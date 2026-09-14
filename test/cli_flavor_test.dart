import 'dart:async';
import 'dart:io';

import 'package:launcher_icons/src/cli.dart' as main_dart;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// End-to-end tests for flavor selection through createIconsFromArguments.
// These change the process working directory (the CLI resolves everything
// against CWD); test execution is serialized via dart_test.yaml.
//
// LILogger routes info output through top-level print (via cli_util's
// StandardLogger), so a print zone captures the CLI banners below.

// End-to-end tests for flavor selection through createIconsFromArguments.
// These change the process working directory (the CLI resolves everything
// against CWD); test execution is serialized via dart_test.yaml.
void main() {
  group('createIconsFromArguments flavor selection', () {
    late String originalDir;
    late String sandboxDir;

    const windowsYaml = '''
launcher_icons:
  image_path: "icon.png"
  windows:
    generate: true
''';

    setUp(() async {
      originalDir = Directory.current.path;
      sandboxDir = path.join(
        '.dart_tool',
        'launcher_icons',
        'test',
        'cli_flavor',
      );
      final sandbox = Directory(sandboxDir);
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
      sandbox.createSync(recursive: true);
      await Directory(path.join(sandboxDir, 'windows')).create();
      File(path.join(originalDir, 'test', 'assets', 'app_icon.png'))
          .copySync(path.join(sandboxDir, 'icon.png'));
      await File(
        path.join(sandboxDir, 'launcher_icons-staging.yaml'),
      ).writeAsString(windowsYaml);
      await File(
        path.join(sandboxDir, 'launcher_icons-production.yaml'),
      ).writeAsString(windowsYaml);
      await File(path.join(sandboxDir, 'custom.yaml'))
          .writeAsString(windowsYaml);
      Directory.current = sandboxDir;
    });

    tearDown(() {
      Directory.current = originalDir;
    });

    Future<List<String>> runCli(List<String> args) async {
      final printed = <String>[];
      await runZoned(
        () => main_dart.createIconsFromArguments(args),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );
      return printed;
    }

    test('loops over all flavors without -f', () async {
      final printed = await runCli([]);
      expect(printed.any((line) => line.contains('Flavor: staging')), isTrue);
      expect(
        printed.any((line) => line.contains('Flavor: production')),
        isTrue,
      );
      expect(
        printed.any((line) => line.contains('for flavors')),
        isTrue,
      );
    });

    test(
        'explicit -f flavor file runs only that flavor (fluttercommunity/flutter_launcher_icons#215)',
        () async {
      final printed = await runCli(['-f', 'launcher_icons-staging.yaml']);
      expect(printed.any((line) => line.contains('Flavor: staging')), isTrue);
      expect(
        printed.any((line) => line.contains('Flavor: production')),
        isFalse,
      );
    });

    test(
        'explicit -f custom file bypasses the flavor loop (fluttercommunity/flutter_launcher_icons#426)',
        () async {
      final printed = await runCli(['-f', 'custom.yaml']);
      expect(
        printed.any((line) => line.contains('Flavor:')),
        isFalse,
      );
      expect(
        printed.any(
          (line) =>
              line.contains('Successfully generated launcher icons') &&
              !line.contains('flavors'),
        ),
        isTrue,
      );
    });
  });
}
