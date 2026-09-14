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

  /// Round the icon corners with an Apple-like mask (#463).
  ///
  /// Disabled by default; macOS does not shape the artwork itself.
  @JsonKey(name: 'rounded_corners')
  final bool roundedCorners;

  /// Creates a instance of [MacOSConfig]
  const MacOSConfig({
    this.generate = false,
    this.imagePath,
    this.padding = 0,
    this.roundedCorners = false,
  });

  /// Creates [WebConfig] from [json]
  factory MacOSConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$MacOSConfigFromJson(json);

  /// Creates [Map] from [WebConfig]
  Map<String, dynamic> toJson() => _$MacOSConfigToJson(this);

  @override
  String toString() => '$runtimeType: ${toJson()}';
}
