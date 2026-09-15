import 'dart:io';

import 'package:launcher_icons/src/config/config.dart';
import 'package:launcher_icons/src/config/ios_config.dart';
import 'package:launcher_icons/src/config/macos_config.dart';
import 'package:launcher_icons/src/core/constants.dart';
import 'package:launcher_icons/src/core/custom_exceptions.dart';
import 'package:launcher_icons/src/core/logger.dart';
import 'package:launcher_icons/src/core/utils.dart';
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

  printStatus('Creating liquid glass .icon for $iconName', logger);

  // Resolve per-appearance sources. Variants fall back to the dark/tinted
  // app artwork so one file serves both unless explicitly overridden.
  final darkSource = iosConfig.imagePathLiquidGlassIconDark ??
      iosConfig.imagePathDarkTransparent;
  final tintedSource = iosConfig.imagePathLiquidGlassIconTinted ??
      iosConfig.imagePathTintedGrayscale;

  await _writeLiquidGlassBundle(
    sources: {
      liquidGlassImagePath,
      if (darkSource != null) darkSource,
      if (tintedSource != null) tintedSource,
    },
    iconFolderPath: withPrefix(prefixPath, iosLiquidGlassIconPath(iconName)),
    assetsFolderPath:
        withPrefix(prefixPath, iosLiquidGlassAssetsPath(iconName)),
    configFilePath: withPrefix(prefixPath, iosLiquidGlassConfigPath(iconName)),
    iconConfig: generateIconConfig(config, path.basename(liquidGlassImagePath)),
    iconFolderDisplayPath: iosLiquidGlassIconPath(iconName),
    logger: logger,
    prefixPath: prefixPath,
  );
}

/// Generate liquid glass .icon file for macOS (Tahoe 26+ renders live glass
/// from it; the PNG catalog stays the fallback on older systems).
Future<void> generateMacOSLiquidGlassIcon(
  Config config,
  String iconName, {
  LILogger? logger,
  String prefixPath = '.',
}) async {
  if (!config.hasMacOSLiquidGlassIconConfig) {
    return;
  }

  final macOSConfig = config.macOSConfig!;
  final String? liquidGlassImagePath = macOSConfig.imagePathLiquidGlassIcon;
  if (liquidGlassImagePath == null) {
    return;
  }

  printStatus('Creating macOS liquid glass .icon for $iconName', logger);

  // macOS has no dark/tinted PNG catalog variants to fall back to: only
  // explicitly configured layer sources become appearances.
  await _writeLiquidGlassBundle(
    sources: {
      liquidGlassImagePath,
      if (macOSConfig.imagePathLiquidGlassIconDark != null)
        macOSConfig.imagePathLiquidGlassIconDark!,
      if (macOSConfig.imagePathLiquidGlassIconTinted != null)
        macOSConfig.imagePathLiquidGlassIconTinted!,
    },
    iconFolderPath: withPrefix(prefixPath, macOSLiquidGlassIconPath(iconName)),
    assetsFolderPath:
        withPrefix(prefixPath, macOSLiquidGlassAssetsPath(iconName)),
    configFilePath:
        withPrefix(prefixPath, macOSLiquidGlassConfigPath(iconName)),
    iconConfig:
        generateMacOSIconConfig(config, path.basename(liquidGlassImagePath)),
    iconFolderDisplayPath: macOSLiquidGlassIconPath(iconName),
    logger: logger,
    prefixPath: prefixPath,
  );
}

/// Copies layer [sources] into the `.icon` bundle folders, sweeps orphaned
/// layers, and writes the `icon.json` document.
Future<void> _writeLiquidGlassBundle({
  required Set<String> sources,
  required String iconFolderPath,
  required String assetsFolderPath,
  required String configFilePath,
  required Map<String, dynamic> iconConfig,
  required String iconFolderDisplayPath,
  required LILogger? logger,
  required String prefixPath,
}) async {
  await createDirIfNotExist(iconFolderPath);
  await createDirIfNotExist(assetsFolderPath);

  // Copy image(s) to Assets folder. Sources pass through verbatim and are
  // never decoded, so SVG layers work as-is.
  final wantedBasenames = <String>{};
  for (final source in sources) {
    final sourceImageFile = File(withPrefix(prefixPath, source));
    if (!sourceImageFile.existsSync()) {
      throw InvalidConfigException(
        'Liquid glass icon image not found at: $source',
      );
    }
    final basename = path.basename(source);
    wantedBasenames.add(basename);
    await sourceImageFile.copy(path.join(assetsFolderPath, basename));
  }
  // Sweep layers orphaned by source switches (e.g. PNG replaced by SVG):
  // the Assets folder is fully tool-owned.
  for (final entity in Directory(assetsFolderPath).listSync()) {
    if (entity is File &&
        !wantedBasenames.contains(path.basename(entity.path))) {
      printStatus(
        'Removing orphaned liquid glass asset ${path.basename(entity.path)}',
        logger,
      );
      await entity.delete();
    }
  }

  // Generate icon.json
  final configFile = await createFileIfNotExist(configFilePath);
  await configFile.writeAsString(prettifyJsonEncode(iconConfig));

  printStatus('Generated liquid glass .icon at $iconFolderDisplayPath', logger);
}

/// Resolves a per-appearance layer basename: null when unset or identical to
/// the base image (a present base key silently wins over the specializations
/// array, so same-file variants must not be emitted).
String? _variantName(String? source, String imageFileName) {
  if (source == null || path.basename(source) == imageFileName) {
    return null;
  }
  return path.basename(source);
}

/// Generate the icon.json configuration
@visibleForTesting
Map<String, dynamic> generateIconConfig(Config config, String imageFileName) {
  // Fall back to defaults so direct callers don't need an ios block.
  final iosConfig = config.iosConfig ?? const IOSConfig();
  return buildLiquidGlassDocument(
    platform: 'ios',
    backgroundColor: iosConfig.backgroundColor,
    imageFileName: imageFileName,
    darkName: _variantName(
      iosConfig.imagePathLiquidGlassIconDark ??
          iosConfig.imagePathDarkTransparent,
      imageFileName,
    ),
    tintedName: _variantName(
      iosConfig.imagePathLiquidGlassIconTinted ??
          iosConfig.imagePathTintedGrayscale,
      imageFileName,
    ),
    removeGlass: iosConfig.removeLiquidGlass,
    scale: iosConfig.liquidGlassIconScale,
    offsetX: iosConfig.liquidGlassOffsetX,
    offsetY: iosConfig.liquidGlassOffsetY,
    translucency: iosConfig.liquidGlassTranslucency,
    specular: iosConfig.liquidGlassSpecular,
    shadowKind: iosConfig.liquidGlassShadowKind,
    shadowOpacity: iosConfig.liquidGlassShadowOpacity,
    blur: iosConfig.liquidGlassBlur,
    lighting: iosConfig.liquidGlassLighting,
    refractivityEnabled: iosConfig.liquidGlassRefractivityEnabled,
    refractivityDepth: iosConfig.liquidGlassRefractivityDepth,
    refractivityStrength: iosConfig.liquidGlassRefractivityStrength,
    specularPlacement: iosConfig.liquidGlassSpecularHighlightPlacement,
  );
}

/// Generate the macOS icon.json configuration.
///
/// macOS shares Icon Composer's document format with iOS (one shared square
/// design covers both); only the option source differs.
@visibleForTesting
Map<String, dynamic> generateMacOSIconConfig(
  Config config,
  String imageFileName,
) {
  // Fall back to defaults so direct callers don't need a macos block.
  final macOSConfig = config.macOSConfig ?? const MacOSConfig();
  return buildLiquidGlassDocument(
    platform: 'macos',
    backgroundColor: macOSConfig.backgroundColor,
    imageFileName: imageFileName,
    darkName: _variantName(
      macOSConfig.imagePathLiquidGlassIconDark,
      imageFileName,
    ),
    tintedName: _variantName(
      macOSConfig.imagePathLiquidGlassIconTinted,
      imageFileName,
    ),
    removeGlass: macOSConfig.removeLiquidGlass,
    scale: macOSConfig.liquidGlassIconScale,
    offsetX: macOSConfig.liquidGlassOffsetX,
    offsetY: macOSConfig.liquidGlassOffsetY,
    translucency: macOSConfig.liquidGlassTranslucency,
    specular: macOSConfig.liquidGlassSpecular,
    shadowKind: macOSConfig.liquidGlassShadowKind,
    shadowOpacity: macOSConfig.liquidGlassShadowOpacity,
    blur: macOSConfig.liquidGlassBlur,
    lighting: macOSConfig.liquidGlassLighting,
    refractivityEnabled: macOSConfig.liquidGlassRefractivityEnabled,
    refractivityDepth: macOSConfig.liquidGlassRefractivityDepth,
    refractivityStrength: macOSConfig.liquidGlassRefractivityStrength,
    specularPlacement: macOSConfig.liquidGlassSpecularHighlightPlacement,
  );
}

/// Builds the Icon Composer `icon.json` document from explicit values.
///
/// [platform] labels validation errors (`ios` or `macos`). Optical
/// pass-throughs are opt-in so unset keys stay out of the document.
@visibleForTesting
Map<String, dynamic> buildLiquidGlassDocument({
  required String platform,
  required String backgroundColor,
  required String imageFileName,
  required String? darkName,
  required String? tintedName,
  required bool removeGlass,
  required double scale,
  required double? offsetX,
  required double? offsetY,
  required double? translucency,
  required bool specular,
  required String shadowKind,
  required double? shadowOpacity,
  required double? blur,
  required String? lighting,
  required bool? refractivityEnabled,
  required double? refractivityDepth,
  required double? refractivityStrength,
  required String? specularPlacement,
}) {
  // Convert background color to display P3 format
  final displayP3Color = convertHexToDisplayP3(backgroundColor);

  // Extract image name without extension for the layer name
  final imageName = path.basenameWithoutExtension(imageFileName);

  // Validate shadow kind
  if (shadowKind.toLowerCase() != 'neutral' &&
      shadowKind.toLowerCase() != 'chromatic') {
    throw InvalidConfigException(
      '$platform.liquid_glass_shadow_kind must be either "Neutral" or "Chromatic", got: $shadowKind',
    );
  }

  // Optical pass-throughs. All are opt-in so unset keys stay out of the
  // document and historical output is byte-identical.
  if (lighting != null && lighting != 'individual' && lighting != 'combined') {
    throw InvalidConfigException(
      '$platform.liquid_glass_lighting must be either "individual" or "combined", got: $lighting',
    );
  }
  Map<String, dynamic>? refractivity;
  if (refractivityEnabled == true) {
    if (refractivityDepth == null || refractivityStrength == null) {
      throw InvalidConfigException(
        '$platform.liquid_glass_refractivity_enabled requires '
        '`liquid_glass_refractivity_depth` and '
        '`liquid_glass_refractivity_strength`.',
      );
    }
    refractivity = {
      'enabled': true,
      'depth': refractivityDepth,
      'strength': refractivityStrength,
    };
  }
  if (specularPlacement != null &&
      specularPlacement != 'inside' &&
      specularPlacement != 'outside') {
    throw InvalidConfigException(
      '$platform.liquid_glass_specular_highlight_placement must be either "inside" or "outside", got: $specularPlacement',
    );
  }

  // NOTE: no top-level `features` declaration is emitted. It is optional
  // per the format (the keys below stand alone), and actool rejects the
  // array with an internal error — verified against Xcode 26.6.

  final layer = <String, dynamic>{
    'glass': !removeGlass,
    'hidden': false,
    'name': imageName,
    'position': {
      'scale': scale,
      'translation-in-points': [offsetX ?? 0.0, offsetY ?? 0.0],
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
        'blur-material': blur,
        if (lighting != null) 'lighting': lighting,
        'layers': [layer],
        if (refractivity != null) 'refractivity': refractivity,
        'shadow': {
          'kind': shadowKind.toLowerCase() == 'chromatic'
              ? 'layer-color'
              : shadowKind.toLowerCase(),
          'opacity': shadowOpacity,
        },
        'specular': specular,
        if (specularPlacement != null)
          'specular-highlight-placement': specularPlacement,
        'translucency': {
          'enabled': !removeGlass,
          'value': translucency ?? 0.5,
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
