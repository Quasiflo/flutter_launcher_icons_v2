import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:flutter_launcher_icons/main.dart' show defaultConfigFile;
import 'package:flutter_launcher_icons/main.dart' as main_dart;
import 'package:path/path.dart' show join;
import 'package:test/test.dart';

// Unit tests for main.dart
void main() {
  test('iOS icon list is correct size', () {
    expect(ios.iosIcons.length, 16);
  });

  test('iOS legacy icon list is correct size', () {
    expect(ios.legacyIosIcons.length, 21);
  });

  test('Android icon list is correct size', () {
    expect(android.androidIcons.length, 5);
  });

  test(
      'iOS image list used to generate legacy Contents.json for icon directory is correct size (no dark or tinted icons)',
      () {
    expect(ios.createLegacyImageList('blah').length, 25);
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size (with dark icon)',
      () {
    expect(
      ios.createImageList('blah', 'dark-blah', null).length,
      16 * 2 + 1,
    ); // 16 normal, 16 dark icons + 1 marketing icon
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size (with tinted icon)',
      () {
    expect(
      ios.createImageList('blah', null, 'tinted-blah').length,
      16 * 2 + 1,
    ); // 16 normal, 16 tinted icons + 1 marketing icon
  });

  test(
      'iOS image list used to generate Contents.json for icon directory is correct size (with dark and tinted icon)',
      () {
    expect(
      ios.createImageList('blah', 'dark-blah', 'tinted-blah').length,
      16 * 3 + 1,
    ); // 16 normal, 16 dark, 16 tinted icons + 1 marketing icon
  });

  group('config file from args', () {
    // Create mini parser with only the wanted option, mocking the real one
    final ArgParser parser = ArgParser()
      ..addOption(
        main_dart.fileOption,
        abbr: 'f',
        defaultsTo: defaultConfigFile,
      )
      ..addOption(
        main_dart.prefixOption,
        abbr: 'p',
        defaultsTo: '.',
      );
    final String testDir =
        join('.dart_tool', 'flutter_launcher_icons', 'test', 'config_file');

    late String currentDirectory;
    Future<void> setCurrentDirectory(String path) async {
      path = join(testDir, path);
      await Directory(path).create(recursive: true);
      Directory.current = path;
    }

    setUp(() {
      currentDirectory = Directory.current.path;
    });
    tearDown(() {
      Directory.current = currentDirectory;
    });

    test('default', () async {
      await setCurrentDirectory('default');
      await File('flutter_launcher_icons.yaml').writeAsString('''
flutter_launcher_icons:
  android:
    generate: true
  ios:
    generate: false
''');
      final ArgResults argResults = parser.parse(<String>[]);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.androidConfig!.generate, isTrue);
    });
    test('default_use_pubspec', () async {
      await setCurrentDirectory('pubspec_only');
      await File('pubspec.yaml').writeAsString('''
flutter_launcher_icons:
  android:
    generate: true
  ios:
    generate: false
''');
      ArgResults argResults = parser.parse(<String>[]);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.iosConfig!.generate, isFalse);

      // read pubspec if provided file is not found
      argResults = parser.parse(<String>['-f', defaultConfigFile]);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNotNull);
    });

    group('stale template shadowing (#628)', () {
      Future<void> writeStaleYamlAndRealPubspec() async {
        await File('flutter_launcher_icons.yaml').writeAsString('''
flutter_launcher_icons:
  image_path: "assets/icon/icon.png"
  android:
    generate: true
''');
        await File('pubspec.yaml').writeAsString('''
flutter_launcher_icons:
  image_path: "real.png"
  android:
    generate: true
''');
        await File('real.png').writeAsBytes([0]);
      }

      test('prefers pubspec when default file is a stale template', () async {
        await setCurrentDirectory('stale_template');
        await writeStaleYamlAndRealPubspec();
        final ArgResults argResults = parser.parse(<String>[]);
        final Config? config =
            main_dart.loadConfigFileFromArgResults(argResults);
        expect(config, isNotNull);
        expect(config!.imagePath, equals('real.png'));
      });

      test('explicit -f still honors the given file', () async {
        await setCurrentDirectory('stale_template_explicit');
        await writeStaleYamlAndRealPubspec();
        final ArgResults argResults = parser.parse(
          <String>['-f', 'flutter_launcher_icons.yaml'],
        );
        final Config? config = main_dart.loadConfigFileFromArgResults(
          argResults,
          explicitFile: true,
        );
        expect(config, isNotNull);
        expect(config!.imagePath, equals('assets/icon/icon.png'));
      });

      test('prefers the file when its images exist', () async {
        await setCurrentDirectory('both_real');
        await File('flutter_launcher_icons.yaml').writeAsString('''
flutter_launcher_icons:
  image_path: "yaml.png"
  android:
    generate: true
''');
        await File('pubspec.yaml').writeAsString('''
flutter_launcher_icons:
  image_path: "real.png"
  android:
    generate: true
''');
        await File('yaml.png').writeAsBytes([0]);
        await File('real.png').writeAsBytes([0]);
        final ArgResults argResults = parser.parse(<String>[]);
        final Config? config =
            main_dart.loadConfigFileFromArgResults(argResults);
        expect(config, isNotNull);
        expect(config!.imagePath, equals('yaml.png'));
      });
    });

    test('custom', () async {      await setCurrentDirectory('custom');
      await File('custom.yaml').writeAsString('''
flutter_launcher_icons:
  android:
    generate: true
  ios:
    generate: true
''');
      // if no argument set, should fail
      ArgResults argResults = parser.parse(<String>['-f', 'custom.yaml']);
      final Config? config = main_dart.loadConfigFileFromArgResults(argResults);
      expect(config, isNotNull);
      expect(config!.iosConfig!.generate, isTrue);

      // should fail if no argument
      argResults = parser.parse(<String>[]);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNull);

      // or missing file
      argResults = parser.parse(<String>['-f', 'missing_custom.yaml']);
      expect(main_dart.loadConfigFileFromArgResults(argResults), isNull);
    });
  });

  group('explicit flavor from args', () {
    final ArgParser parser = ArgParser()
      ..addOption(
        main_dart.fileOption,
        abbr: 'f',
        defaultsTo: defaultConfigFile,
      );

    test('returns null when -f is not given', () {
      expect(
        main_dart.explicitFlavorFromArgs(parser.parse(<String>[])),
        isNull,
      );
    });

    test('returns null when -f names the default config file', () {
      expect(
        main_dart.explicitFlavorFromArgs(
          parser.parse(<String>['-f', defaultConfigFile]),
        ),
        isNull,
      );
    });

    test('returns null when -f names a non-flavor file', () {
      expect(
        main_dart.explicitFlavorFromArgs(
          parser.parse(<String>['-f', 'custom.yaml']),
        ),
        isNull,
      );
    });

    test('returns the flavor when -f names a flavor file', () {
      expect(
        main_dart.explicitFlavorFromArgs(
          parser.parse(<String>['-f', 'flutter_launcher_icons-staging.yaml']),
        ),
        equals('staging'),
      );
    });

    test('matches flavor files in subdirectories by basename', () {
      expect(
        main_dart.explicitFlavorFromArgs(
          parser
              .parse(<String>['-f', 'config/flutter_launcher_icons-prod.yaml']),
        ),
        equals('prod'),
      );
    });
  });

  group('isFileOptionExplicit', () {
    test('is false when -f is absent', () {
      expect(main_dart.isFileOptionExplicit([]), isFalse);
      expect(main_dart.isFileOptionExplicit(['-v']), isFalse);
    });

    test('detects -f, --file and --file= forms', () {
      expect(main_dart.isFileOptionExplicit(['-f', 'x.yaml']), isTrue);
      expect(main_dart.isFileOptionExplicit(['--file', 'x.yaml']), isTrue);
      expect(main_dart.isFileOptionExplicit(['--file=x.yaml']), isTrue);
    });
  });

  test('image_path is in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': {'generate': true},
      'ios': {'generate': true},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(
      config.getImagePathAndroid(),
      equals('assets/images/icon-710x599.png'),
    );
    expect(config.getImagePathIOS(), equals('assets/images/icon-710x599.png'));
    final Map<String, dynamic> flutterIconsConfigAndroid = <String, dynamic>{
      'android': {
        'generate': true,
        'image_path': 'assets/images/icon-710x599.png',
      },
      'ios': {'generate': true},
    };
    final configAndroid = Config.fromJson(flutterIconsConfigAndroid);
    expect(
      configAndroid.getImagePathAndroid(),
      equals('assets/images/icon-710x599.png'),
    );
    expect(configAndroid.getImagePathIOS(), isNull);
    final Map<String, dynamic> flutterIconsConfigBoth = <String, dynamic>{
      'android': {
        'generate': true,
        'image_path': 'assets/images/icon-android.png',
      },
      'ios': {
        'generate': true,
        'image_path': 'assets/images/icon-ios.png',
      },
    };
    final configBoth = Config.fromJson(flutterIconsConfigBoth);
    expect(
      configBoth.getImagePathAndroid(),
      equals('assets/images/icon-android.png'),
    );
    expect(configBoth.getImagePathIOS(), equals('assets/images/icon-ios.png'));
  });

  test('At least one platform is in config file', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': {'generate': true},
      'ios': {'generate': true},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, isTrue);
  });

  test('No platform specified in config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.hasPlatformConfig, isFalse);
  });

  test('No new Android icon needed - android.generate: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': {'generate': false},
      'ios': {'generate': true},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, isFalse);
  });

  test('No new Android icon needed - no Android config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'ios': {'generate': true},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewAndroidIcon, isFalse);
  });

  test('No new iOS icon needed - ios.generate: false', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': {'generate': true},
      'ios': {'generate': false},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, isFalse);
  });

  test('No new iOS icon needed - no iOS config', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': {'generate': true},
    };
    final config = Config.fromJson(flutterIconsConfig);
    expect(config.isNeedingNewIOSIcon, isFalse);
  });

  group('v3 schema migration guard', () {
    test('legacy boolean android/ios values throw a migration error', () {
      expect(
        () => Config.fromJson(<String, dynamic>{
          'image_path': 'assets/images/icon-710x599.png',
          'android': true,
          'ios': true,
        }),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    test('legacy string android/ios values throw a migration error', () {
      expect(
        () => Config.fromJson(<String, dynamic>{
          'image_path': 'assets/images/icon-710x599.png',
          'android': 'launcher_icon',
          'ios': 'MyIcon',
        }),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    test('nested android/ios maps parse without migration error', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path': 'assets/images/icon-710x599.png',
        'android': {'generate': true},
        'ios': {'generate': true},
      });
      expect(config.isNeedingNewAndroidIcon, isTrue);
      expect(config.isNeedingNewIOSIcon, isTrue);
    });
  });
}
