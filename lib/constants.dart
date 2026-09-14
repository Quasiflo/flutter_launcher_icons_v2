// ignore_for_file: public_member_api_docs

import 'package:path/path.dart' as path;

/// Relative path to android resource folder
String androidResFolder(String? flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/";

/// Relative path to android colors.xml file
String androidColorsFile(String? flavor) =>
    "android/app/src/${flavor ?? 'main'}/res/values/colors.xml";

const String androidManifestFile = 'android/app/src/main/AndroidManifest.xml';
const String androidFileName = 'ic_launcher.png';
const String androidAdaptiveForegroundFileName = 'ic_launcher_foreground.png';
const String androidAdaptiveBackgroundFileName = 'ic_launcher_background.png';
const String androidAdaptiveMonochromeFileName = 'ic_launcher_monochrome.png';
String androidAdaptiveXmlFolder(String? flavor) =>
    androidResFolder(flavor) + 'mipmap-anydpi-v26/';
const String androidDefaultIconName = 'ic_launcher';

const String iosDefaultIconFolder =
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/';
const String iosAssetFolder = 'ios/Runner/Assets.xcassets/';
const String iosConfigFile = 'ios/Runner.xcodeproj/project.pbxproj';
const String iosDefaultIconName = 'Icon-App';

// iOS Liquid Glass .icon constants
const String iosRunnerFolder = 'ios/Runner/';
String iosLiquidGlassIconPath(String iconName) =>
    '$iosRunnerFolder$iconName.icon/';
String iosLiquidGlassAssetsPath(String iconName) =>
    '${iosLiquidGlassIconPath(iconName)}Assets/';
String iosLiquidGlassConfigPath(String iconName) =>
    '${iosLiquidGlassIconPath(iconName)}icon.json';

// web
/// favicon.ico size
const int kFaviconSize = 16;

/// Relative web direcotry path
String webDirPath = path.join('web');

/// Relative web icons directory path
String webIconsDirPath = path.join(webDirPath, 'icons');

/// Relative web manifest.json file path
String webManifestFilePath = path.join(webDirPath, 'manifest.json');
// TODO(RatakondalaArun): support for other images formats
/// Relative favicon.png path
String webFaviconFilePath = path.join(webDirPath, 'favicon.png');

/// Relative favicon.ico path (browsers request /favicon.ico by default)
String webFaviconIcoFilePath = path.join(webDirPath, 'favicon.ico');

/// Relative index.html file path
String webIndexFilePath = path.join(webDirPath, 'index.html');

/// Relative pubspec.yaml path
String pubspecFilePath = path.join('pubspec.yaml');

// Windows
/// Relative path to windows directory
String windowsDirPath = path.join('windows');

/// Relative path to windows resources directory
String windowsResourcesDirPath =
    path.join(windowsDirPath, 'runner', 'resources');

/// Relative path to windows icon file path
String windowsIconFilePath = path.join(windowsResourcesDirPath, 'app_icon.ico');

// MacOS

/// Relative path to macos folder
final macOSDirPath = path.join('macos');

/// Relative path to macos icons folder
final macOSIconsDirPath =
    path.join(macOSDirPath, 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');

/// Relative path to macos contents.json
final macOSContentsFilePath = path.join(macOSIconsDirPath, 'Contents.json');

// Linux

/// Relative path to linux directory
String linuxDirPath = path.join('linux');

/// Relative path to linux my_application.cc file
String linuxMyApplicationFile =
    path.join(linuxDirPath, 'runner', 'my_application.cc');

const String errorMissingImagePath =
    'Missing "image_path" or "image_path_android" + "image_path_ios" within configuration';
const String errorMissingPlatform =
    'No platform specified within config to generate icons for.';
const String errorNoPlatformEnabled =
    'No platform enabled within config to generate icons for. '
    'Set "generate: true" for at least one platform.';
const String errorIncorrectIconName =
    'The icon name must contain only lowercase a-z, 0-9, or underscore: '
    'E.g. "ic_my_new_icon"';

String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     LAUNCHER ICONS (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';
