import 'package:launcher_icons/utils.dart';

/// Base class for all launcher_icons exceptions.
///
/// Catching `LIException` handles every error thrown by this package while
/// the specific subtypes stay available for fine-grained handling.
abstract class LIException implements Exception {
  /// Constructs instance
  const LIException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// Exception to be thrown whenever we have an invalid configuration
class InvalidConfigException extends LIException {
  /// Constructs instance
  const InvalidConfigException([super.message]);
}

/// Exception to be thrown whenever using an invalid Android icon name
class InvalidAndroidIconNameException extends LIException {
  /// Constructs instance of this exception
  const InvalidAndroidIconNameException([super.message]);
}

/// Exception to be thrown whenever no config is found
class NoConfigFoundException extends LIException {
  /// Constructs instance of this exception
  const NoConfigFoundException([super.message]);
}

/// Exception to be thrown whenever there is no decoder for the image format
class NoDecoderForImageFormatException extends LIException {
  /// Constructs instance of this exception
  const NoDecoderForImageFormatException([super.message]);
}

/// A exception to throw when given [fileName] is not found
class FileNotFoundException extends LIException {
  /// Creates a instance of [FileNotFoundException].
  const FileNotFoundException(this.fileName)
      : super('$fileName file not found');

  /// Name of the file
  final String fileName;
}
