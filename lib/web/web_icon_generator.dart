import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

import '../abs/icon_generator.dart';
import '../constants.dart' as constants;
import '../utils.dart' as utils;
import 'web_template.dart';

/// Generates Web icons for flutter
class WebIconGenerator extends IconGenerator {
  static const _webIconSizeTemplates = <WebIconTemplate>[
    WebIconTemplate(size: 192),
    WebIconTemplate(size: 512),
    WebIconTemplate(size: 192, maskable: true),
    WebIconTemplate(size: 512, maskable: true),
  ];

  /// Creates an instance of [WebIconGenerator].
  ///
  ///
  WebIconGenerator(IconGeneratorContext context) : super(context, 'Web');

  @override
  bool get isEnabled => context.webConfig?.generate ?? false;

  /// Web root directory honoring `output_path` (default `web`), so flavors
  /// can target separate web roots (#426).
  String get _webDirPath => context.webConfig?.outputPath ?? 'web';

  /// All web file paths resolved under [_webDirPath].
  String get _manifestFilePath => path.join(_webDirPath, 'manifest.json');
  String get _indexFilePath => path.join(_webDirPath, 'index.html');
  String get _faviconFilePath => path.join(_webDirPath, 'favicon.png');
  String get _faviconIcoFilePath => path.join(_webDirPath, 'favicon.ico');
  String get _iconsDirPath => path.join(_webDirPath, 'icons');

  /// Opaque 180x180 apple-touch-icon for iOS Safari, which ignores manifest
  /// icons or picks the wrong art without an explicit tag.
  String get _appleTouchIconFilePath =>
      path.join(_iconsDirPath, 'apple-touch-icon.png');

  @override
  Future<void> createIcons() async {
    final imgFilePath = path.join(
      context.prefixPath,
      context.config.resolveImagePath(context.webConfig!.imagePath)!,
    );

    // load and decode the image file
    context.logger
        .verbose('Decoding and loading image file at $imgFilePath...');
    final imgFile = await utils.decodeImageFile(imgFilePath);

    // resolve the favicon image path and file, which is either one explicitly
    // provided or the same as the image file loaded above
    late final String faviconImgFilePath;
    late final Image faviconImgFile;
    final faviconImagePathOverride = context.webConfig!.imagePathFavicon;
    if (faviconImagePathOverride != null) {
      // favicon override was specified, construct the full path and decode
      faviconImgFilePath =
          path.join(context.prefixPath, faviconImagePathOverride);
      final faviconImageFile = await utils.decodeImageFile(faviconImgFilePath);
      faviconImgFile = faviconImageFile;
    } else {
      // no favicon override, use the fallback image file
      faviconImgFilePath = imgFilePath;
      faviconImgFile = imgFile;
    }

    // generate favicon in web/favicon.png
    context.logger.verbose('Generating favicon from $faviconImgFilePath...');
    await _generateFavicon(faviconImgFile);

    // generate icons in web/icons/
    context.logger.verbose('Generating icons from $imgFilePath...');
    await _generateIcons(imgFile);

    // update manifest.json in <web root>/manifest.json
    context.logger.verbose(
      'Updating ${path.join(context.prefixPath, _manifestFilePath)}...',
    );
    await _updateManifestFile();

    // iOS Safari needs an explicit opaque 180px touch icon.
    context.logger.verbose('Generating apple-touch-icon from $imgFilePath...');
    await _generateAppleTouchIcon(imgFile);

    // make the generated files discoverable from index.html
    context.logger.verbose(
      'Updating ${path.join(context.prefixPath, _indexFilePath)}...',
    );
    await _updateIndexFile();
  }

  @override
  bool validateRequirements() {
    // The generate flag is enforced by [isEnabled]; only filesystem and
    // config preconditions are checked here.
    context.logger.verbose('Checking webconfig...');
    final webConfig = context.webConfig!;
    if (context.config.resolveImagePath(webConfig.imagePath) == null) {
      context.logger.error(
        'Invalid config. Either provide web.imagePath or imagePath',
      );
      return false;
    }

    // verify web platform related files and directories exists
    final entitesToCheck = [
      path.join(context.prefixPath, _webDirPath),
      path.join(context.prefixPath, _manifestFilePath),
      path.join(context.prefixPath, _indexFilePath),
    ];

    // web platform related files must exist to continue
    final failedEntityPath = utils.areFSEntiesExist(entitesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate web icons',
      );
      return false;
    }

    return true;
  }

  Future<void> _generateFavicon(Image image) async {
    final size = context.webConfig?.faviconSize ?? constants.kFaviconSize;
    final favIcon = utils.createResizedImage(
      size > 0 ? size : constants.kFaviconSize,
      image,
    );
    final favIconFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, _faviconFilePath),
    );
    await favIconFile.writeAsBytes(encodePng(favIcon));
    // Browsers request /favicon.ico by default; emit it alongside (#540).
    // index.html keeps pointing at favicon.png, either file now resolves.
    final favIcoFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, _faviconIcoFilePath),
    );
    await favIcoFile.writeAsBytes(encodeIco(favIcon));
  }

  Future<void> _generateIcons(Image image) async {
    final iconsDir = await utils.createDirIfNotExist(
      path.join(context.prefixPath, _iconsDirPath),
    );
    // generate icons
    for (final template in _webIconSizeTemplates) {
      final resizedImg = utils.createResizedImage(template.size, image);
      final iconFile = await utils.createFileIfNotExist(
        path.join(context.prefixPath, iconsDir.path, template.iconFile),
      );
      await iconFile.writeAsBytes(encodePng(resizedImg));
    }
  }

  Future<void> _updateManifestFile() async {
    final manifestFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, _manifestFilePath),
    );
    final manifestConfig =
        jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;

    // update background_color
    if (context.webConfig?.backgroundColor != null) {
      manifestConfig['background_color'] = context.webConfig?.backgroundColor;
    }

    // update theme_color
    if (context.webConfig?.themeColor != null) {
      manifestConfig['theme_color'] = context.webConfig?.themeColor;
    }

    // replace existing icons to eliminate conflicts
    manifestConfig
      ..remove('icons')
      ..['icons'] = _webIconSizeTemplates
          .map<Map<String, dynamic>>((e) => e.iconManifest)
          .toList();

    await manifestFile.writeAsString(utils.prettifyJsonEncode(manifestConfig));
  }

  /// Generates an opaque 180x180 `apple-touch-icon.png` by flattening the
  /// source onto `background_color` (white fallback).
  Future<void> _generateAppleTouchIcon(Image source) async {
    const size = 180;
    final resized = utils.createResizedImage(size, source);
    final rgba = resized.numChannels == 4
        ? resized
        : resized.convert(numChannels: 4);

    var bg = (r: 255, g: 255, b: 255);
    final bgRaw = context.webConfig?.backgroundColor;
    if (bgRaw != null) {
      try {
        bg = utils.parseHexColor(bgRaw);
      } catch (_) {
        context.logger.verbose(
          'Ignoring non-hex background_color "$bgRaw" for apple-touch-icon; using white.',
        );
      }
    }

    final flat = Image(width: size, height: size, numChannels: 3);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final pixel = rgba.getPixel(x, y);
        final alpha = pixel.a.toInt().clamp(0, 255);
        final invAlpha = 255 - alpha;
        flat.setPixelRgb(
          x,
          y,
          (pixel.r.toInt() * alpha + bg.r * invAlpha) ~/ 255,
          (pixel.g.toInt() * alpha + bg.g * invAlpha) ~/ 255,
          (pixel.b.toInt() * alpha + bg.b * invAlpha) ~/ 255,
        );
      }
    }

    final iconFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, _appleTouchIconFilePath),
    );
    await iconFile.writeAsBytes(encodePng(flat));
  }

  /// Manages an idempotent `<!--LI-->…<!--LIEND-->` block in index.html
  /// wiring up the favicon, apple-touch-icon, manifest, and theme-color.
  /// An existing block is replaced in place; otherwise the block is
  /// inserted before `</head>`.
  Future<void> _updateIndexFile() async {
    final indexFile = File(path.join(context.prefixPath, _indexFilePath));
    var content = await indexFile.readAsString();

    final favSize =
        context.webConfig?.faviconSize ?? constants.kFaviconSize;
    final themeColor = context.webConfig?.themeColor;
    final block = '''
  <!--LI-->
  <link rel="icon" type="image/x-icon" sizes="any" href="favicon.ico"/>
  <link rel="icon" type="image/png" sizes="${favSize}x$favSize" href="favicon.png"/>
  <link rel="apple-touch-icon" href="icons/apple-touch-icon.png"/>
  <link rel="manifest" href="manifest.json"/>${themeColor != null ? '\n  <meta name="theme-color" content="$themeColor"/>' : ''}
  <!--LIEND-->''';

    final pattern = RegExp(r'<!--LI-->.*?<!--LIEND-->', dotAll: true);
    if (pattern.hasMatch(content)) {
      content = content.replaceAll(pattern, block);
    } else if (content.contains('</head>')) {
      content = content.replaceFirst('</head>', '$block\n</head>');
    } else {
      content = '$content\n$block\n';
    }
    await indexFile.writeAsString(content);
  }
}
