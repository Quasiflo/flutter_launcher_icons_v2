// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:launcher_icons/config/config.dart';
import 'package:launcher_icons/config/ios_config.dart';
import 'package:launcher_icons/constants.dart';
import 'package:launcher_icons/custom_exceptions.dart';
import 'package:launcher_icons/logger.dart';
import 'package:launcher_icons/utils.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// Generate liquid glass .icon file for iOS
Future<void> generateLiquidGlassIcon(
  Config config,
  String iconName, {
  LILogger? logger,
  String prefixPath = '.',
}) async {
  if (!config.hasLiquidGlassIconConfig) {
    return;
  }

  final iosConfig = config.iosConfig!;
  final String? liquidGlassImagePath = iosConfig.imagePathLiquidGlassIcon;
  if (liquidGlassImagePath == null) {
    return;
  }

  // Validate shadow kind
  final shadowKind = iosConfig.liquidGlassShadowKind.toLowerCase();
  if (shadowKind != 'neutral' && shadowKind != 'chromatic') {
    throw InvalidConfigException(
      'ios.liquid_glass_shadow_kind must be either "Neutral" or "Chromatic", got: ${iosConfig.liquidGlassShadowKind}',
    );
  }

  // Check if source image exists
  final sourceImageFile = File(withPrefix(prefixPath, liquidGlassImagePath));
  if (!sourceImageFile.existsSync()) {
    throw InvalidConfigException(
      'Liquid glass icon image not found at: $liquidGlassImagePath',
    );
  }

  printStatus('Creating liquid glass .icon for $iconName', logger);

  // Create directory structure
  final iconFolderPath =
      withPrefix(prefixPath, iosLiquidGlassIconPath(iconName));
  final assetsFolderPath =
      withPrefix(prefixPath, iosLiquidGlassAssetsPath(iconName));
  final configFilePath =
      withPrefix(prefixPath, iosLiquidGlassConfigPath(iconName));

  await createDirIfNotExist(iconFolderPath);
  await createDirIfNotExist(assetsFolderPath);

  // Copy image to Assets folder
  final imageFileName = path.basename(liquidGlassImagePath);
  final destinationImagePath = path.join(assetsFolderPath, imageFileName);
  await sourceImageFile.copy(destinationImagePath);

  // Generate icon.json
  final iconConfig = generateIconConfig(config, imageFileName);
  final configFile = await createFileIfNotExist(configFilePath);
  await configFile.writeAsString(prettifyJsonEncode(iconConfig));

  printStatus('Generated liquid glass .icon at $iconFolderPath', logger);
}

/// Generate the icon.json configuration
@visibleForTesting
Map<String, dynamic> generateIconConfig(Config config, String imageFileName) {
  // Fall back to defaults so direct callers don't need an ios block.
  final iosConfig = config.iosConfig ?? const IOSConfig();
  // Convert background color to display P3 format
  final displayP3Color = convertHexToDisplayP3(iosConfig.backgroundColor);

  // Extract image name without extension for the layer name
  final imageName = path.basenameWithoutExtension(imageFileName);

  return {
    'fill': {
      'solid': displayP3Color,
    },
    'groups': [
      {
        'blur-material': iosConfig.liquidGlassBlur,
        'layers': [
          {
            'glass': !iosConfig.removeLiquidGlass,
            'hidden': false,
            'image-name': imageFileName,
            'name': imageName,
            'position': {
              'scale': iosConfig.liquidGlassIconScale,
              'translation-in-points': [
                iosConfig.liquidGlassOffsetX ?? 0.0,
                iosConfig.liquidGlassOffsetY ?? 0.0,
              ],
            },
          },
        ],
        'shadow': {
          'kind': iosConfig.liquidGlassShadowKind.toLowerCase() == 'chromatic'
              ? 'layer-color'
              : iosConfig.liquidGlassShadowKind.toLowerCase(),
          'opacity': iosConfig.liquidGlassShadowOpacity,
        },
        'specular': iosConfig.liquidGlassSpecular,
        'translucency': {
          'enabled': !iosConfig.removeLiquidGlass,
          'value': iosConfig.liquidGlassTranslucency ?? 0.5,
        },
      },
    ],
    'supported-platforms': {
      'circles': ['watchOS'],
      'squares': 'shared',
    },
  };
}

/// Convert hex color to Display P3 format (as used by Apple Icon Composer)
@visibleForTesting
String convertHexToDisplayP3(String hexColor) {
  final (:r, :g, :b) = parseHexColor(hexColor);

  return 'display-p3:${(r / 255).toStringAsFixed(5)},'
      '${(g / 255).toStringAsFixed(5)},'
      '${(b / 255).toStringAsFixed(5)},1.00000';
}
