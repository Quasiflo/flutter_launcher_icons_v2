import 'dart:io';

import 'package:image/image.dart';
import 'package:launcher_icons/src/config/config.dart';
import 'package:launcher_icons/src/config/windows_config.dart';
import 'package:launcher_icons/src/core/custom_exceptions.dart';
import 'package:launcher_icons/src/core/icon_generator.dart';
import 'package:launcher_icons/src/core/logger.dart';
import 'package:launcher_icons/src/core/utils.dart' as utils;
import 'package:launcher_icons/src/platforms/windows/windows_icon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

// SVG sources: detection, rasterization, the per-size opt-in, and one
// end-to-end platform run per raster mode.
void main() {
  final assetPath = path.join(Directory.current.path, 'test', 'assets');

  group('isSvgPath', () {
    test('matches svg extension case-insensitively', () {
      expect(utils.isSvgPath('icon.svg'), isTrue);
      expect(utils.isSvgPath('assets/ICON.SVG'), isTrue);
      expect(utils.isSvgPath('icon.png'), isFalse);
      expect(utils.isSvgPath('icon.svg.png'), isFalse);
    });
  });

  group('rasterizeSvgFile', () {
    test('renders at the requested size with gradients intact', () async {
      final image = await utils.rasterizeSvgFile(
        path.join(assetPath, 'vector-opaque-1024.svg'),
        width: 48,
        height: 48,
      );

      expect(image.width, equals(48));
      expect(image.height, equals(48));
      // Fully opaque art strips the alpha channel (downstream hasAlpha
      // checks see it as opaque).
      expect(image.numChannels, equals(3));
      // White ring between the navy core and the gradient edge: the ring
      // spans radii 150-300 of 1024, so (24,14) sits 10px off-center.
      final ring = image.getPixel(24, 14);
      expect(ring.r, greaterThan(200));
      expect(ring.g, greaterThan(200));
      expect(ring.b, greaterThan(200));
      // Corner carries the opaque gradient background.
      expect(image.getPixel(2, 2).a, equals(255));
    });

    test('recovers transparency by difference matting', () async {
      final image = await utils.rasterizeSvgFile(
        path.join(assetPath, 'vector-transparent-1024.svg'),
        width: 64,
        height: 64,
      );

      expect(image.numChannels, equals(4));
      expect(image.getPixel(0, 0).a, equals(0));
      // Center sits on the semi-transparent teal stripe over the amber
      // disc: opaque teal after matting.
      final center = image.getPixel(32, 32);
      expect(center.a, equals(255));
      expect(center.r, closeTo(0, 2));
      expect(center.g, closeTo(188, 2));
      expect(center.b, closeTo(212, 2));
    });

    test('matte of identical renders strips alpha as fully opaque', () {
      final white = Image(width: 4, height: 4, numChannels: 3);
      fill(white, color: ColorRgb8(10, 20, 30));

      final matted = utils.matteWhiteBlack(white, white);

      expect(matted.numChannels, equals(3));
      final pixel = matted.getPixel(1, 1);
      expect(pixel.r, equals(10));
      expect(pixel.g, equals(20));
      expect(pixel.b, equals(30));
    });

    test('defaults to a 1024 master', () async {
      final image = await utils.rasterizeSvgFile(
        path.join(assetPath, 'vector-opaque-1024.svg'),
      );

      expect(image.width, equals(utils.svgMasterSize));
      expect(image.height, equals(utils.svgMasterSize));
    });

    test('missing file throws FileSystemException', () async {
      await expectLater(
        utils.rasterizeSvgFile(path.join(assetPath, 'absent.svg')),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('malformed svg throws InvalidConfigException', () async {
      final dir = await Directory.systemTemp.createTemp('svg_bad');
      try {
        final file = File(path.join(dir.path, 'bad.svg'));
        await file.writeAsString('not xml at all <<<');
        await expectLater(
          utils.rasterizeSvgFile(file.path),
          throwsA(isA<InvalidConfigException>()),
        );
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test('svg without dimensions throws InvalidConfigException', () async {
      final dir = await Directory.systemTemp.createTemp('svg_nosize');
      try {
        final file = File(path.join(dir.path, 'nosize.svg'));
        await file.writeAsString(
          '<svg xmlns="http://www.w3.org/2000/svg"><rect width="10" height="10"/></svg>',
        );
        await expectLater(
          utils.rasterizeSvgFile(file.path),
          throwsA(isA<InvalidConfigException>()),
        );
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });

  group('decodeImageFile', () {
    test('routes svg sources through the rasterizer', () async {
      final image = await utils.decodeImageFile(
        path.join(assetPath, 'vector-opaque-1024.svg'),
      );

      expect(image.width, equals(utils.svgMasterSize));
    });
  });

  group('sizeImageLoaderFor', () {
    test('raster sources decode once and resize', () async {
      final load = await utils.sizeImageLoaderFor(
        path.join(assetPath, 'master-light-1024.png'),
        perSize: true,
      );

      final small = await load(48);
      expect(small.width, equals(48));
      expect(small.height, equals(48));
    });

    test('svg single-master mode resizes one 1024 raster', () async {
      final load = await utils.sizeImageLoaderFor(
        path.join(assetPath, 'vector-opaque-1024.svg'),
        perSize: false,
      );

      final small = await load(48);
      expect(small.width, equals(48));
      expect(small.getPixel(24, 24).a, equals(255));
    });

    test('svg per-size mode rasterizes at each size', () async {
      final load = await utils.sizeImageLoaderFor(
        path.join(assetPath, 'vector-opaque-1024.svg'),
        perSize: true,
      );

      for (final size in [16, 48, 192]) {
        final image = await load(size);
        expect(image.width, equals(size));
        expect(image.height, equals(size));
      }
    });
  });

  group('svg_rasterize_per_size flag', () {
    test('defaults to false and parses when set', () {
      expect(const Config().svgRasterizePerSize, isFalse);
      final config = Config.fromJson(<String, dynamic>{
        'svg_rasterize_per_size': true,
      });
      expect(config.svgRasterizePerSize, isTrue);
    });
  });

  group('windows end-to-end from svg', () {
    Future<String> runWithFlag(bool perSize) async {
      final name = perSize ? 'fli_svg_persize' : 'fli_svg_master';
      await d.dir(name, [
        d.dir('windows/runner/resources'),
        d.file(
          'icon.svg',
          File(path.join(assetPath, 'vector-opaque-1024.svg')).readAsBytesSync(),
        ),
      ]).create();
      final prefix = path.join(d.sandbox, name);
      final config = Config(
        imagePath: 'icon.svg',
        windowsConfig: const WindowsConfig(generate: true),
        svgRasterizePerSize: perSize,
      );
      final generator = WindowsIconGenerator(
        IconGeneratorContext(
          config: config,
          prefixPath: prefix,
          logger: LILogger(false),
        ),
      );

      expect(generator.validateRequirements(), isTrue);
      await generator.createIcons();
      return path.join(
        prefix,
        'windows',
        'runner',
        'resources',
        'app_icon.ico',
      );
    }

    int icoFrameCount(String icoPath) {
      final bytes = File(icoPath).readAsBytesSync();
      expect(bytes.length, greaterThan(6));
      return bytes[4] | bytes[5] << 8;
    }

    test('single-master mode emits a 7-frame ico', () async {
      expect(icoFrameCount(await runWithFlag(false)), equals(7));
    });

    test('per-size mode emits a 7-frame ico', () async {
      expect(icoFrameCount(await runWithFlag(true)), equals(7));
    });
  });
}
