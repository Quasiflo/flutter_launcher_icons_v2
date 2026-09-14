// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:io';

import 'package:launcher_icons/abs/icon_generator.dart';
import 'package:launcher_icons/config/config.dart';
import 'package:launcher_icons/config/windows_config.dart';
import 'package:launcher_icons/custom_exceptions.dart';
import 'package:launcher_icons/logger.dart';
import 'package:launcher_icons/windows/windows_icon_generator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../templates.dart' as templates;
import 'windows_icon_generator_test.mocks.dart';

/// Parses the ICONDIR of a `.ico` file, returning one entry per embedded
/// image. Width/height of `0` means 256 (per the ICO spec).
List<({int width, int height, int offset, int size})> _parseIcoDirectory(
  List<int> bytes,
) {
  if (bytes.length < 6) {
    fail('ico is smaller than the 6 byte ICONDIR header');
  }
  final count = bytes[4] | bytes[5] << 8;
  if (6 + count * 16 > bytes.length) {
    fail('ico ICONDIR is truncated');
  }
  return [
    for (var i = 0; i < count; i++)
      (
        width: bytes[6 + i * 16],
        height: bytes[6 + i * 16 + 1],
        size: bytes[6 + i * 16 + 8] |
            bytes[6 + i * 16 + 9] << 8 |
            bytes[6 + i * 16 + 10] << 16 |
            bytes[6 + i * 16 + 11] << 24,
        offset: bytes[6 + i * 16 + 12] |
            bytes[6 + i * 16 + 13] << 8 |
            bytes[6 + i * 16 + 14] << 16 |
            bytes[6 + i * 16 + 15] << 24,
      ),
  ];
}

@GenerateMocks([Config, WindowsConfig, LILogger])
void main() {
  group('WindowsIconGenerator', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config mockConfig;
    late WindowsConfig mockWindowsConfig;
    late String prefixPath;
    late File testImageFile;
    late MockLILogger mockLogger;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    group('#validateRequirments', () {
      setUpAll(() {
        // make sure test file exists before starting test
        testImageFile = File(path.join(assetPath, 'app_icon.png'));
        expect(testImageFile.existsSync(), isTrue);
      });
      setUp(() async {
        prefixPath = path.join(d.sandbox, 'fli_test');
        mockConfig = MockConfig();
        mockWindowsConfig = MockWindowsConfig();
        mockLogger = MockLILogger();
        context = IconGeneratorContext(
          config: mockConfig,
          prefixPath: prefixPath,
          logger: mockLogger,
        );
        generator = WindowsIconGenerator(context);
        // initilize mock defaults
        when(mockLogger.error(argThat(anything))).thenReturn(anything);
        when(mockLogger.info(argThat(anything))).thenReturn(anything);
        when(mockLogger.verbose(argThat(anything))).thenReturn(anything);
        when(mockLogger.isVerbose).thenReturn(false);
        when(mockConfig.windowsConfig).thenReturn(mockWindowsConfig);
        when(mockWindowsConfig.generate).thenReturn(true);
        when(mockWindowsConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
        when(mockConfig.imagePath)
            .thenReturn(path.join(prefixPath, 'app_icon.png'));
        // resolveImagePath is mocked: implement the real fallback rule so
        // the unit tests exercise the generators, not the mock default.
        when(mockConfig.resolveImagePath(argThat(anything))).thenAnswer(
          (invocation) =>
              (invocation.positionalArguments.first as String?) ??
              mockConfig.imagePath,
        );
      });

      test('isEnabled is false when windows config is not provided', () {
        when(mockConfig.windowsConfig).thenReturn(null);
        expect(generator.isEnabled, isFalse);
      });

      test('isEnabled is false when windows.generate is false', () {
        when(mockConfig.windowsConfig).thenReturn(mockWindowsConfig);
        when(mockWindowsConfig.generate).thenReturn(false);
        expect(generator.isEnabled, isFalse);
      });

      test('Config.fromJson rejects removed windows.icon_size with help',
          () {
        expect(
          () => Config.fromJson(<String, dynamic>{
            'windows': {'generate': true, 'icon_size': 48},
          }),
          throwsA(
            isA<InvalidConfigException>().having(
              (e) => e.toString(),
              'message',
              contains('windows.icon_size'),
            ),
          ),
        );
      });

      test('should return false when windows.image_path and imagePath is null',
          () {
        when(mockWindowsConfig.imagePath).thenReturn(null);
        when(mockConfig.imagePath).thenReturn(null);
        expect(generator.validateRequirements(), isFalse);

        verifyInOrder([
          mockWindowsConfig.imagePath,
          mockConfig.imagePath,
        ]);
      });

    test('should return false when windows dir does not exist', () async {
        await d.dir('fli_test', [
          d.file('app_icon.png', testImageFile.readAsBytesSync()),
        ]).create();
        await expectLater(
          d.dir('fli_test', [
            d.file('app_icon.png', anything),
          ]).validate(),
          completes,
        );
        expect(generator.validateRequirements(), isFalse);
      });

      test('should return false when image file does not exist', () async {
        await d.dir('fli_test', [d.dir('windows')]).create();
        await expectLater(
          d.dir('fli_test', [d.dir('windows')]).validate(),
          completes,
        );
        expect(generator.validateRequirements(), isFalse);
      });
    });
  });

  group('WindowsIconGenerator end-to-end', () {
    late IconGeneratorContext context;
    late IconGenerator generator;
    late Config config;
    late String prefixPath;
    final assetPath = path.join(Directory.current.path, 'test', 'assets');

    setUp(() async {
      final imageFile = File(path.join(assetPath, 'app_icon.png'));
      expect(imageFile.existsSync(), isTrue);
      await d.dir('fli_test', [
        d.dir('windows'),
        d.file('launcher_icons.yaml', templates.liWindowsConfig),
        d.file('pubspec.yaml', templates.pubspecTemplate),
        d.file('app_icon.png', imageFile.readAsBytesSync()),
      ]).create();
      prefixPath = path.join(d.sandbox, 'fli_test');
      config = Config.loadConfigFromPath(
        'launcher_icons.yaml',
        prefixPath,
      )!;
      context = IconGeneratorContext(
        config: config,
        prefixPath: prefixPath,
        logger: LILogger(false),
      );
      generator = WindowsIconGenerator(context);
    });

    test('should generate valid icons', () async {
      expect(generator.validateRequirements(), isTrue);
      await generator.createIcons();
      await expectLater(
        d.dir('fli_test', [
          d.dir('windows', [
            d.dir('runner', [
              d.dir('resources', [
                d.file('app_icon.ico', anything),
              ]),
            ]),
          ]),
        ]).validate(),
        completes,
      );

      final icoBytes = File(
        path.join(
          prefixPath,
          'windows',
          'runner',
          'resources',
          'app_icon.ico',
        ),
      ).readAsBytesSync();
      expect(icoBytes.length, greaterThan(6));

      final entries = _parseIcoDirectory(icoBytes);
      int toPixels(int byte) => byte == 0 ? 256 : byte;
      expect(
        entries.map((e) => toPixels(e.width)).toList(),
        [16, 24, 32, 48, 256],
      );
      expect(
        entries.map((e) => toPixels(e.height)).toList(),
        [16, 24, 32, 48, 256],
      );

      final firstDataOffset = 6 + entries.length * 16;
      expect(entries.first.offset, firstDataOffset);
      for (var i = 1; i < entries.length; i++) {
        expect(entries[i].offset, entries[i - 1].offset + entries[i - 1].size);
      }
      expect(entries.last.offset + entries.last.size, icoBytes.length);
    });
  });
}
