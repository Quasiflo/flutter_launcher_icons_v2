import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('FLIException', () {
    test('all package exceptions extend the base class', () {
      expect(const InvalidConfigException(), isA<FLIException>());
      expect(const InvalidAndroidIconNameException(), isA<FLIException>());
      expect(const NoConfigFoundException(), isA<FLIException>());
      expect(const NoDecoderForImageFormatException(), isA<FLIException>());
      expect(const FileNotFoundException('x'), isA<FLIException>());
      expect(const InvalidConfigException(), isA<Exception>());
    });

    test('toString output is unchanged', () {
      expect(
        const InvalidConfigException('bad').toString(),
        contains('InvalidConfigException'),
      );
      expect(
        const FileNotFoundException('icon.png').toString(),
        contains('icon.png file not found'),
      );
    });

    test('a single on FLIException clause catches every subtype', () {
      Object? caught;
      try {
        throw const NoConfigFoundException('missing');
      } on FLIException catch (e) {
        caught = e;
      }
      expect(caught, isA<NoConfigFoundException>());
    });
  });
}
