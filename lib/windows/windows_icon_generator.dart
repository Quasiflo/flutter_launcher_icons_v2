import 'package:image/image.dart';
import 'package:launcher_icons/abs/icon_generator.dart';
import 'package:launcher_icons/constants.dart' as constants;
import 'package:launcher_icons/utils.dart' as utils;
import 'package:path/path.dart' as path;

/// A Implementation of [IconGenerator] for Windows
class WindowsIconGenerator extends IconGenerator {
  /// Creates a instance of [WindowsIconGenerator]
  WindowsIconGenerator(IconGeneratorContext context)
      : super(context, 'Windows');

  // Minimal, sensible defaults for Windows ICOs.
  static const List<int> _icoSizes = [16, 24, 32, 48, 256];

  @override
  bool get isEnabled => context.windowsConfig?.generate ?? false;

  @override
  Future<void> createIcons() async {
    final imgFilePath = path.join(
      context.prefixPath,
      context.config.resolveImagePath(context.windowsConfig!.imagePath),
    );

    context.logger
        .verbose('Decoding and loading image file from $imgFilePath...');
    final imgFile = await utils.decodeImageFile(imgFilePath);

    context.logger.verbose('Generating icon from $imgFilePath...');
    await _generateIcon(imgFile);
  }

  @override
  bool validateRequirements() {
    // The generate flag is enforced by [isEnabled]; only filesystem and
    // config preconditions are checked here.
    context.logger.verbose('Validating windows config...');
    final windowsConfig = context.windowsConfig!;

    if (context.config.resolveImagePath(windowsConfig.imagePath) == null) {
      context.logger.error(
        'Invalid config. Either provide windows.image_path or image_path',
      );
      return false;
    }

    final entitesToCheck = [
      path.join(context.prefixPath, constants.windowsDirPath),
      path.join(
        context.prefixPath,
        windowsConfig.imagePath ?? context.config.imagePath,
      ),
    ];

    final failedEntityPath = utils.areFSEntiesExist(entitesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate windows icons',
      );
      return false;
    }

    return true;
  }

  Future<void> _generateIcon(Image image) async {
    // Build a multi-frame ICO: one frame per target size.
    Image? multi;
    for (final sz in _icoSizes) {
      final resized = utils.createResizedImage(sz, image);
      if (multi == null) {
        multi = resized;
      } else {
        multi.addFrame(resized);
      }
    }
    final favIconFile = await utils.createFileIfNotExist(
      path.join(context.prefixPath, constants.windowsIconFilePath),
    );
    await favIconFile.writeAsBytes(encodeIco(multi!));
  }
}
