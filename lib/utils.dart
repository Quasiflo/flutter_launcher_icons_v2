
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

import 'custom_exceptions.dart';
import 'logger.dart';

/// Note: Do not change interpolation unless you end up with better results
/// (see issue for result when using cubic interpolation)
/// https://github.com/Quasiflo/launcher_icons/issues/101#issuecomment-495528733
Image createResizedImage(int iconSize, Image image) {
  if (image.width >= iconSize) {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.average,
    );
  } else {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.linear,
    );
  }
}

/// Prints a status bullet, routed through [logger] when provided (#552).
void printStatus(String message, [LILogger? logger]) {
  if (logger != null) {
    logger.info('• $message');
  } else {
    print('• $message');
  }
}

/// Formats [e] for CLI output as `✗ ERROR: <Type>` plus [error] detail.
String generateError(Exception e, String? error) {
  final errorOutput = error == null ? '' : ' \n$error';
  return '\n✗ ERROR: ${(e).runtimeType.toString()}$errorOutput';
}

/// Decodes the image at [filePath], throwing [FileSystemException] when
/// missing and [NoDecoderForImageFormatException] when undecodable.
/// Never returns null.
Future<Image> decodeImageFile(String filePath) async {
  final bytes = await File(filePath).readAsBytes();
  final image = decodeImage(bytes);
  if (image == null) {
    throw NoDecoderForImageFormatException(filePath);
  }
  return image;
}

/// Joins [prefixPath] with a project-relative [target] path.
///
/// The default `'.'` prefix leaves [target] untouched so default runs keep
/// their historical relative paths; any other prefix is joined normally.
String withPrefix(String prefixPath, String target) =>
    prefixPath == '.' ? target : path.join(prefixPath, target);

/// Parses a `#rrggbb` (or `rrggbb`) hex color into its channels.
///
/// Only the 6-digit form is accepted; anything else throws
/// [InvalidConfigException].
({int r, int g, int b}) parseHexColor(String hexColor) {
  final cleanHex =
      hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;
  final hexValue = int.tryParse(cleanHex, radix: 16);
  if (cleanHex.length != 6 || hexValue == null) {
    throw InvalidConfigException(
      'Invalid hex color "$hexColor": expected 6 hex digits (e.g. "#ffffff")',
    );
  }
  return (
    r: (hexValue >> 16) & 0xff,
    g: (hexValue >> 8) & 0xff,
    b: hexValue & 0xff,
  );
}

/// Whether [color] is a valid CSS hex color: `#rgb`, `#rgba`, `#rrggbb`,
/// or `#rrggbbaa`.
bool isHexColor(String color) {
  if (!color.startsWith('#')) {
    return false;
  }
  final hex = color.substring(1);
  if (![3, 4, 6, 8].contains(hex.length)) {
    return false;
  }
  return int.tryParse(hex, radix: 16) != null;
}

/// Creates [File] in the given [filePath] if not exists
Future<File> createFileIfNotExist(String filePath) async {
  final file = File(path.joinAll(path.split(filePath)));
  // Using the sync method here due to `avoid_slow_async_io` lint suggestion.
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}

/// Creates [Directory] in the given [dirPath] if not exists
Future<Directory> createDirIfNotExist(String dirPath) async {
  final dir = Directory(path.joinAll(path.split(dirPath)));
  // Using the sync method here due to `avoid_slow_async_io` lint suggestion.
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Returns a prettified json string
String prettifyJsonEncode(Object? map) =>
    JsonEncoder.withIndent(' ' * 4).convert(map);

/// Check if give [File] or [Directory] exists at the give [paths],
/// if not returns the failed [FileSystemEntity] path
String? areFSEntiesExist(List<String> paths) {
  for (final path in paths) {
    // Using the sync method here due to `avoid_slow_async_io` lint suggestion.
    final fsType = FileSystemEntity.typeSync(path);
    if (![FileSystemEntityType.directory, FileSystemEntityType.file]
        .contains(fsType)) {
      return path;
    }
  }
  return null;
}

/// Config file name for [flavor] (e.g. `launcher_icons-staging.yaml`).
String flavorConfigFile(String flavor) => 'launcher_icons-$flavor.yaml';
