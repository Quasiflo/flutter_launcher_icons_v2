import 'package:flutter_launcher_icons/utils.dart';

/// Base class for all flutter_launcher_icons exceptions.
///
/// Catching `FLIException` handles every error thrown by this package while
/// the specific subtypes stay available for fine-grained handling.
abstract class FLIException implements Exception {
  /// Constructs instance
  const FLIException([this.message]);

  /// Message for the exception
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

/// Exception to be thrown whenever we have an invalid configuration
class InvalidConfigException extends FLIException {
  /// Constructs instance
  const InvalidConfigException([super.message]);
}

/// Exception to be thrown whenever using an invalid Android icon name
class InvalidAndroidIconNameException extends FLIException {
  /// Constructs instance of this exception
  const InvalidAndroidIconNameException([super.message]);
}

/// Exception to be thrown whenever no config is found
class NoConfigFoundException extends FLIException {
  /// Constructs instance of this exception
  const NoConfigFoundException([super.message]);
}

/// Exception to be thrown whenever there is no decoder for the image format
class NoDecoderForImageFormatException extends FLIException {
  /// Constructs instance of this exception
  const NoDecoderForImageFormatException([super.message]);
}

/// A exception to throw when given [fileName] is not found
class FileNotFoundException extends FLIException {
  /// Creates a instance of [FileNotFoundException].
  const FileNotFoundException(this.fileName)
      : super('$fileName file not found');

  /// Name of the file
  final String fileName;
}
