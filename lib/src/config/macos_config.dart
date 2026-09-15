import 'package:json_annotation/json_annotation.dart';

part 'macos_config.g.dart';

/// The launcher_icons configuration set for MacOS
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class MacOSConfig {
  /// Specifies weather to generate icons for macos
  @JsonKey()
  final bool generate;

  /// Image path for macos
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Safe-area margin as a percent of the icon size applied on every side.
  ///
  /// The artwork is scaled into the remaining inner area and centered on a
  /// transparent canvas. `0` (default) disables padding.
  @JsonKey(name: 'padding')
  final int padding;

  /// Round the icon corners with an Apple-like mask (fluttercommunity/flutter_launcher_icons#463).
  ///
  /// Disabled by default; macOS does not shape the artwork itself.
  @JsonKey(name: 'rounded_corners')
  final bool roundedCorners;

  /// macOS image_path_liquid_glass_icon.
  ///
  /// Enables the liquid glass `.icon` bundle (macOS Tahoe 26+ renders live
  /// glass from it via Icon Composer's format; the PNG catalog stays the
  /// fallback on older systems). Sources pass through verbatim, so SVGs work.
  @JsonKey(name: 'image_path_liquid_glass_icon')
  final String? imagePathLiquidGlassIcon;

  /// Liquid glass dark-appearance layer source (no fallback: macOS has no
  /// dark PNG catalog variant to reuse).
  @JsonKey(name: 'image_path_liquid_glass_icon_dark')
  final String? imagePathLiquidGlassIconDark;

  /// Liquid glass tinted-appearance layer source (no fallback: macOS has no
  /// tinted PNG catalog variant to reuse).
  @JsonKey(name: 'image_path_liquid_glass_icon_tinted')
  final String? imagePathLiquidGlassIconTinted;

  /// macOS remove_liquid_glass: flat icon without glass effects.
  @JsonKey(name: 'remove_liquid_glass')
  final bool removeLiquidGlass;

  /// macOS background_color: canvas fill behind the glass (hex `#RRGGBB`).
  @JsonKey(name: 'background_color')
  final String backgroundColor;

  /// macOS liquid_glass_icon_scale
  @JsonKey(name: 'liquid_glass_icon_scale')
  final double liquidGlassIconScale;

  /// macOS liquid glass translucency
  @JsonKey(name: 'liquid_glass_translucency')
  final double? liquidGlassTranslucency;

  /// macOS liquid glass specular
  @JsonKey(name: 'liquid_glass_specular')
  final bool liquidGlassSpecular;

  /// macOS liquid glass shadow kind (`Neutral` or `Chromatic`)
  @JsonKey(name: 'liquid_glass_shadow_kind')
  final String liquidGlassShadowKind;

  /// macOS liquid glass shadow opacity
  @JsonKey(name: 'liquid_glass_shadow_opacity')
  final double? liquidGlassShadowOpacity;

  /// macOS liquid glass blur
  @JsonKey(name: 'liquid_glass_blur')
  final double? liquidGlassBlur;

  /// Group lighting model: `individual` or `combined`. Unset by default
  /// (omitted from icon.json); only observable with 2+ layers.
  @JsonKey(name: 'liquid_glass_lighting')
  final String? liquidGlassLighting;

  /// Enables group refractivity (`depth` + `strength` required).
  @JsonKey(name: 'liquid_glass_refractivity_enabled')
  final bool? liquidGlassRefractivityEnabled;

  /// Refractivity depth (required when refractivity is enabled).
  @JsonKey(name: 'liquid_glass_refractivity_depth')
  final double? liquidGlassRefractivityDepth;

  /// Refractivity strength (required when refractivity is enabled).
  @JsonKey(name: 'liquid_glass_refractivity_strength')
  final double? liquidGlassRefractivityStrength;

  /// Specular highlight placement: `inside` or `outside`. Unset by default.
  @JsonKey(name: 'liquid_glass_specular_highlight_placement')
  final String? liquidGlassSpecularHighlightPlacement;

  /// macOS liquid glass offset X
  @JsonKey(name: 'liquid_glass_offset_x')
  final double? liquidGlassOffsetX;

  /// macOS liquid glass offset Y
  @JsonKey(name: 'liquid_glass_offset_y')
  final double? liquidGlassOffsetY;

  /// Creates a instance of [MacOSConfig]
  const MacOSConfig({
    this.generate = false,
    this.imagePath,
    this.padding = 0,
    this.roundedCorners = false,
    this.imagePathLiquidGlassIcon,
    this.imagePathLiquidGlassIconDark,
    this.imagePathLiquidGlassIconTinted,
    this.removeLiquidGlass = false,
    this.backgroundColor = '#ffffff',
    this.liquidGlassIconScale = 1,
    this.liquidGlassTranslucency = 0.5,
    this.liquidGlassSpecular = true,
    this.liquidGlassShadowKind = 'Neutral',
    this.liquidGlassShadowOpacity = 0.5,
    this.liquidGlassBlur = 0.5,
    this.liquidGlassLighting,
    this.liquidGlassRefractivityEnabled,
    this.liquidGlassRefractivityDepth,
    this.liquidGlassRefractivityStrength,
    this.liquidGlassSpecularHighlightPlacement,
    this.liquidGlassOffsetX = 0.0,
    this.liquidGlassOffsetY = 0.0,
  });

  /// Creates [MacOSConfig] from [json]
  factory MacOSConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$MacOSConfigFromJson(json);

  /// Creates [Map] from [WebConfig]
  Map<String, dynamic> toJson() => _$MacOSConfigToJson(this);

  @override
  String toString() => '$runtimeType: ${toJson()}';
}
