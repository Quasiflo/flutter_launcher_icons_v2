import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:json_annotation/json_annotation.dart';

part 'android_config.g.dart';

/// The flutter_launcher_icons configuration set for Android
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class AndroidConfig {
  /// Specifies whether to generate icons for Android
  final bool generate;

  /// Image path for Android (falls back to the global `image_path`)
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Custom icon name (e.g. `"ic_launcher"`).
  ///
  /// When set, a new launcher icon is generated without removing the old
  /// default one. When `null`, the default existing icon is overridden.
  @JsonKey(name: 'icon_name')
  final String? iconName;

  /// Android min_sdk
  @JsonKey(name: 'min_sdk')
  final int minSdk;

  /// android adaptive_icon_foreground image
  @JsonKey(name: 'adaptive_icon_foreground')
  final String? adaptiveIconForeground;

  /// android adaptive_icon_foreground inset
  @JsonKey(name: 'adaptive_icon_foreground_inset')
  final int adaptiveIconForegroundInset;

  /// android adaptive_icon_background image
  @JsonKey(name: 'adaptive_icon_background')
  final String? adaptiveIconBackground;

  /// android adaptive_icon_monochrome image
  @JsonKey(name: 'adaptive_icon_monochrome')
  final String? adaptiveIconMonochrome;

  /// Creates a instance of [AndroidConfig]
  const AndroidConfig({
    this.generate = false,
    this.imagePath,
    this.iconName,
    this.minSdk = constants.androidDefaultAndroidMinSDK,
    this.adaptiveIconForeground,
    this.adaptiveIconForegroundInset = 16,
    this.adaptiveIconBackground,
    this.adaptiveIconMonochrome,
  });

  /// Creates [AndroidConfig] from [json]
  factory AndroidConfig.fromJson(Map<dynamic, dynamic> json) =>
      _$AndroidConfigFromJson(json);

  /// Creates [Map] from [AndroidConfig]
  Map<String, dynamic> toJson() => _$AndroidConfigToJson(this);

  @override
  String toString() => 'AndroidConfig: ${toJson()}';
}
