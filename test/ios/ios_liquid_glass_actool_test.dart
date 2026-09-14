import 'dart:io';

import 'package:launcher_icons/config/config.dart';
import 'package:launcher_icons/ios_liquid_glass_icon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Validates generated `.icon` bundles with Apple's own `actool`, the same
// compiler Xcode runs during builds. Requires macOS + Xcode; skipped
// elsewhere (the JSON-shape unit tests cover all platforms).
void main() {
  group(
    'generateLiquidGlassIcon actool validation',
    () {
      late String originalDir;
      late String sandboxDir;

      setUp(() {
        originalDir = Directory.current.path;
        sandboxDir = path.absolute(
          '.dart_tool',
          'launcher_icons',
          'test',
          'ios_liquid_glass_actool',
        );
        final sandbox = Directory(sandboxDir);
        if (sandbox.existsSync()) {
          sandbox.deleteSync(recursive: true);
        }
        sandbox.createSync(recursive: true);
        for (final name in ['icon.png', 'icon-dark.png', 'icon-tinted.png']) {
          File(path.join(originalDir, 'test', 'assets', 'app_icon.png'))
              .copySync(path.join(sandboxDir, name));
        }
        Directory.current = sandboxDir;
      });

      tearDown(() {
        Directory.current = originalDir;
      });

      Future<ProcessResult> compileIcon(
        String bundleDir,
        String iconName,
        String outName,
      ) {
        final outDir = path.join(sandboxDir, outName);
        Directory(outDir).createSync();
        return Process.run('xcrun', [
          'actool',
          path.join(sandboxDir, bundleDir),
          '--app-icon',
          iconName,
          '--compile',
          outDir,
          '--output-partial-info-plist',
          path.join(sandboxDir, '$outName-info.plist'),
          '--output-format',
          'human-readable-text',
          '--target-device',
          'iphone',
          '--target-device',
          'ipad',
          '--minimum-deployment-target',
          '18.0',
          '--platform',
          'iphoneos',
        ]);
      }

      test('plain bundle compiles without errors', () async {
        final config = Config.fromJson(<String, dynamic>{
          'ios': {
            'generate': true,
            'image_path_liquid_glass_icon': 'icon.png',
          },
        });

        await generateLiquidGlassIcon(config, 'AppIcon');

        final result = await compileIcon(
          'ios/Runner/AppIcon.icon',
          'AppIcon',
          'compiled-plain',
        );
        expect(
          result.exitCode,
          equals(0),
          reason: result.stdout.toString() + result.stderr.toString(),
        );
        expect(
          File(path.join('compiled-plain', 'Assets.car')).existsSync(),
          isTrue,
        );
      });

      test('specialized bundle compiles without errors', () async {
        final config = Config.fromJson(<String, dynamic>{
          'ios': {
            'generate': true,
            'image_path_liquid_glass_icon': 'icon.png',
            'image_path_liquid_glass_icon_dark': 'icon-dark.png',
            'image_path_liquid_glass_icon_tinted': 'icon-tinted.png',
            'liquid_glass_shadow_kind': 'Chromatic',
          },
        });

        await generateLiquidGlassIcon(config, 'AppIcon');

        final result = await compileIcon(
          'ios/Runner/AppIcon.icon',
          'AppIcon',
          'compiled-spec',
        );
        expect(
          result.exitCode,
          equals(0),
          reason: result.stdout.toString() + result.stderr.toString(),
        );
        expect(
          File(path.join('compiled-spec', 'Assets.car')).existsSync(),
          isTrue,
        );
      });
    },
    skip: !Platform.isMacOS ? 'requires macOS with Xcode actool' : false,
  );
}
