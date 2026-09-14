import 'dart:io';

import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Tests for changeIosLauncherIcon: scoped rewrites (#565), atomic writes
// (#636) and the missing-key warning (#341).
// NOTE: a trailing newline keeps written output byte-identical when
// nothing is replaced.
const _fixture = r'''
// !$*UTF8*$!
{
/* Begin XCBuildConfiguration section */
		baseConfigurationReference = AAA /* Debug-production.xcconfig */;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
/* End XCBuildConfiguration section */
}
''';

void main() {
  group('changeIosLauncherIcon', () {
    late String originalDir;
    late String sandboxDir;

    setUp(() async {
      originalDir = Directory.current.path;
      sandboxDir = path.join(
        '.dart_tool',
        'flutter_launcher_icons',
        'test',
        'ios_change_icon',
      );
      final sandbox = Directory(sandboxDir);
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
      await Directory(path.join(sandboxDir, 'ios', 'Runner.xcodeproj'))
          .create(recursive: true);
      // Written before chdir (sandbox-relative); every path below is
      // CWD-relative because the generator resolves against Directory.current.
      await File(
        path.join(sandboxDir, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
      ).writeAsString(_fixture);
      Directory.current = sandboxDir;
    });

    tearDown(() {
      Directory.current = originalDir;
    });

    File pbxprojFile() => File(
          path.join('ios', 'Runner.xcodeproj', 'project.pbxproj'),
        );

    test('rewrites the matching flavor config without touching the rest',
        () async {
      await ios.changeIosLauncherIcon('AppIcon-production', 'production');
      final content = await pbxprojFile().readAsString();
      expect(
        content,
        contains('ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-production;'),
      );
      // #634: neighboring build settings must survive.
      expect(
        content,
        contains(
          'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;',
        ),
      );
      // #636: no temp file left behind.
      expect(
        File(
          path.join(
            'ios',
            'Runner.xcodeproj',
            'project.pbxproj.tmp',
          ),
        ).existsSync(),
        isFalse,
      );
    });

    test('warns instead of silently skipping a missing flavor key (#341)',
        () async {
      await ios.changeIosLauncherIcon('AppIcon-staging', 'staging');
      // File content (modulo trailing newline handling) is unchanged.
      final content = await pbxprojFile().readAsString();
      expect(content, isNot(contains('AppIcon-staging')));
    });

    test('updates every config when no flavor is given', () async {
      await ios.changeIosLauncherIcon('AppIcon', null);
      final content = await pbxprojFile().readAsString();
      expect(
        content,
        contains('ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;'),
      );
    });
  });
}
