import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart' as yaml;
import 'package:flutter_launcher_icons/config/android_config.dart';
import 'package:flutter_launcher_icons/config/ios_config.dart';
import 'package:flutter_launcher_icons/config/linux_config.dart';
import 'package:flutter_launcher_icons/config/macos_config.dart';
import 'package:flutter_launcher_icons/config/web_config.dart';
import 'package:flutter_launcher_icons/config/windows_config.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

part 'config.g.dart';

/// A model representing the flutter_launcher_icons configuration
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class Config {
  /// Creates an instance of [Config]
  const Config({
    this.imagePath,
    this.androidConfig,
    this.iosConfig,
    this.webConfig,
    this.windowsConfig,
    this.macOSConfig,
    this.linuxConfig,
  });

  /// Creates [Config] for given [flavor] and [prefixPath]
  static Config? loadConfigFromFlavor(
    String flavor,
    String prefixPath,
  ) {
    return _getConfigFromPubspecYaml(
      prefix: prefixPath,
      pathToPubspecYamlFile: utils.flavorConfigFile(flavor),
    );
  }

  /// Loads flutter launcher icons configs from given [filePath]
  static Config? loadConfigFromPath(String filePath, String prefixPath) {
    return _getConfigFromPubspecYaml(
      prefix: prefixPath,
      pathToPubspecYamlFile: filePath,
    );
  }

  /// Loads flutter launcher icons config from `pubspec.yaml` file
  static Config? loadConfigFromPubSpec(String prefix) {
    return _getConfigFromPubspecYaml(
      prefix: prefix,
      pathToPubspecYamlFile: constants.pubspecFilePath,
    );
  }

  static Config? _getConfigFromPubspecYaml({
    required String pathToPubspecYamlFile,
    required String prefix,
  }) {
    final configFile = File(path.join(prefix, pathToPubspecYamlFile));
    if (!configFile.existsSync()) {
      return null;
    }
    final configContent = configFile.readAsStringSync();
    try {
      return yaml.checkedYamlDecode<Config?>(
        configContent,
        (Map<dynamic, dynamic>? json) {
          if (json != null) {
            // if we have flutter_icons configuration ...
            if (json['flutter_icons'] != null) {
              stderr.writeln('\n⚠ Warning: flutter_icons has been deprecated '
                  'please use flutter_launcher_icons instead in your yaml files');
              return Config.fromJson(json['flutter_icons']);
            }
            // if we have flutter_launcher_icons configuration ...
            if (json['flutter_launcher_icons'] != null) {
              return Config.fromJson(json['flutter_launcher_icons']);
            }
          }
          return null;
        },
        allowNull: true,
      );
    } on yaml.ParsedYamlException catch (e) {
      throw InvalidConfigException(e.formattedMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Generic image_path
  @JsonKey(name: 'image_path')
  final String? imagePath;

  /// Android platform config
  @JsonKey(name: 'android')
  final AndroidConfig? androidConfig;

  /// iOS platform config
  @JsonKey(name: 'ios')
  final IOSConfig? iosConfig;

  /// Web platform config
  @JsonKey(name: 'web')
  final WebConfig? webConfig;

  /// Windows platform config
  @JsonKey(name: 'windows')
  final WindowsConfig? windowsConfig;

  /// MacOS platform config
  @JsonKey(name: 'macos')
  final MacOSConfig? macOSConfig;

  /// Linux platform config
  @JsonKey(name: 'linux')
  final LinuxConfig? linuxConfig;

  /// Creates [Config] icons from [json]
  ///
  /// The v2 (flat `android:`/`ios:`) schema was removed in v3. A legacy
  /// boolean or string value produces a migration error instead of being
  /// silently ignored.
  factory Config.fromJson(Map<dynamic, dynamic> json) {
    for (final key in ['android', 'ios']) {
      final value = json[key];
      if (value is bool || value is String) {
        throw InvalidConfigException(
          'Invalid `$key` value `$value`. Since v3, `$key` must be a map '
          'with `generate: true` (e.g. `$key:\n    generate: true`). '
          'See the README for the new schema.',
        );
      }
    }
    return _$ConfigFromJson(json);
  }

  /// whether or not there is configuration for adaptive icons for android
  bool get hasAndroidAdaptiveConfig =>
      isNeedingNewAndroidIcon &&
      androidConfig?.adaptiveIconForeground != null &&
      androidConfig?.adaptiveIconBackground != null;

  /// whether or not there is configuration for monochrome icons for android
  bool get hasAndroidAdaptiveMonochromeConfig {
    return isNeedingNewAndroidIcon &&
        androidConfig?.adaptiveIconMonochrome != null;
  }

  /// Checks if contains any platform config
  bool get hasPlatformConfig {
    return androidConfig != null ||
        iosConfig != null ||
        webConfig != null ||
        windowsConfig != null ||
        macOSConfig != null ||
        linuxConfig != null;
  }

  /// Whether or not configuration for generating Android icons exist
  bool get hasAndroidConfig => androidConfig != null;

  /// Whether or not configuration for generating iOS icons exist
  bool get hasIOSConfig => iosConfig != null;

  /// Whether or not configuration for generating Web icons exist
  bool get hasWebConfig => webConfig != null;

  /// Whether or not configuration for generating Windows icons exist
  bool get hasWindowsConfig => windowsConfig != null;

  /// Whether or not configuration for generating MacOS icons exists
  bool get hasMacOSConfig => macOSConfig != null;

  /// Whether or not configuration for generating Linux icons exists
  bool get hasLinuxConfig => linuxConfig != null;

  /// Check to see if a custom Android icon name was specified via `icon_name`.
  /// When set, a new launcher icon is generated without removing the old
  /// default existing Flutter launcher icon.
  bool get isCustomAndroidFile => androidConfig?.iconName != null;

  /// if we are needing a new Android icon
  bool get isNeedingNewAndroidIcon => androidConfig?.generate ?? false;

  /// if we are needing a new iOS icon
  bool get isNeedingNewIOSIcon => iosConfig?.generate ?? false;

  /// Whether or not configuration for generating liquid glass .icon exists
  bool get hasLiquidGlassIconConfig =>
      iosConfig?.imagePathLiquidGlassIcon != null;

  /// Method for the retrieval of the Android icon path
  /// If android.image_path is found, this will be prioritised over the image_path
  /// value.
  String? getImagePathAndroid() => androidConfig?.imagePath ?? imagePath;

  /// get the image path for IOS
  String? getImagePathIOS() => iosConfig?.imagePath ?? imagePath;

  /// Converts config to [Map]
  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  @override
  String toString() => 'FlutterLauncherIconsConfig: ${toJson()}';
}
