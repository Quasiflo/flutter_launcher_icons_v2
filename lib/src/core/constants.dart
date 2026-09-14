// Project-relative path builders live in paths.dart and shared error
// strings in errors.dart; both are re-exported here so existing
// `constants.X` references keep working. New code should import
// `paths.dart` / `errors.dart` directly.
export 'errors.dart';
export 'paths.dart';

/// Default Android legacy icon file name
const String androidFileName = 'ic_launcher.png';

/// Default Android adaptive foreground file name
const String androidAdaptiveForegroundFileName = 'ic_launcher_foreground.png';

/// Default Android adaptive background file name
const String androidAdaptiveBackgroundFileName = 'ic_launcher_background.png';

/// Default Android adaptive monochrome file name
const String androidAdaptiveMonochromeFileName = 'ic_launcher_monochrome.png';

/// Default Android adaptive round drawable file name
const String androidAdaptiveRoundFileName = 'ic_launcher_round.png';

/// Default Android adaptive round icon resource name
const String androidAdaptiveRoundIconName = 'ic_launcher_round';

/// Play Store upload sidecar, written next to the project (never res/).
const String androidPlayStoreIconFile = 'play_store_icon.png';

/// Default Android icon resource name
const String androidDefaultIconName = 'ic_launcher';

/// Default iOS icon file name prefix
const String iosDefaultIconName = 'Icon-App';

/// favicon.ico size
const int kFaviconSize = 16;

/// CLI banner with the current package version.
String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     LAUNCHER ICONS (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';
