import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:launcher_icons/abs/icon_generator.dart';
import 'package:launcher_icons/constants.dart' as constants;
import 'package:launcher_icons/macos/macos_icon_effects.dart'
    as effects;
import 'package:launcher_icons/macos/macos_icon_template.dart';
import 'package:launcher_icons/utils.dart' as utils;
import 'package:path/path.dart' as path;

/// A [IconGenerator] implementation for macos
class MacOSIconGenerator extends IconGenerator {
  static const _iconSizeTemplates = <MacOSIconTemplate>[
    MacOSIconTemplate(16, 1),
    MacOSIconTemplate(16, 2),
    MacOSIconTemplate(32, 1),
    MacOSIconTemplate(32, 2),
    MacOSIconTemplate(128, 1),
    MacOSIconTemplate(128, 2),
    MacOSIconTemplate(256, 1),
    MacOSIconTemplate(256, 2),
    MacOSIconTemplate(512, 1),
    MacOSIconTemplate(512, 2),
  ];

  /// Creates a instance of [MacOSIconGenerator]
  MacOSIconGenerator(IconGeneratorContext context) : super(context, 'MacOS');

  @override
  bool get isEnabled => context.macOSConfig?.generate ?? false;

  /// Icons directory, flavor-aware: `AppIcon-<flavor>.appiconset` for flavor
  /// runs so macOS honors flavors like iOS does (#638).
  String _iconsDirPath() {
    final flavor = context.flavor;
    if (flavor == null) {
      return constants.macOSIconsDirPath;
    }
    return path.join(
      constants.macOSDirPath,
      'Runner',
      'Assets.xcassets',
      'AppIcon-$flavor.appiconset',
    );
  }

  /// Contents.json path matching [_iconsDirPath].
  String _contentsFilePath() => path.join(_iconsDirPath(), 'Contents.json');

  @override
  Future<void> createIcons() async {
    final imgFilePath = path.join(
      context.prefixPath,
      context.config.macOSConfig!.imagePath ?? context.config.imagePath,
    );

    context.logger
        .verbose('Decoding and loading image file at $imgFilePath...');
    final imgFile = await utils.decodeImageFile(imgFilePath);

    context.logger.verbose('Generating icons $imgFilePath...');
    await _generateIcons(imgFile);
    context.logger.verbose('Updating contents.json');
    _updateContentsFile();
  }

  @override
  bool validateRequirements() {
    // The generate flag is enforced by [isEnabled]; only filesystem and
    // config preconditions are checked here.
    context.logger.verbose('Checking $platformName config...');
    final macOSConfig = context.macOSConfig!;

    if (macOSConfig.imagePath == null && context.config.imagePath == null) {
      context.logger.error(
        'Missing image_path. Either provide "launcher_icons.macos.image_path" or "launcher_icons.image_path"',
      );

      return false;
    }

    // this files and folders should exist to create macos icons
    final enitiesToCheck = [
      path.join(context.prefixPath, constants.macOSDirPath),
      path.join(context.prefixPath, _iconsDirPath()),
      path.join(context.prefixPath, _contentsFilePath()),
    ];

    final failedEntityPath = utils.areFSEntiesExist(enitiesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate $platformName icons',
      );
      return false;
    }

    return true;
  }

  Future<void> _generateIcons(Image image) async {
    final iconsDir = await utils.createDirIfNotExist(
      path.join(context.prefixPath, _iconsDirPath()),
    );
    final padding = context.macOSConfig?.padding ?? 0;
    final roundedCorners = context.macOSConfig?.roundedCorners ?? false;

    for (final template in _iconSizeTemplates) {
      final resizedImg = effects.buildMacOSIconImage(
        image,
        template.scaledSize,
        paddingPercent: padding,
        roundedCorners: roundedCorners,
      );
      final iconFile = await utils.createFileIfNotExist(
        path.join(context.prefixPath, iconsDir.path, template.iconFile),
      );
      await iconFile.writeAsBytes(encodePng(resizedImg));
    }
  }

  void _updateContentsFile() {
    final contentsFilePath =
        File(path.join(context.prefixPath, _contentsFilePath()));
    final contentsConfig =
        jsonDecode(contentsFilePath.readAsStringSync()) as Map<String, dynamic>;
    contentsConfig
      ..remove('images')
      ..['images'] = _iconSizeTemplates
          .map<Map<String, dynamic>>((e) => e.iconContent)
          .toList();

    contentsFilePath
        .writeAsStringSync(utils.prettifyJsonEncode(contentsConfig));
  }
}
