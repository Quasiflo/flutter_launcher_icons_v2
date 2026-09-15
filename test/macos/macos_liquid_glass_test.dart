import 'dart:convert';
import 'dart:io';

import 'package:launcher_icons/src/config/config.dart';
import 'package:launcher_icons/src/core/custom_exceptions.dart';
import 'package:launcher_icons/src/core/icon_generator.dart';
import 'package:launcher_icons/src/core/logger.dart';
import 'package:launcher_icons/src/platforms/ios/liquid_glass_icon_generator.dart';
import 'package:launcher_icons/src/platforms/macos/macos_icon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../templates.dart' as templates;

// Minimal macOS project.pbxproj carrying every section the .icon reference
// edit needs (file references, build files, Runner group, Resources phase).
const _pbxproj = r'''
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		00000000000000000000000A /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 000000000000000000000001 /* AppDelegate.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		000000000000000000000001 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		000000000000000000000002 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		000000000000000000000003 /* Runner */ = {
			isa = PBXGroup;
			children = (
				000000000000000000000002 /* Assets.xcassets */,
				000000000000000000000001 /* AppDelegate.swift */,
			);
			name = Runner;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXResourcesBuildPhase section */
		000000000000000000000004 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */
	};
	rootObject = 000000000000000000000005 /* Project object */;
}
''';

// Unit tests for macOS liquid glass support (lib/src/platforms/macos).
void main() {
  group('hasMacOSLiquidGlassIconConfig', () {
    test('is true when macos.image_path_liquid_glass_icon is set', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'assets/icon.png',
        },
      });
      expect(config.hasMacOSLiquidGlassIconConfig, isTrue);
    });

    test('is false when macos.image_path_liquid_glass_icon is not set', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {'generate': true},
      });
      expect(config.hasMacOSLiquidGlassIconConfig, isFalse);
    });

    test('is false without a macos section', () {
      final config = Config.fromJson(<String, dynamic>{});
      expect(config.hasMacOSLiquidGlassIconConfig, isFalse);
    });
  });

  group('Config macOS liquid glass fields', () {
    test('liquid glass config fields are parsed', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'assets/icon.png',
          'image_path_liquid_glass_icon_dark': 'assets/icon-dark.png',
          'image_path_liquid_glass_icon_tinted': 'assets/icon-tinted.png',
          'remove_liquid_glass': true,
          'background_color': '#FF0000',
          'liquid_glass_icon_scale': 0.85,
          'liquid_glass_translucency': 0.3,
          'liquid_glass_specular': false,
          'liquid_glass_shadow_kind': 'Chromatic',
          'liquid_glass_shadow_opacity': 0.7,
          'liquid_glass_blur': 0.4,
          'liquid_glass_lighting': 'combined',
          'liquid_glass_offset_x': 0.1,
          'liquid_glass_offset_y': -0.2,
        },
      });
      final macOSConfig = config.macOSConfig!;
      expect(macOSConfig.imagePathLiquidGlassIcon, 'assets/icon.png');
      expect(macOSConfig.imagePathLiquidGlassIconDark, 'assets/icon-dark.png');
      expect(
        macOSConfig.imagePathLiquidGlassIconTinted,
        'assets/icon-tinted.png',
      );
      expect(macOSConfig.removeLiquidGlass, isTrue);
      expect(macOSConfig.backgroundColor, '#FF0000');
      expect(macOSConfig.liquidGlassIconScale, 0.85);
      expect(macOSConfig.liquidGlassTranslucency, 0.3);
      expect(macOSConfig.liquidGlassSpecular, isFalse);
      expect(macOSConfig.liquidGlassShadowKind, 'Chromatic');
      expect(macOSConfig.liquidGlassShadowOpacity, 0.7);
      expect(macOSConfig.liquidGlassBlur, 0.4);
      expect(macOSConfig.liquidGlassLighting, 'combined');
      expect(macOSConfig.liquidGlassOffsetX, 0.1);
      expect(macOSConfig.liquidGlassOffsetY, -0.2);
    });

    test('liquid glass config fields have default values', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {'generate': true},
      });
      final macOSConfig = config.macOSConfig!;
      expect(macOSConfig.removeLiquidGlass, isFalse);
      expect(macOSConfig.backgroundColor, '#ffffff');
      expect(macOSConfig.liquidGlassIconScale, 1);
      expect(macOSConfig.liquidGlassTranslucency, 0.5);
      expect(macOSConfig.liquidGlassSpecular, isTrue);
      expect(macOSConfig.liquidGlassShadowKind, 'Neutral');
      expect(macOSConfig.liquidGlassShadowOpacity, 0.5);
      expect(macOSConfig.liquidGlassBlur, 0.5);
      expect(macOSConfig.liquidGlassLighting, isNull);
      expect(macOSConfig.liquidGlassOffsetX, 0.0);
      expect(macOSConfig.liquidGlassOffsetY, 0.0);
    });
  });

  group('generateMacOSIconConfig', () {
    test('generates the expected icon.json structure', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'assets/icon.png',
          'background_color': '#FF0000',
        },
      });

      final iconJson = generateMacOSIconConfig(config, 'icon.png');

      expect(
        iconJson['fill'],
        <String, dynamic>{
          'solid': 'display-p3:1.00000,0.00000,0.00000,1.00000',
        },
      );
      expect(
        iconJson['supported-platforms'],
        <String, dynamic>{
          'circles': <String>['watchOS'],
          'squares': 'shared',
        },
      );
      final groups = iconJson['groups'] as List;
      final layers = (groups.first as Map)['layers'] as List;
      final layer = layers.first as Map<String, dynamic>;
      expect(layer['image-name'], 'icon.png');
      expect(layer['glass'], isTrue);
    });

    test('emits dark/tinted specializations for explicit variants', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'icon.png',
          'image_path_liquid_glass_icon_dark': 'icon-dark.png',
          'image_path_liquid_glass_icon_tinted': 'icon-tinted.png',
        },
      });

      final iconJson = generateMacOSIconConfig(config, 'icon.png');
      final groups = iconJson['groups'] as List;
      final layers = (groups.first as Map)['layers'] as List;
      final layer = layers.first as Map<String, dynamic>;
      expect(layer.containsKey('image-name'), isFalse);
      expect(
        layer['image-name-specializations'],
        equals([
          {'value': 'icon.png'},
          {'appearance': 'dark', 'value': 'icon-dark.png'},
          {'appearance': 'tinted', 'value': 'icon-tinted.png'},
        ]),
      );
    });

    test('does not fall back to catalog artwork for variants', () {
      // Unlike iOS, macOS has no dark/tinted PNG catalog variants to reuse,
      // so variant keys stay unset without explicit layer sources.
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'icon.png',
        },
      });

      final iconJson = generateMacOSIconConfig(config, 'icon.png');
      final groups = iconJson['groups'] as List;
      final layers = (groups.first as Map)['layers'] as List;
      final layer = layers.first as Map<String, dynamic>;
      expect(layer['image-name'], 'icon.png');
    });

    test('remove_liquid_glass disables glass and translucency', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'icon.png',
          'remove_liquid_glass': true,
        },
      });

      final iconJson = generateMacOSIconConfig(config, 'icon.png');
      final groups = iconJson['groups'] as List;
      final group = groups.first as Map<String, dynamic>;
      final layers = group['layers'] as List;
      expect((layers.first as Map)['glass'], isFalse);
      expect(
        group['translucency'],
        equals({'enabled': false, 'value': 0.5}),
      );
    });

    test('rejects invalid values with macos-labelled errors', () {
      Map<String, dynamic> iconJsonFor(Map<String, dynamic> macos) {
        final config = Config.fromJson(<String, dynamic>{'macos': macos});
        return generateMacOSIconConfig(config, 'icon.png');
      }

      Map<String, dynamic> base() => <String, dynamic>{
            'generate': true,
            'image_path_liquid_glass_icon': 'icon.png',
          };

      expect(
        () => iconJsonFor(base()..['liquid_glass_shadow_kind'] = 'Invalid'),
        throwsA(
          isA<InvalidConfigException>().having(
            (e) => e.message,
            'message',
            contains('macos.liquid_glass_shadow_kind'),
          ),
        ),
      );
      expect(
        () => iconJsonFor(base()..['liquid_glass_lighting'] = 'dramatic'),
        throwsA(
          isA<InvalidConfigException>().having(
            (e) => e.message,
            'message',
            contains('macos.liquid_glass_lighting'),
          ),
        ),
      );
      expect(
        () => iconJsonFor(
          base()..['liquid_glass_refractivity_enabled'] = true,
        ),
        throwsA(
          isA<InvalidConfigException>().having(
            (e) => e.message,
            'message',
            contains('macos.liquid_glass_refractivity_enabled'),
          ),
        ),
      );
      expect(
        () => iconJsonFor(
          base()..['liquid_glass_specular_highlight_placement'] = 'above',
        ),
        throwsA(
          isA<InvalidConfigException>().having(
            (e) => e.message,
            'message',
            contains('macos.liquid_glass_specular_highlight_placement'),
          ),
        ),
      );
    });
  });

  group('generateMacOSLiquidGlassIcon', () {
    test('throws InvalidConfigException for invalid shadow kind', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'missing-icon.png',
          'liquid_glass_shadow_kind': 'Invalid',
        },
      });
      expect(
        () => generateMacOSLiquidGlassIcon(config, 'AppIcon'),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    test('throws InvalidConfigException when source image is missing', () {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path_liquid_glass_icon': 'missing-icon.png',
        },
      });
      expect(
        () => generateMacOSLiquidGlassIcon(config, 'AppIcon'),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    group('filesystem', () {
      late String prefixPath;
      late Directory sandbox;

      setUp(() async {
        sandbox = Directory(
          path.join(
            Directory.current.path,
            '.dart_tool',
            'launcher_icons',
            'test',
            'macos_liquid_glass',
          ),
        );
        if (sandbox.existsSync()) {
          sandbox.deleteSync(recursive: true);
        }
        sandbox.createSync(recursive: true);
        File(
          path.join(
            Directory.current.path,
            'test',
            'assets',
            'master-light-1024.png',
          ),
        ).copySync(path.join(sandbox.path, 'master-light-1024.png'));
        prefixPath = sandbox.absolute.path;
      });

      tearDown(() {
        if (sandbox.existsSync()) {
          sandbox.deleteSync(recursive: true);
        }
      });

      test('creates the .icon bundle structure and icon.json', () async {
        final config = Config.fromJson(<String, dynamic>{
          'macos': {
            'generate': true,
            'image_path_liquid_glass_icon': 'master-light-1024.png',
            'background_color': '#FF0000',
          },
        });

        await generateMacOSLiquidGlassIcon(
          config,
          'AppIcon',
          prefixPath: prefixPath,
        );

        final assetsImage = File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'AppIcon.icon',
            'Assets',
            'master-light-1024.png',
          ),
        );
        expect(assetsImage.existsSync(), isTrue);

        final configFile = File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'AppIcon.icon',
            'icon.json',
          ),
        );
        expect(configFile.existsSync(), isTrue);

        final iconJson =
            jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
        expect(
          iconJson['fill'],
          <String, dynamic>{
            'solid': 'display-p3:1.00000,0.00000,0.00000,1.00000',
          },
        );
        expect(
          iconJson['supported-platforms'],
          <String, dynamic>{
            'circles': <String>['watchOS'],
            'squares': 'shared',
          },
        );
      });

      test('sweeps layers orphaned by source switches', () async {
        final config = Config.fromJson(<String, dynamic>{
          'macos': {
            'generate': true,
            'image_path_liquid_glass_icon': 'master-light-1024.png',
            'background_color': '#FF0000',
          },
        });

        await generateMacOSLiquidGlassIcon(
          config,
          'AppIcon',
          prefixPath: prefixPath,
        );

        // Simulate a PNG -> SVG source switch: the stale copy must go.
        final stale = File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'AppIcon.icon',
            'Assets',
            'stale-layer.png',
          ),
        );
        await stale.writeAsBytes([1, 2, 3]);

        await generateMacOSLiquidGlassIcon(
          config,
          'AppIcon',
          prefixPath: prefixPath,
        );

        expect(stale.existsSync(), isFalse);
      });
    });
  });

  group('MacOSIconGenerator liquid glass', () {
    late String prefixPath;
    late Directory sandbox;

    setUp(() async {
      sandbox = Directory(
        path.join(
          Directory.current.path,
          '.dart_tool',
          'launcher_icons',
          'test',
          'macos_liquid_glass_generator',
        ),
      );
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
      await Directory(
        path.join(
          sandbox.path,
          'macos',
          'Runner',
          'Assets.xcassets',
          'AppIcon.appiconset',
        ),
      ).create(recursive: true);
      await Directory(
        path.join(sandbox.path, 'macos', 'Runner.xcodeproj'),
      ).create(recursive: true);
      await File(
        path.join(
          sandbox.path,
          'macos',
          'Runner',
          'Assets.xcassets',
          'AppIcon.appiconset',
          'Contents.json',
        ),
      ).writeAsString(templates.macOSContentsJsonFile);
      await File(
        path.join(
          sandbox.path,
          'macos',
          'Runner.xcodeproj',
          'project.pbxproj',
        ),
      ).writeAsString(_pbxproj);
      File(
        path.join(
          Directory.current.path,
          'test',
          'assets',
          'master-light-1024.png',
        ),
      ).copySync(path.join(sandbox.path, 'master-light-1024.png'));
      prefixPath = sandbox.absolute.path;
    });

    tearDown(() {
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
    });

    test('writes the .icon bundle and pbxproj reference', () async {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path': 'master-light-1024.png',
          'image_path_liquid_glass_icon': 'master-light-1024.png',
        },
      });
      final generator = MacOSIconGenerator(
        IconGeneratorContext(
          config: config,
          logger: LILogger(false),
          prefixPath: prefixPath,
        ),
      );

      expect(generator.isEnabled, isTrue);
      expect(generator.validateRequirements(), isTrue);
      await generator.createIcons();

      // PNG catalog still written alongside the glass bundle.
      expect(
        File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'Assets.xcassets',
            'AppIcon.appiconset',
            'Contents.json',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'AppIcon.icon',
            'icon.json',
          ),
        ).existsSync(),
        isTrue,
      );
      final pbxproj = File(
        path.join(
          prefixPath,
          'macos',
          'Runner.xcodeproj',
          'project.pbxproj',
        ),
      ).readAsStringSync();
      expect(pbxproj.contains('AppIcon.icon'), isTrue);
    });

    test('names the bundle after the flavor on flavor runs', () async {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path': 'master-light-1024.png',
          'image_path_liquid_glass_icon': 'master-light-1024.png',
        },
      });
      final generator = MacOSIconGenerator(
        IconGeneratorContext(
          config: config,
          logger: LILogger(false),
          prefixPath: prefixPath,
          flavor: 'staging',
        ),
      );

      await generator.createIcons();

      expect(
        File(
          path.join(
            prefixPath,
            'macos',
            'Runner',
            'AppIcon-staging.icon',
            'icon.json',
          ),
        ).existsSync(),
        isTrue,
      );
      final pbxproj = File(
        path.join(
          prefixPath,
          'macos',
          'Runner.xcodeproj',
          'project.pbxproj',
        ),
      ).readAsStringSync();
      expect(pbxproj.contains('AppIcon-staging.icon'), isTrue);
    });

    test('writes no bundle without liquid glass config', () async {
      final config = Config.fromJson(<String, dynamic>{
        'macos': {
          'generate': true,
          'image_path': 'master-light-1024.png',
        },
      });
      final generator = MacOSIconGenerator(
        IconGeneratorContext(
          config: config,
          logger: LILogger(false),
          prefixPath: prefixPath,
        ),
      );

      await generator.createIcons();

      expect(
        Directory(
          path.join(prefixPath, 'macos', 'Runner', 'AppIcon.icon'),
        ).existsSync(),
        isFalse,
      );
    });
  });
}
