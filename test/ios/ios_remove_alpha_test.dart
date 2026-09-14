import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// Regression tests for #514: `_alphaBlend` mixed up the background channels
// (bg.g/bg.a instead of bg.r/bg.g), tinting matted edges green.
void main() {
  group('remove_alpha background blending', () {
    late String originalDir;
    late String sandboxDir;

    setUp(() {
      originalDir = Directory.current.path;
      sandboxDir = path.join(
        '.dart_tool',
        'flutter_launcher_icons',
        'test',
        'ios_remove_alpha',
      );
      final sandbox = Directory(sandboxDir);
      if (sandbox.existsSync()) {
        sandbox.deleteSync(recursive: true);
      }
      sandbox.createSync(recursive: true);
      Directory.current = sandboxDir;
    });

    tearDown(() {
      Directory.current = originalDir;
    });

    test('semi-transparent red over green matte blends to yellow-brown',
        () async {
      // Uniform semi-transparent red source.
      final source = Image(width: 8, height: 8, numChannels: 4);
      for (final frame in source.frames) {
        for (var y = 0; y < frame.height; y++) {
          for (var x = 0; x < frame.width; x++) {
            frame.setPixelRgba(x, y, 255, 0, 0, 128);
          }
        }
      }
      await File('icon.png').writeAsBytes(encodePng(source));

      // Minimal runner layout expected by the generator.
      await Directory(path.join(
        'ios',
        'Runner',
        'Assets.xcassets',
        'AppIcon.appiconset',
      )).create(recursive: true);
      final pbxproj =
          File(path.join('ios', 'Runner.xcodeproj', 'project.pbxproj'));
      await pbxproj.create(recursive: true);
      await pbxproj.writeAsString('// !\$*UTF8*\$!\n{}\n');

      final config = Config.fromJson(<String, dynamic>{
        'ios': {
          'generate': true,
          'image_path': 'icon.png',
          'remove_alpha': true,
          'background_color': '#00FF00',
        },
      });

      await ios.createIcons(config, null);

      final output = decodeImage(
        await File(
          path.join(
            'ios',
            'Runner',
            'Assets.xcassets',
            'AppIcon.appiconset',
            'Icon-App-1024x1024@1x.png',
          ),
        ).readAsBytes(),
      )!;
      final pixel = output.getPixel(0, 0);
      // (128*255 + 127*0)/255 = 128 red, (128*0 + 127*255)/255 = 127 green.
      // The old channel-swapped math produced red = 255 here.
      expect(pixel.r, equals(128));
      expect(pixel.g, equals(127));
      expect(pixel.b, equals(0));
    });
  });
}
