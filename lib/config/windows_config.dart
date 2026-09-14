import 'package:json_annotation/json_annotation.dart';

part 'windows_config.g.dart';

/// The launcher_icons configuration set for Windows
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class WindowsConfig {
  /// Specifies whether to generate icons for Windows
  final bool generate;

  /// Image path for Windows
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Creates a instance of [WindowsConfig]
  const WindowsConfig({
    this.generate = false,
    this.imagePath,
  });

  /// Creates [WindowsConfig] from [json]
  factory WindowsConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$WindowsConfigFromJson(json);

  /// Creates [Map] from [WindowsConfig]
  Map<String, dynamic> toJson() => _$WindowsConfigToJson(this);

  @override
  String toString() => 'WindowsConfig: ${toJson()}';
}
