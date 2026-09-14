import 'dart:io';

import 'package:launcher_icons/config/config.dart';
import 'package:launcher_icons/custom_exceptions.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Suffixed `launcher_icons-<flavor>:` top-level sections: discovery via
// Config.loadFlavorConfigsFromPath.
void main() {
  group('loadFlavorConfigsFromPath', () {
    late String dir;

    setUp(() async {
      dir = (await Directory.systemTemp.createTemp('flavor_keys')).path;
    });

    tearDown(() async {
      await Directory(dir).delete(recursive: true);
    });

    Future<Map<String, Config>> load(String content) async {
      await File(path.join(dir, 'pubspec.yaml')).writeAsString(content);
      return Config.loadFlavorConfigsFromPath('pubspec.yaml', dir);
    }

    test('parses suffixed sections keyed by flavor', () async {
      final flavors = await load('''
launcher_icons:
  image_path: "base.png"
flutter:
  uses-material-design: true
launcher_icons-development:
  image_path: "dev.png"
  windows:
    generate: true
launcher_icons-production:
  image_path: "prod.png"
''');

      expect(flavors.keys.toSet(), {'development', 'production'});
      expect(flavors['development']!.imagePath, 'dev.png');
      expect(flavors['development']!.windowsConfig?.generate, isTrue);
      expect(flavors['production']!.imagePath, 'prod.png');
    });

    test('works without a base launcher_icons section', () async {
      final flavors = await load('''
launcher_icons-dev:
  image_path: "dev.png"
''');

      expect(flavors.keys.toSet(), {'dev'});
    });

    test('missing or empty file yields no flavors', () async {
      expect(Config.loadFlavorConfigsFromPath('absent.yaml', dir), isEmpty);

      await File(path.join(dir, 'empty.yaml')).writeAsString('\n');
      expect(Config.loadFlavorConfigsFromPath('empty.yaml', dir), isEmpty);
    });

    test('non-map section value throws', () async {
      await expectLater(
        load('launcher_icons-dev: true\n'),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    test('invalid nested section throws at load time', () async {
      await expectLater(
        load('''
launcher_icons-dev:
  android: "oops"
'''),
        throwsA(isA<InvalidConfigException>()),
      );
    });
  });
}
