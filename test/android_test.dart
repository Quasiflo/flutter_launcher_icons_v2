import 'dart:io';

import 'package:flutter_launcher_icons/android.dart' as android;
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// unit tests for android.dart
void main() {
  test('Adaptive icon mipmap path is correct', () {
    const String path1 = 'android/app/src/main/res/';
    const String path2 = 'mipmap-anydpi-v26/';
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path1), false);
    expect(android.isCorrectMipmapDirectoryForAdaptiveIcon(path2), false);
    expect(
      android.isCorrectMipmapDirectoryForAdaptiveIcon(
        androidAdaptiveXmlFolder(null),
      ),
      true,
    );
  });

  test('Adaptive icon background image paths are detected', () {
    expect(android.isAdaptiveIconConfigImageFile('assets/background.png'), isTrue);
    expect(android.isAdaptiveIconConfigImageFile('assets/background.PNG'), isTrue);
    expect(android.isAdaptiveIconConfigImageFile('assets/background.jpg'), isTrue);
    expect(android.isAdaptiveIconConfigImageFile('assets/background.JPG'), isTrue);
    expect(
      android.isAdaptiveIconConfigImageFile('assets/background.jpeg'),
      isTrue,
    );
    expect(
      android.isAdaptiveIconConfigImageFile('assets/background.Jpeg'),
      isTrue,
    );
    expect(
      android.isAdaptiveIconConfigImageFile('assets/background.webp'),
      isTrue,
    );
    expect(
      android.isAdaptiveIconConfigImageFile('assets/background.WEBP'),
      isTrue,
    );
    expect(android.isAdaptiveIconConfigImageFile('#ffffff'), isFalse);
  });

  group('adaptive icon background generation', () {
    late String originalDir;
    late String sandboxDir;

    setUp(() {
      originalDir = Directory.current.path;
      sandboxDir = path.join(
        '.dart_tool',
        'flutter_launcher_icons',
        'test',
        'android_adaptive',
      );
      final sandbox = Directory(sandboxDir);
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
      sandbox.createSync(recursive: true);
      File(path.join(originalDir, 'test', 'assets', 'app_icon.png'))
          .copySync(path.join(sandboxDir, 'app_icon.png'));
      File(path.join(originalDir, 'test', 'assets', 'background.jpg'))
          .copySync(path.join(sandboxDir, 'background.jpg'));
      File(path.join(originalDir, 'test', 'assets', 'background.webp'))
          .copySync(path.join(sandboxDir, 'background.webp'));
      Directory.current = sandboxDir;
    });

    tearDown(() {
      Directory.current = originalDir;
    });

    String backgroundPngPath(android.AndroidIconTemplate template) => path.join(
          'android',
          'app',
          'src',
          'main',
          'res',
          template.directoryName,
          androidAdaptiveBackgroundFileName,
        );

    test('jpg background generates background PNGs and @drawable mipmap',
        () async {
      final config = Config.fromJson(<String, dynamic>{
        'android': true,
        'adaptive_icon_background': 'background.jpg',
        'adaptive_icon_foreground': 'app_icon.png',
      });

      await android.createAdaptiveIcons(config, null);

      for (final template in android.adaptiveForegroundIcons) {
        expect(
          File(backgroundPngPath(template)).existsSync(),
          isTrue,
          reason: backgroundPngPath(template),
        );
      }
      expect(
        File(androidColorsFile(null)).existsSync(),
        isFalse,
        reason: 'colors.xml should not be written for an image background',
      );

      await android.createMipmapXmlFile(config, null);
      final mipmapXml = File(
        path.join(androidAdaptiveXmlFolder(null), androidDefaultIconName) +
            '.xml',
      ).readAsStringSync();
      expect(mipmapXml, contains('@drawable/ic_launcher_background'));
    });

    test('webp background generates background PNGs', () async {
      final config = Config.fromJson(<String, dynamic>{
        'android': true,
        'adaptive_icon_background': 'background.webp',
        'adaptive_icon_foreground': 'app_icon.png',
      });

      await android.createAdaptiveIcons(config, null);

      for (final template in android.adaptiveForegroundIcons) {
        expect(
          File(backgroundPngPath(template)).existsSync(),
          isTrue,
          reason: backgroundPngPath(template),
        );
      }
    });

    test('hex color background writes colors.xml and @color mipmap', () async {
      final config = Config.fromJson(<String, dynamic>{
        'android': true,
        'adaptive_icon_background': '#ffffff',
        'adaptive_icon_foreground': 'app_icon.png',
      });

      await android.createAdaptiveIcons(config, null);

      final colorsFile = File(androidColorsFile(null));
      expect(colorsFile.existsSync(), isTrue);
      expect(colorsFile.readAsStringSync(), contains('#ffffff'));
      expect(
        File(backgroundPngPath(android.adaptiveForegroundIcons.first))
            .existsSync(),
        isFalse,
        reason: 'colors should not produce background PNGs',
      );

      await android.createMipmapXmlFile(config, null);
      final mipmapXml = File(
        path.join(androidAdaptiveXmlFolder(null), androidDefaultIconName) +
            '.xml',
      ).readAsStringSync();
      expect(mipmapXml, contains('@color/ic_launcher_background'));
    });
  });

  test('Correct number of adaptive foreground icons', () {
    expect(android.adaptiveForegroundIcons.length, 5);
  });

  test('Correct number of android launcher icons', () {
    expect(android.androidIcons.length, 5);
  });

  test('Config contains string for generating new launcher icons', () {
    final Map<String, dynamic> flutterIconsConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': true,
      'ios': true,
    };
    expect(
      Config.fromJson(flutterIconsConfig).isCustomAndroidFile,
      isFalse,
    );

    final Map<String, dynamic> flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'android': 'New Icon',
      'ios': true,
    };
    expect(
      Config.fromJson(flutterIconsNewIconConfig).isCustomAndroidFile,
      isTrue,
    );
  });

  test('Prioritise image_path_android over image_path', () {
    final Map<String, dynamic> flutterIconsNewIconConfig = <String, dynamic>{
      'image_path': 'assets/images/icon-710x599.png',
      'image_path_android': 'assets/images/icon-android.png',
      'android': 'New Icon',
      'ios': true,
    };
    expect(
      Config.fromJson(flutterIconsNewIconConfig).getImagePathAndroid(),
      equals('assets/images/icon-android.png'),
    );
  });

  test('Transforming manifest without icon must add icon', () async {
    final String inputManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"');
    final String expectedManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_other_icon_name"');

    await withTempFile('AndroidManifest.xml', (File androidManifestFile) async {
      androidManifestFile.writeAsStringSync(inputManifest);
      await android.overwriteAndroidManifestWithNewLauncherIcon(
        'ic_other_icon_name',
        androidManifestFile,
      );
      expect(androidManifestFile.readAsStringSync(), equals(expectedManifest));
    });
  });

  test(
      'Transforming manifest with icon already in place should leave it unchanged',
      () async {
    final String inputManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"');
    final String expectedManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"');

    await withTempFile('AndroidManifest.xml', (File androidManifestFile) async {
      androidManifestFile.writeAsStringSync(inputManifest);
      await android.overwriteAndroidManifestWithNewLauncherIcon(
        'ic_launcher',
        androidManifestFile,
      );
      expect(androidManifestFile.readAsStringSync(), equals(expectedManifest));
    });
  });

  test(
      'Transforming manifest with trailing newline should keep newline untouched',
      () async {
    final String inputManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"') + '\n';
    final String expectedManifest = inputManifest;

    await withTempFile('AndroidManifest.xml', (File androidManifestFile) async {
      androidManifestFile.writeAsStringSync(inputManifest);
      await android.overwriteAndroidManifestWithNewLauncherIcon(
        'ic_launcher',
        androidManifestFile,
      );
      expect(androidManifestFile.readAsStringSync(), equals(expectedManifest));
    });
  });

  test(
      'Transforming manifest with 3 trailing newlines should keep newlines untouched',
      () async {
    final String inputManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"') +
            '\n\n\n';
    final String expectedManifest = inputManifest;

    await withTempFile('AndroidManifest.xml', (File androidManifestFile) async {
      androidManifestFile.writeAsStringSync(inputManifest);
      await android.overwriteAndroidManifestWithNewLauncherIcon(
        'ic_launcher',
        androidManifestFile,
      );
      expect(androidManifestFile.readAsStringSync(), equals(expectedManifest));
    });
  });

  test(
      'Transforming manifest with special newline characters should leave special newline characters untouched',
      () async {
    final String inputManifest =
        getAndroidManifestExample('android:icon="@mipmap/ic_launcher"')
            .replaceAll('\n', '\r\n');
    final String expectedManifest = inputManifest;

    await withTempFile('AndroidManifest.xml', (File androidManifestFile) async {
      androidManifestFile.writeAsStringSync(inputManifest);
      await android.overwriteAndroidManifestWithNewLauncherIcon(
        'ic_launcher',
        androidManifestFile,
      );
      expect(androidManifestFile.readAsStringSync(), equals(expectedManifest));
    });
  });
}

Future<void> withTempFile(String fileName, Function block) async {
  final Directory tempDir = Directory.systemTemp.createTempSync();
  final File file = File('${tempDir.path}/$fileName')..createSync();
  if (!file.existsSync()) {
    fail('Could not create temp test file ${file.path}');
  }
  try {
    await block(file);
  } finally {
    file.deleteSync();
  }
}

String getAndroidManifestExample(String iconLine) {
  return '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapplication">

    <application
        android:allowBackup="true"
        $iconLine
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
        <activity
            android:name=".MainActivity"
            android:label="@string/app_name"
            android:theme="@style/AppTheme.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
  '''
      .trim();
}
