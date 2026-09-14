import 'dart:io';

import 'package:launcher_icons/abs/icon_generator.dart';
import 'package:launcher_icons/constants.dart' as constants;
import 'package:launcher_icons/custom_exceptions.dart';
import 'package:launcher_icons/utils.dart' as utils;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// A Implementation of [IconGenerator] for Linux
class LinuxIconGenerator extends IconGenerator {
  /// Creates a instance of [LinuxIconGenerator]
  LinuxIconGenerator(IconGeneratorContext context) : super(context, 'Linux');

  @override
  bool get isEnabled => context.linuxConfig?.generate ?? false;

  @override
  Future<void> createIcons() async {
    final iconPath = context.config
        .resolveImagePath(context.linuxConfig!.imagePath)!;

    context.logger.verbose('Using Linux icon at $iconPath...');

    // Validate that the icon path starts with assets/ (since it needs to be runtime accessible)
    if (!iconPath.startsWith('assets/')) {
      context.logger.error(
        'Linux icon path must be in assets directory (e.g., "assets/images/icon.png") to be accessible at runtime',
      );
      throw Exception('Invalid Linux icon path: $iconPath');
    }

    // Update my_application.cc file with the icon path
    await _updateMyApplicationFile(iconPath);
  }

  @override
  bool validateRequirements() {
    // The generate flag is enforced by [isEnabled]; only filesystem and
    // config preconditions are checked here.
    context.logger.verbose('Validating Linux config...');
    final linuxConfig = context.linuxConfig!;

    if (context.config.resolveImagePath(linuxConfig.imagePath) == null) {
      context.logger.error(
        'Invalid config. Either provide linux.image_path or image_path',
      );
      return false;
    }

    final iconPath = context.config
        .resolveImagePath(linuxConfig.imagePath)!;

    // Check that icon path is in assets
    if (!iconPath.startsWith('assets/')) {
      context.logger.error(
        'Linux icon path must be in assets directory (e.g., "assets/images/icon.png") to be accessible at runtime',
      );
      return false;
    }

    final entitesToCheck = [
      path.join(context.prefixPath, constants.linuxDirPath),
      path.join(context.prefixPath, constants.linuxMyApplicationFile),
      path.join(context.prefixPath, iconPath),
    ];

    final failedEntityPath = utils.areFSEntiesExist(entitesToCheck);
    if (failedEntityPath != null) {
      context.logger.error(
        '$failedEntityPath this file or folder is required to generate Linux icons',
      );
      return false;
    }

    if (!_hasPubspecAsset(iconPath)) {
      return false;
    }

    return true;
  }

  /// Returns `true` when [iconPath] (or its directory) is declared in the
  /// `flutter.assets` section of `pubspec.yaml`.
  bool _hasPubspecAsset(String iconPath) {
    final pubspecFile = File(path.join(context.prefixPath, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      context.logger.error(
        'pubspec.yaml not found. Please add "$iconPath" to your flutter.assets section.',
      );
      return false;
    }

    final Map<dynamic, dynamic>? yamlDoc;
    try {
      yamlDoc =
          loadYaml(pubspecFile.readAsStringSync()) as Map<dynamic, dynamic>?;
    } catch (_) {
      context.logger.error('Could not parse pubspec.yaml');
      return false;
    }

    if (yamlDoc == null) {
      context.logger.error('Could not parse pubspec.yaml');
      return false;
    }

    final flutter = yamlDoc['flutter'] as Map<dynamic, dynamic>?;
    if (flutter == null) {
      context.logger.error(
        'No flutter section found in pubspec.yaml. Please add $iconPath to your flutter.assets section.',
      );
      return false;
    }

    final assets = flutter['assets'] as List<dynamic>?;
    if (assets == null) {
      context.logger.error(
        'No assets section found in pubspec.yaml. Please add "$iconPath" to your flutter.assets section.',
      );
      return false;
    }

    // Check if the icon path or its directory is included in assets.
    // Normalize separators so a directory entry also matches on Windows.
    final iconDir = '${path.dirname(iconPath).replaceAll(r'\', '/')}/';
    for (final asset in assets) {
      final assetStr = asset.toString();
      if (assetStr == iconPath || assetStr == iconDir) {
        context.logger.verbose(
          'Icon path $iconPath is properly configured in pubspec.yaml',
        );
        return true;
      }
    }

    context.logger.error(
      'Icon path $iconPath not found in pubspec.yaml assets. Please add "$iconPath" or "$iconDir" to your flutter.assets section.',
    );
    return false;
  }

  static const _assetHelperName = 'get_flutter_asset_path';
  static const _iconVarName = 'linux_icon_path';
  static const _gioInclude = '#include <gio/gio.h>';

  /// Matches the helper definition/call, but not a longer identifier that
  /// merely ends with the helper name (e.g. `my_get_flutter_asset_path(`).
  static final _helperRefRegex = RegExp(
    '(^|[^A-Za-z0-9_])' + _assetHelperName + r'\s*\(',
    multiLine: true,
  );

  static const _assetHelperTemplate = r'''
static gchar* get_flutter_asset_path(const gchar* asset_path) {
  g_autofree gchar* executable = g_file_read_link("/proc/self/exe", NULL);
  if (executable == NULL) {
    return g_strdup(asset_path);
  }
  g_autofree gchar* executable_dir = g_path_get_dirname(executable);
  return g_build_filename(executable_dir, "data", "flutter_assets", asset_path, NULL);
}
''';

  /// Builds the canonical 2-line call block for [iconPath] with [indent].
  static List<String> _canonicalBlock(String iconPath, String indent) {
    return [
      '${indent}g_autofree gchar* $_iconVarName = $_assetHelperName("$iconPath");',
      '${indent}gtk_window_set_icon_from_file(window, $_iconVarName, NULL);',
    ];
  }

  Future<void> _updateMyApplicationFile(String iconPath) async {
    final myAppFile =
        File(path.join(context.prefixPath, constants.linuxMyApplicationFile));

    if (!myAppFile.existsSync()) {
      context.logger.error(
        'my_application.cc file not found at ${constants.linuxMyApplicationFile}',
      );
      throw FileNotFoundException(constants.linuxMyApplicationFile);
    }

    var content = await myAppFile.readAsString();

    // Canonical block already present -> check path, update or no-op.
    if (_helperRefRegex.hasMatch(content)) {
      final canonicalPathRegex = RegExp(
        // ignore: prefer_single_quotes
        RegExp.escape(_assetHelperName) + r'\s*\(\s*"([^"]+)"\s*\)',
      );
      final canonicalMatch = canonicalPathRegex.firstMatch(content);
      if (canonicalMatch != null) {
        final currentPath = canonicalMatch.group(1)!;
        if (currentPath == iconPath) {
          context.logger.verbose(
            'Icon configuration already exists with correct path: $iconPath',
          );
          // Still ensure helper + include are present (e.g. hand-edited file).
          final updated = _ensureHelperAndInclude(content);
          if (updated != content) {
            await myAppFile.writeAsString(updated);
          }
          return;
        } else {
          context.logger.verbose(
            'Updating icon configuration from "$currentPath" to "$iconPath"',
          );
          var updated = content.replaceAll(
            canonicalPathRegex,
            '$_assetHelperName("$iconPath")',
          );
          updated = _ensureHelperAndInclude(updated);
          await myAppFile.writeAsString(updated);
          context.logger.verbose(
            'Updated my_application.cc with new icon configuration: $iconPath',
          );
          return;
        }
      }
    }

    // Legacy single/multi-line call present -> upgrade to canonical block,
    // taking the path from the manual call only for logging; we always
    // rewrite to the configured iconPath.
    final existingIconRegex = RegExp(
      r'gtk_window_set_icon_from_file\s*\(\s*[^;]*;',
      multiLine: true,
      dotAll: true,
    );
    final existingIconMatch = existingIconRegex.firstMatch(content);
    if (existingIconMatch != null) {
      final existingIconStatement = existingIconMatch.group(0)!;
      // Skip if this is already the canonical second line (uses variable).
      if (!existingIconStatement.contains(_iconVarName)) {
        final iconPathRegex = RegExp(r'"([^"]+)"');
        final iconPathMatch = iconPathRegex.firstMatch(existingIconStatement);
        final currentIconPath = iconPathMatch?.group(1);
        context.logger.verbose(
          currentIconPath == null
              ? 'Upgrading icon configuration to exe-relative block: $iconPath'
              : 'Upgrading icon configuration from "$currentIconPath" to "$iconPath"',
        );
        var updated = _ensureHelperAndInclude(content);
        updated = _replaceLegacyCall(updated, existingIconRegex, iconPath);
        await myAppFile.writeAsString(updated);
        context.logger.verbose(
          'Updated my_application.cc with new icon configuration: $iconPath',
        );
        return;
      } else {
        // Canonical call line exists but helper-call regex missed (should be
        // rare) -> just ensure helper + include.
        final updated = _ensureHelperAndInclude(content);
        if (updated != content) {
          await myAppFile.writeAsString(updated);
        }
        return;
      }
    }

    // No existing icon configuration found - need to add it
    context.logger.verbose('Adding new icon configuration: $iconPath');

    content = _ensureHelperAndInclude(content);
    final lines = content.split('\n');
    var modified = false;

    void insertAt(int index, String indent) {
      final block = _canonicalBlock(iconPath, indent);
      lines.insertAll(index, block);
    }

    // Strategy 1: Find gtk_window_set_default_size and insert before it
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('gtk_window_set_default_size')) {
        final currentLine = lines[i];
        final leadingWhitespace =
            RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';
        insertAt(i, leadingWhitespace);
        modified = true;
        break;
      }
    }

    // Strategy 2: Find window variable declaration and insert after it
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('GtkWindow* window =') ||
            lines[i].contains('GtkWindow *window =')) {
          // Find the end of the window declaration (look for semicolon)
          int declarationEndIndex = i;
          while (declarationEndIndex < lines.length &&
              !lines[declarationEndIndex].contains(';')) {
            declarationEndIndex++;
          }

          // Insert after the window declaration
          final int insertIndex = declarationEndIndex + 1;

          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          insertAt(insertIndex, leadingWhitespace);
          modified = true;
          break;
        }
      }
    }

    // Strategy 3: Find gtk_window_show and insert before it
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('gtk_window_show') ||
            lines[i].contains('gtk_widget_show')) {
          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          insertAt(i, leadingWhitespace);
          modified = true;
          break;
        }
      }
    }

    // Strategy 4: Find any gtk_window function call and insert nearby
    if (!modified) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('gtk_window_') &&
            !lines[i].contains('gtk_window_set_icon_from_file')) {
          // Find proper indentation
          final currentLine = lines[i];
          final leadingWhitespace =
              RegExp(r'^(\s*)').firstMatch(currentLine)?.group(1) ?? '  ';

          insertAt(i + 1, leadingWhitespace);
          modified = true;
          break;
        }
      }
    }

    if (modified) {
      await myAppFile.writeAsString(lines.join('\n'));
      context.logger.verbose(
        'Updated my_application.cc with icon configuration: $iconPath',
      );
    } else {
      // The 2-line call depends on the asset-path helper and the gio
      // include, so spell out all three pieces for a manual fix.
      final errorMessage =
          'Could not find appropriate location to add icon configuration in my_application.cc. '
          'Please manually update it as follows:\n'
          '1. Add $_gioInclude alongside the other includes (if missing).\n'
          '2. Add this helper before my_application_activate:\n'
          '${_assetHelperTemplate.trim()}\n'
          '3. Add these lines after the window creation:\n'
          '  g_autofree gchar* linux_icon_path = get_flutter_asset_path("$iconPath");\n'
          '  gtk_window_set_icon_from_file(window, linux_icon_path, NULL);';
      context.logger.error(errorMessage);
      throw Exception('Failed to update my_application.cc. $errorMessage');
    }
  }

  /// Ensures `#include <gio/gio.h>` and the asset-path helper are present.
  String _ensureHelperAndInclude(String content) {
    var updated = content;
    if (!updated.contains(_gioInclude)) {
      final lines = updated.split('\n');
      final lastInclude =
          lines.lastIndexWhere((l) => l.trimLeft().startsWith('#include'));
      if (lastInclude != -1) {
        lines.insert(lastInclude + 1, _gioInclude);
      } else {
        lines.insert(0, _gioInclude);
      }
      updated = lines.join('\n');
    }
    if (!_helperRefRegex.hasMatch(updated) ||
        !updated.contains('g_file_read_link("/proc/self/exe"')) {
      // Insert helper before my_application_activate when possible.
      const anchor = 'static void my_application_activate';
      final anchorIndex = updated.indexOf(anchor);
      if (anchorIndex != -1) {
        updated = updated.replaceFirst(
          anchor,
          '${_assetHelperTemplate.trim()}\n\n$anchor',
        );
      } else {
        updated = '${_assetHelperTemplate.trim()}\n\n$updated';
      }
    }
    return updated;
  }

  /// Replaces a legacy `gtk_window_set_icon_from_file(...)` statement with
  /// the canonical 2-line exe-relative block, preserving indentation.
  String _replaceLegacyCall(
    String content,
    RegExp legacyRegex,
    String iconPath,
  ) {
    final match = legacyRegex.firstMatch(content);
    if (match == null) {
      return content;
    }
    final statement = match.group(0)!;
    // Derive indentation from the start of the matched statement.
    final before = content.substring(0, match.start);
    final lineStart = before.lastIndexOf('\n') + 1;
    final linePrefix = content.substring(lineStart, match.start);
    final indentMatch = RegExp(r'^(\s*)').firstMatch(linePrefix + statement);
    final indent = indentMatch?.group(1) ?? '  ';
    final block = _canonicalBlock(iconPath, indent).join('\n');
    return content.replaceFirst(legacyRegex, block);
  }
}
