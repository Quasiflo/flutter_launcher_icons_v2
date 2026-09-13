import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios_liquid_glass_icon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Unit tests for ios_liquid_glass_icon_generator.dart
void main() {
  group('hasLiquidGlassIconConfig', () {
    test('is true when image_path_ios_liquid_glass_icon is set', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'assets/icon.png',
      });
      expect(config.hasLiquidGlassIconConfig, isTrue);
    });

    test('is false when image_path_ios_liquid_glass_icon is not set', () {
      final config = Config.fromJson(<String, dynamic>{});
      expect(config.hasLiquidGlassIconConfig, isFalse);
    });
  });

  group('Config liquid glass fields', () {
    test('liquid glass config fields are parsed', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'assets/icon.png',
        'remove_liquid_glass_ios': true,
        'liquid_glass_icon_scale': 0.85,
        'liquid_glass_translucency_ios': 0.3,
        'liquid_glass_specular_ios': false,
        'liquid_glass_shadow_kind_ios': 'Chromatic',
        'liquid_glass_shadow_opacity_ios': 0.7,
        'liquid_glass_blur_ios': 0.4,
        'liquid_glass_offset_x_ios': 0.1,
        'liquid_glass_offset_y_ios': -0.2,
      });
      expect(config.imagePathIOSLiquidGlassIcon, 'assets/icon.png');
      expect(config.removeLiquidGlassIOS, isTrue);
      expect(config.liquidGlassIconScaleIOS, 0.85);
      expect(config.liquidGlassTranslucencyIOS, 0.3);
      expect(config.liquidGlassSpecularIOS, isFalse);
      expect(config.liquidGlassShadowKindIOS, 'Chromatic');
      expect(config.liquidGlassShadowOpacityIOS, 0.7);
      expect(config.liquidGlassBlurIOS, 0.4);
      expect(config.liquidGlassOffsetXIOS, 0.1);
      expect(config.liquidGlassOffsetYIOS, -0.2);
    });

    test('liquid glass config fields have default values', () {
      final config = Config.fromJson(<String, dynamic>{});
      expect(config.removeLiquidGlassIOS, isFalse);
      expect(config.liquidGlassIconScaleIOS, 1);
      expect(config.liquidGlassTranslucencyIOS, 0.5);
      expect(config.liquidGlassSpecularIOS, isTrue);
      expect(config.liquidGlassShadowKindIOS, 'Neutral');
      expect(config.liquidGlassShadowOpacityIOS, 0.5);
      expect(config.liquidGlassBlurIOS, 0.5);
      expect(config.liquidGlassOffsetXIOS, 0.0);
      expect(config.liquidGlassOffsetYIOS, 0.0);
    });
  });

  group('convertHexToDisplayP3', () {
    test('converts hex colors to display-p3 format', () {
      expect(
        convertHexToDisplayP3('#FF0000'),
        'display-p3:1.00000,0.00000,0.00000,1.00000',
      );
      expect(
        convertHexToDisplayP3('#ffffff'),
        'display-p3:1.00000,1.00000,1.00000,1.00000',
      );
      expect(
        convertHexToDisplayP3('#000000'),
        'display-p3:0.00000,0.00000,0.00000,1.00000',
      );
      expect(
        convertHexToDisplayP3('#123456'),
        'display-p3:0.07059,0.20392,0.33725,1.00000',
      );
      expect(
        convertHexToDisplayP3('FF0000'),
        'display-p3:1.00000,0.00000,0.00000,1.00000',
      );
    });

    test('throws InvalidConfigException when hex is not 6 characters', () {
      expect(
        () => convertHexToDisplayP3('#FF00'),
        throwsA(isA<InvalidConfigException>()),
      );
      expect(
        () => convertHexToDisplayP3('#GGGGGG'),
        throwsA(isA<InvalidConfigException>()),
      );
    });
  });

  group('generateIconConfig', () {
    test('generates the expected icon.json structure', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'assets/icon.png',
        'liquid_glass_icon_scale': 0.85,
        'liquid_glass_translucency_ios': 0.3,
        'liquid_glass_specular_ios': true,
        'liquid_glass_shadow_kind_ios': 'Neutral',
        'liquid_glass_shadow_opacity_ios': 0.7,
        'liquid_glass_blur_ios': 0.4,
        'liquid_glass_offset_x_ios': 0.1,
        'liquid_glass_offset_y_ios': -0.2,
      });
      expect(
        generateIconConfig(config, 'liquid_glass_icon.png'),
        equals(<String, dynamic>{
          'fill': <String, dynamic>{
            'solid': 'display-p3:1.00000,1.00000,1.00000,1.00000',
          },
          'groups': [
            <String, dynamic>{
              'blur-material': 0.4,
              'layers': [
                <String, dynamic>{
                  'glass': true,
                  'hidden': false,
                  'image-name': 'liquid_glass_icon.png',
                  'name': 'liquid_glass_icon',
                  'position': <String, dynamic>{
                    'scale': 0.85,
                    'translation-in-points': <double>[0.1, -0.2],
                  },
                },
              ],
              'shadow': <String, dynamic>{
                'kind': 'neutral',
                'opacity': 0.7,
              },
              'specular': true,
              'translucency': <String, dynamic>{
                'enabled': true,
                'value': 0.3,
              },
            },
          ],
          'supported-platforms': <String, dynamic>{
            'circles': <String>['watchOS'],
            'squares': 'shared',
          },
        }),
      );
    });

    test('maps chromatic shadow kind to layer-color', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'assets/icon.png',
        'liquid_glass_shadow_kind_ios': 'Chromatic',
      });
      final groups = generateIconConfig(config, 'icon.png')['groups'] as List;
      final shadow = (groups.first as Map<String, dynamic>)['shadow']
          as Map<String, dynamic>;
      expect(shadow['kind'], 'layer-color');
    });

    test('disables glass and translucency when remove_liquid_glass_ios is true',
        () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'assets/icon.png',
        'remove_liquid_glass_ios': true,
      });
      final groups = generateIconConfig(config, 'icon.png')['groups'] as List;
      final firstGroup = groups.first as Map<String, dynamic>;
      final layer =
          (firstGroup['layers'] as List).first as Map<String, dynamic>;
      final translucency = firstGroup['translucency'] as Map<String, dynamic>;
      expect(layer['glass'], isFalse);
      expect(translucency['enabled'], isFalse);
    });
  });

  group('generateLiquidGlassIcon', () {
    test('throws InvalidConfigException for invalid shadow kind', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'missing-icon.png',
        'liquid_glass_shadow_kind_ios': 'Invalid',
      });
      expect(
        () => generateLiquidGlassIcon(config, 'AppIcon'),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    test('throws InvalidConfigException when source image is missing', () {
      final config = Config.fromJson(<String, dynamic>{
        'image_path_ios_liquid_glass_icon': 'missing-icon.png',
      });
      expect(
        () => generateLiquidGlassIcon(config, 'AppIcon'),
        throwsA(isA<InvalidConfigException>()),
      );
    });

    group('filesystem', () {
      late String originalDir;
      late String sandboxDir;

      setUp(() {
        originalDir = Directory.current.path;
        sandboxDir = path.join(
          '.dart_tool',
          'flutter_launcher_icons',
          'test',
          'ios_liquid_glass',
        );
        final sandbox = Directory(sandboxDir);
        if (sandbox.existsSync()) {
          sandbox.deleteSync(recursive: true);
        }
        sandbox.createSync(recursive: true);
        File(path.join(originalDir, 'test', 'assets', 'app_icon.png'))
            .copySync(path.join(sandboxDir, 'app_icon.png'));
        Directory.current = sandboxDir;
      });

      tearDown(() {
        Directory.current = originalDir;
      });

      test('creates the .icon bundle structure and icon.json', () async {
        final config = Config.fromJson(<String, dynamic>{
          'image_path_ios_liquid_glass_icon': 'app_icon.png',
          'background_color_ios': '#FF0000',
        });

        await generateLiquidGlassIcon(config, 'AppIcon');

        final assetsImage =
            File(iosLiquidGlassAssetsPath('AppIcon') + 'app_icon.png');
        expect(assetsImage.existsSync(), isTrue);

        final configFile = File(iosLiquidGlassConfigPath('AppIcon'));
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
    });
  });
}
