import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:json_annotation/json_annotation.dart';

part 'web_config.g.dart';

/// The flutter_launcher_icons configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class WebConfig {
  /// Specifies weather to generate icons for web
  final bool generate;

  /// Image path for web
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Override image path for favicon
  @JsonKey(name: 'image_path_favicon')
  final String? imagePathFavicon;

  /// Output directory for web icons (default `web`).
  ///
  /// Lets flavors (or custom setups) target different web roots, e.g.
  /// `output_path: web_prod`.
  @JsonKey(name: 'output_path')
  final String outputPath;

  /// Favicon size in pixels (default 16, the `kFaviconSize` default).
  @JsonKey(name: 'favicon_size')
  final int faviconSize;

  /// manifest.json's background_color
  @JsonKey(name: 'background_color')
  final String? backgroundColor;

  /// manifest.json's theme_color
  @JsonKey(name: 'theme_color')
  final String? themeColor;

  /// Creates an instance of [WebConfig]
  const WebConfig({
    this.generate = false,
    this.imagePath,
    this.imagePathFavicon,
    this.faviconSize = constants.kFaviconSize,
    this.outputPath = 'web',
    this.backgroundColor,
    this.themeColor,
  });

  /// Creates [WebConfig] from [json]
  factory WebConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$WebConfigFromJson(json);

  /// Creates [Map] from [WebConfig]
  Map<String, dynamic> toJson() => _$WebConfigToJson(this);

  @override
  String toString() => 'WebConfig: ${toJson()}';
}
