
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

  // Resolve per-appearance sources. Variants fall back to the dark/tinted
  // app artwork so one file serves both unless explicitly overridden.
  final darkSource = iosConfig.imagePathLiquidGlassIconDark ??
      iosConfig.imagePathDarkTransparent;
  final tintedSource = iosConfig.imagePathLiquidGlassIconTinted ??
      iosConfig.imagePathTintedGrayscale;

  // Copy image(s) to Assets folder. Sources pass through verbatim and are
  // never decoded, so SVG layers work as-is.
  final sources = <String>{
    liquidGlassImagePath,
    if (darkSource != null) darkSource,
    if (tintedSource != null) tintedSource,
  };
  for (final source in sources) {
    final sourceImageFile = File(withPrefix(prefixPath, source));
    if (!sourceImageFile.existsSync()) {
      throw InvalidConfigException(
        'Liquid glass icon image not found at: $source',
      );
    }
    final destinationImagePath =
        path.join(assetsFolderPath, path.basename(source));
    await sourceImageFile.copy(destinationImagePath);
  }

  // Generate icon.json
  final imageFileName = path.basename(liquidGlassImagePath);
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

  // Per-appearance layer sources, resolved with the same fallback as the
  // filesystem copy above. A present base key silently wins over the
  // specializations array, so when variants exist the light case becomes
  // the unmarked entry and no base `image-name` is emitted.
  String? variantName(String? source) {
    if (source == null || path.basename(source) == imageFileName) {
      return null;
    }
    return path.basename(source);
  }

  final darkName = variantName(
    iosConfig.imagePathLiquidGlassIconDark ??
        iosConfig.imagePathDarkTransparent,
  );
  final tintedName = variantName(
    iosConfig.imagePathLiquidGlassIconTinted ??
        iosConfig.imagePathTintedGrayscale,
  );

  // Optical pass-throughs. All are opt-in so unset keys stay out of the
  // document and historical output is byte-identical.
  final lighting = iosConfig.liquidGlassLighting;
  if (lighting != null && lighting != 'individual' && lighting != 'combined') {
    throw InvalidConfigException(
      'ios.liquid_glass_lighting must be either "individual" or "combined", got: $lighting',
    );
  }
  Map<String, dynamic>? refractivity;
  if (iosConfig.liquidGlassRefractivityEnabled == true) {
    final depth = iosConfig.liquidGlassRefractivityDepth;
    final strength = iosConfig.liquidGlassRefractivityStrength;
    if (depth == null || strength == null) {
      throw const InvalidConfigException(
        'ios.liquid_glass_refractivity_enabled requires '
        '`liquid_glass_refractivity_depth` and '
        '`liquid_glass_refractivity_strength`.',
      );
    }
    refractivity = {'enabled': true, 'depth': depth, 'strength': strength};
  }
  final specularPlacement = iosConfig.liquidGlassSpecularHighlightPlacement;
  if (specularPlacement != null &&
      specularPlacement != 'inside' &&
      specularPlacement != 'outside') {
    throw InvalidConfigException(
      'ios.liquid_glass_specular_highlight_placement must be either "inside" or "outside", got: $specularPlacement',
    );
  }

  // NOTE: no top-level `features` declaration is emitted. It is optional
  // per the format (the keys below stand alone), and actool rejects the
  // array with an internal error — verified against Xcode 26.6.

  final layer = <String, dynamic>{
    'glass': !iosConfig.removeLiquidGlass,
    'hidden': false,
    'name': imageName,
    'position': {
      'scale': iosConfig.liquidGlassIconScale,
      'translation-in-points': [
        iosConfig.liquidGlassOffsetX ?? 0.0,
        iosConfig.liquidGlassOffsetY ?? 0.0,
      ],
    },
  };
  if (darkName == null && tintedName == null) {
    layer['image-name'] = imageFileName;
  } else {
    layer['image-name-specializations'] = [
      {'value': imageFileName},
      if (darkName != null) {'appearance': 'dark', 'value': darkName},
      if (tintedName != null) {'appearance': 'tinted', 'value': tintedName},
    ];
  }

  return {
    'fill': {
      'solid': displayP3Color,
    },
    'groups': [
      {
        'blur-material': iosConfig.liquidGlassBlur,
        if (lighting != null) 'lighting': lighting,
        'layers': [layer],
        if (refractivity != null) 'refractivity': refractivity,
        'shadow': {
          'kind': iosConfig.liquidGlassShadowKind.toLowerCase() == 'chromatic'
              ? 'layer-color'
              : iosConfig.liquidGlassShadowKind.toLowerCase(),
          'opacity': iosConfig.liquidGlassShadowOpacity,
        },
        'specular': iosConfig.liquidGlassSpecular,
        if (specularPlacement != null)
          'specular-highlight-placement': specularPlacement,
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
