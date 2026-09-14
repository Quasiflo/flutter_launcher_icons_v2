import 'package:launcher_icons/custom_exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('LIException', () {
    test('all package exceptions extend the base class', () {
      expect(const InvalidConfigException(), isA<LIException>());
      expect(const InvalidAndroidIconNameException(), isA<LIException>());
      expect(const NoConfigFoundException(), isA<LIException>());
      expect(const NoDecoderForImageFormatException(), isA<LIException>());
      expect(const FileNotFoundException('x'), isA<LIException>());
      expect(
        IconGenerationException(const ['Android']),
        isA<LIException>(),
      );
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

    test('a single on LIException clause catches every subtype', () {
      Object? caught;
      try {
        throw const NoConfigFoundException('missing');
      } on LIException catch (e) {
        caught = e;
      }
      expect(caught, isA<NoConfigFoundException>());
    });
  });
}
