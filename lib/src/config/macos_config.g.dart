// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macos_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacOSConfig _$MacOSConfigFromJson(Map json) => $checkedCreate(
      'MacOSConfig',
      json,
      ($checkedConvert) {
        final val = MacOSConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
          padding: $checkedConvert('padding', (v) => (v as num?)?.toInt() ?? 0),
          roundedCorners:
              $checkedConvert('rounded_corners', (v) => v as bool? ?? false),
          imagePathLiquidGlassIcon: $checkedConvert(
              'image_path_liquid_glass_icon', (v) => v as String?),
          imagePathLiquidGlassIconDark: $checkedConvert(
              'image_path_liquid_glass_icon_dark', (v) => v as String?),
          imagePathLiquidGlassIconTinted: $checkedConvert(
              'image_path_liquid_glass_icon_tinted', (v) => v as String?),
          removeLiquidGlass: $checkedConvert(
              'remove_liquid_glass', (v) => v as bool? ?? false),
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
          liquidGlassLighting:
              $checkedConvert('liquid_glass_lighting', (v) => v as String?),
          liquidGlassRefractivityEnabled: $checkedConvert(
              'liquid_glass_refractivity_enabled', (v) => v as bool?),
          liquidGlassRefractivityDepth: $checkedConvert(
              'liquid_glass_refractivity_depth',
              (v) => (v as num?)?.toDouble()),
          liquidGlassRefractivityStrength: $checkedConvert(
              'liquid_glass_refractivity_strength',
              (v) => (v as num?)?.toDouble()),
          liquidGlassSpecularHighlightPlacement: $checkedConvert(
              'liquid_glass_specular_highlight_placement', (v) => v as String?),
          liquidGlassOffsetX: $checkedConvert(
              'liquid_glass_offset_x', (v) => (v as num?)?.toDouble() ?? 0.0),
          liquidGlassOffsetY: $checkedConvert(
              'liquid_glass_offset_y', (v) => (v as num?)?.toDouble() ?? 0.0),
        );
        return val;
      },
      fieldKeyMap: const {
        'imagePath': 'image_path',
        'roundedCorners': 'rounded_corners',
        'imagePathLiquidGlassIcon': 'image_path_liquid_glass_icon',
        'imagePathLiquidGlassIconDark': 'image_path_liquid_glass_icon_dark',
        'imagePathLiquidGlassIconTinted': 'image_path_liquid_glass_icon_tinted',
        'removeLiquidGlass': 'remove_liquid_glass',
        'backgroundColor': 'background_color',
        'liquidGlassIconScale': 'liquid_glass_icon_scale',
        'liquidGlassTranslucency': 'liquid_glass_translucency',
        'liquidGlassSpecular': 'liquid_glass_specular',
        'liquidGlassShadowKind': 'liquid_glass_shadow_kind',
        'liquidGlassShadowOpacity': 'liquid_glass_shadow_opacity',
        'liquidGlassBlur': 'liquid_glass_blur',
        'liquidGlassLighting': 'liquid_glass_lighting',
        'liquidGlassRefractivityEnabled': 'liquid_glass_refractivity_enabled',
        'liquidGlassRefractivityDepth': 'liquid_glass_refractivity_depth',
        'liquidGlassRefractivityStrength': 'liquid_glass_refractivity_strength',
        'liquidGlassSpecularHighlightPlacement':
            'liquid_glass_specular_highlight_placement',
        'liquidGlassOffsetX': 'liquid_glass_offset_x',
        'liquidGlassOffsetY': 'liquid_glass_offset_y'
      },
    );

Map<String, dynamic> _$MacOSConfigToJson(MacOSConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
      'padding': instance.padding,
      'rounded_corners': instance.roundedCorners,
      'image_path_liquid_glass_icon': instance.imagePathLiquidGlassIcon,
      'image_path_liquid_glass_icon_dark':
          instance.imagePathLiquidGlassIconDark,
      'image_path_liquid_glass_icon_tinted':
          instance.imagePathLiquidGlassIconTinted,
      'remove_liquid_glass': instance.removeLiquidGlass,
      'background_color': instance.backgroundColor,
      'liquid_glass_icon_scale': instance.liquidGlassIconScale,
      'liquid_glass_translucency': instance.liquidGlassTranslucency,
      'liquid_glass_specular': instance.liquidGlassSpecular,
      'liquid_glass_shadow_kind': instance.liquidGlassShadowKind,
      'liquid_glass_shadow_opacity': instance.liquidGlassShadowOpacity,
      'liquid_glass_blur': instance.liquidGlassBlur,
      'liquid_glass_lighting': instance.liquidGlassLighting,
      'liquid_glass_refractivity_enabled':
          instance.liquidGlassRefractivityEnabled,
      'liquid_glass_refractivity_depth': instance.liquidGlassRefractivityDepth,
      'liquid_glass_refractivity_strength':
          instance.liquidGlassRefractivityStrength,
      'liquid_glass_specular_highlight_placement':
          instance.liquidGlassSpecularHighlightPlacement,
      'liquid_glass_offset_x': instance.liquidGlassOffsetX,
      'liquid_glass_offset_y': instance.liquidGlassOffsetY,
    };
