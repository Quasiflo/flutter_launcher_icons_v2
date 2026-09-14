import 'package:json_annotation/json_annotation.dart';

part 'ios_config.g.dart';

/// The launcher_icons configuration set for iOS
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class IOSConfig {
  /// Specifies whether to generate icons for iOS
  final bool generate;

  /// When true, generates only the single 1024px universal icon instead of
  /// the full icon set. Dark/tinted variants are ignored in this mode.
  @JsonKey(name: 'single_size')
  final bool singleSize;

  /// Image path for iOS (falls back to the global `image_path`)
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Custom icon set name.
  ///
  /// When set, a new launcher icon is generated without removing the old
  /// default one. When `null`, the default existing icon is overridden.
  @JsonKey(name: 'icon_name')
  final String? iconName;

  /// Custom path to the `.xcodeproj` directory (default
  /// `ios/Runner.xcodeproj`). Set this when the Xcode project was renamed.
  @JsonKey(name: 'xcodeproj_path')
  final String? xcodeprojPath;

  /// IOS image_path_dark_transparent
  @JsonKey(name: 'image_path_dark_transparent')
  final String? imagePathDarkTransparent;

  /// IOS image_path_tinted_grayscale
  @JsonKey(name: 'image_path_tinted_grayscale')
  final String? imagePathTintedGrayscale;

  /// IOS image_path_liquid_glass_icon
  @JsonKey(name: 'image_path_liquid_glass_icon')
  final String? imagePathLiquidGlassIcon;

  /// Liquid glass dark-appearance layer source.
  ///
  /// Falls back to `image_path_dark_transparent` when unset, so the dark
  /// app artwork is reused instead of requiring a second file.
  @JsonKey(name: 'image_path_liquid_glass_icon_dark')
  final String? imagePathLiquidGlassIconDark;

  /// Liquid glass tinted-appearance layer source.
  ///
  /// Falls back to `image_path_tinted_grayscale` when unset.
  @JsonKey(name: 'image_path_liquid_glass_icon_tinted')
  final String? imagePathLiquidGlassIconTinted;

  /// IOS remove_alpha
  @JsonKey(name: 'remove_alpha')
  final bool removeAlpha;

  /// IOS remove_liquid_glass
  @JsonKey(name: 'remove_liquid_glass')
  final bool removeLiquidGlass;

  /// IOS desaturate_tinted_to_grayscale
  @JsonKey(name: 'desaturate_tinted_to_grayscale')
  final bool desaturateTintedToGrayscale;

  /// IOS background_color
  @JsonKey(name: 'background_color')
  final String backgroundColor;

  /// IOS liquid_glass_icon_scale
  @JsonKey(name: 'liquid_glass_icon_scale')
  final double liquidGlassIconScale;

  /// IOS liquid glass translucency
  @JsonKey(name: 'liquid_glass_translucency')
  final double? liquidGlassTranslucency;

  /// IOS liquid glass specular
  @JsonKey(name: 'liquid_glass_specular')
  final bool liquidGlassSpecular;

  /// IOS liquid glass shadow kind
  @JsonKey(name: 'liquid_glass_shadow_kind')
  final String liquidGlassShadowKind;

  /// IOS liquid glass shadow opacity
  @JsonKey(name: 'liquid_glass_shadow_opacity')
  final double? liquidGlassShadowOpacity;

  /// IOS liquid glass blur
  @JsonKey(name: 'liquid_glass_blur')
  final double? liquidGlassBlur;

  /// IOS liquid glass offset X
  @JsonKey(name: 'liquid_glass_offset_x')
  final double? liquidGlassOffsetX;

  /// IOS liquid glass offset Y
  @JsonKey(name: 'liquid_glass_offset_y')
  final double? liquidGlassOffsetY;

  /// Creates a instance of [IOSConfig]
  const IOSConfig({
    this.generate = false,
    this.singleSize = false,
    this.imagePath,
    this.iconName,
    this.xcodeprojPath,
    this.imagePathDarkTransparent,
    this.imagePathTintedGrayscale,
    this.imagePathLiquidGlassIcon,
    this.imagePathLiquidGlassIconDark,
    this.imagePathLiquidGlassIconTinted,
    this.removeAlpha = false,
    this.removeLiquidGlass = false,
    this.desaturateTintedToGrayscale = false,
    this.backgroundColor = '#ffffff',
    this.liquidGlassIconScale = 1,
    this.liquidGlassTranslucency = 0.5,
    this.liquidGlassSpecular = true,
    this.liquidGlassShadowKind = 'Neutral',
    this.liquidGlassShadowOpacity = 0.5,
    this.liquidGlassBlur = 0.5,
    this.liquidGlassOffsetX = 0.0,
    this.liquidGlassOffsetY = 0.0,
  });

  /// Creates [IOSConfig] from [json]
  factory IOSConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$IOSConfigFromJson(json);

  /// Creates [Map] from [IOSConfig]
  Map<String, dynamic> toJson() => _$IOSConfigToJson(this);

  @override
  String toString() => 'IOSConfig: ${toJson()}';
}
