// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ios_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IOSConfig _$IOSConfigFromJson(Map json) => $checkedCreate(
      'IOSConfig',
      json,
      ($checkedConvert) {
        final val = IOSConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          singleSize:
              $checkedConvert('single_size', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
          iconName: $checkedConvert('icon_name', (v) => v as String?),
          xcodeprojPath: $checkedConvert('xcodeproj_path', (v) => v as String?),
          imagePathDarkTransparent: $checkedConvert(
              'image_path_dark_transparent', (v) => v as String?),
          imagePathTintedGrayscale: $checkedConvert(
              'image_path_tinted_grayscale', (v) => v as String?),
          imagePathLiquidGlassIcon: $checkedConvert(
              'image_path_liquid_glass_icon', (v) => v as String?),
          imagePathLiquidGlassIconDark: $checkedConvert(
              'image_path_liquid_glass_icon_dark', (v) => v as String?),
          imagePathLiquidGlassIconTinted: $checkedConvert(
              'image_path_liquid_glass_icon_tinted', (v) => v as String?),
          removeAlpha:
              $checkedConvert('remove_alpha', (v) => v as bool? ?? false),
          removeLiquidGlass: $checkedConvert(
              'remove_liquid_glass', (v) => v as bool? ?? false),
          desaturateTintedToGrayscale: $checkedConvert(
              'desaturate_tinted_to_grayscale', (v) => v as bool? ?? false),
          backgroundColor: $checkedConvert(
              'background_color', (v) => v as String? ?? '#ffffff'),
          liquidGlassIconScale: $checkedConvert(
              'liquid_glass_icon_scale', (v) => (v as num?)?.toDouble() ?? 1),
          liquidGlassTranslucency: $checkedConvert('liquid_glass_translucency',
              (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassSpecular: $checkedConvert(
              'liquid_glass_specular', (v) => v as bool? ?? true),
          liquidGlassShadowKind: $checkedConvert(
              'liquid_glass_shadow_kind', (v) => v as String? ?? 'Neutral'),
          liquidGlassShadowOpacity: $checkedConvert(
              'liquid_glass_shadow_opacity',
              (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassBlur: $checkedConvert(
              'liquid_glass_blur', (v) => (v as num?)?.toDouble() ?? 0.5),
          liquidGlassOffsetX: $checkedConvert(
              'liquid_glass_offset_x', (v) => (v as num?)?.toDouble() ?? 0.0),
          liquidGlassOffsetY: $checkedConvert(
              'liquid_glass_offset_y', (v) => (v as num?)?.toDouble() ?? 0.0),
        );
        return val;
      },
      fieldKeyMap: const {
        'singleSize': 'single_size',
        'imagePath': 'image_path',
        'iconName': 'icon_name',
        'xcodeprojPath': 'xcodeproj_path',
        'imagePathDarkTransparent': 'image_path_dark_transparent',
        'imagePathTintedGrayscale': 'image_path_tinted_grayscale',
        'imagePathLiquidGlassIcon': 'image_path_liquid_glass_icon',
        'imagePathLiquidGlassIconDark': 'image_path_liquid_glass_icon_dark',
        'imagePathLiquidGlassIconTinted': 'image_path_liquid_glass_icon_tinted',
        'removeAlpha': 'remove_alpha',
        'removeLiquidGlass': 'remove_liquid_glass',
        'desaturateTintedToGrayscale': 'desaturate_tinted_to_grayscale',
        'backgroundColor': 'background_color',
        'liquidGlassIconScale': 'liquid_glass_icon_scale',
        'liquidGlassTranslucency': 'liquid_glass_translucency',
        'liquidGlassSpecular': 'liquid_glass_specular',
        'liquidGlassShadowKind': 'liquid_glass_shadow_kind',
        'liquidGlassShadowOpacity': 'liquid_glass_shadow_opacity',
        'liquidGlassBlur': 'liquid_glass_blur',
        'liquidGlassOffsetX': 'liquid_glass_offset_x',
        'liquidGlassOffsetY': 'liquid_glass_offset_y'
      },
    );

Map<String, dynamic> _$IOSConfigToJson(IOSConfig instance) => <String, dynamic>{
      'generate': instance.generate,
      'single_size': instance.singleSize,
      'image_path': instance.imagePath,
      'icon_name': instance.iconName,
      'xcodeproj_path': instance.xcodeprojPath,
      'image_path_dark_transparent': instance.imagePathDarkTransparent,
      'image_path_tinted_grayscale': instance.imagePathTintedGrayscale,
      'image_path_liquid_glass_icon': instance.imagePathLiquidGlassIcon,
      'image_path_liquid_glass_icon_dark':
          instance.imagePathLiquidGlassIconDark,
      'image_path_liquid_glass_icon_tinted':
          instance.imagePathLiquidGlassIconTinted,
      'remove_alpha': instance.removeAlpha,
      'remove_liquid_glass': instance.removeLiquidGlass,
      'desaturate_tinted_to_grayscale': instance.desaturateTintedToGrayscale,
      'background_color': instance.backgroundColor,
      'liquid_glass_icon_scale': instance.liquidGlassIconScale,
      'liquid_glass_translucency': instance.liquidGlassTranslucency,
      'liquid_glass_specular': instance.liquidGlassSpecular,
      'liquid_glass_shadow_kind': instance.liquidGlassShadowKind,
      'liquid_glass_shadow_opacity': instance.liquidGlassShadowOpacity,
      'liquid_glass_blur': instance.liquidGlassBlur,
      'liquid_glass_offset_x': instance.liquidGlassOffsetX,
      'liquid_glass_offset_y': instance.liquidGlassOffsetY,
    };
