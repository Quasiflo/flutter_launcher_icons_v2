// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:flutter_launcher_icons/android.dart' as android_launcher_icons;
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart' as ios_launcher_icons;
import 'package:flutter_launcher_icons/linux/linux_icon_generator.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/macos/macos_icon_generator.dart';
import 'package:flutter_launcher_icons/web/web_icon_generator.dart';
import 'package:flutter_launcher_icons/windows/windows_icon_generator.dart';
import 'package:path/path.dart' as path;

const String fileOption = 'file';
const String helpFlag = 'help';
const String verboseFlag = 'verbose';
const String prefixOption = 'prefix';
const String defaultConfigFile = 'flutter_launcher_icons.yaml';
const String flavorConfigFilePattern = r'^flutter_launcher_icons-(.*).yaml$';

Future<List<String>> getFlavors({String searchPath = '.'}) async {
  final List<String> flavors = [];

  // Recursively search through directories
  await for (var item in Directory(searchPath).list(recursive: true)) {
    if (item is File) {
      final name = path.basename(item.path);
      final match = RegExp(flavorConfigFilePattern).firstMatch(name);
      if (match != null) {
        flavors.add(match.group(1)!);
      }
    }
  }
  return flavors;
}

/// Returns the flavor named by an explicit `-f flutter_launcher_icons-<flavor>.yaml`
/// argument, or `null` when `-f` does not point at a flavor config file.
String? explicitFlavorFromArgs(ArgResults argResults) {
  final String filePath = argResults[fileOption] as String;
  final match =
      RegExp(flavorConfigFilePattern).firstMatch(path.basename(filePath));
  return match?.group(1);
}

Future<void> createIconsFromArguments(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser
    ..addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false)
    // Make default null to differentiate when it is explicitly set
    ..addOption(
      fileOption,
      abbr: 'f',
      help: 'Path to config file',
      defaultsTo: defaultConfigFile,
    )
    ..addFlag(verboseFlag, abbr: 'v', help: 'Verbose output', defaultsTo: false)
    ..addOption(
      prefixOption,
      abbr: 'p',
      help: 'Generates config in the given path. Only Supports web platform',
      defaultsTo: '.',
    )
    ..addOption(
      'flavor-path',
      help: 'Path to search for flavor configuration files',
      defaultsTo: '.',
    );

  final ArgResults argResults = parser.parse(arguments);
  // creating logger based on -v flag
  final logger = FLILogger(argResults[verboseFlag]);

  logger.verbose('Received args ${argResults.arguments}');

  if (argResults[helpFlag]) {
    stdout.writeln('Generates icons for iOS and Android');
    stdout.writeln(parser.usage);
    exit(0);
  }

  // Flavors management
  final String prefixPath = argResults[prefixOption];

  // An explicit `-f flutter_launcher_icons-<flavor>.yaml` runs only that
  // flavor instead of looping over every discovered flavor (#215).
  // The file is loaded from the given path directly, so flavor configs in
  // subdirectories work too.
  final onlyFlavor = explicitFlavorFromArgs(argResults);
  if (onlyFlavor != null) {
    final String filePath = argResults[fileOption] as String;
    final flutterLauncherIconsConfigs = Config.loadConfigFromPath(
      filePath,
      prefixPath,
    );
    if (flutterLauncherIconsConfigs == null) {
      throw NoConfigFoundException(
        'No configuration found for $onlyFlavor flavor at $filePath. '
        'To discover flavor files in subdirectories use --flavor-path.',
      );
    }
    try {
      print('\nFlavor: $onlyFlavor');
      await createIconsFromConfig(
        flutterLauncherIconsConfigs,
        logger,
        prefixPath,
        onlyFlavor,
      );
      print('\n✓ Successfully generated launcher icons');
    } catch (e) {
      stderr.writeln('\n✕ Could not generate launcher icons');
      stderr.writeln(e);
      exit(2);
    }
    return;
  }

  final flavors = await getFlavors(searchPath: argResults['flavor-path']);
  final hasFlavors = flavors.isNotEmpty;

  // Create icons
  if (!hasFlavors) {
    // Load configs from given file(defaults to ./flutter_launcher_icons.yaml) or from ./pubspec.yaml

    final flutterLauncherIconsConfigs = loadConfigFileFromArgResults(
      argResults,
      explicitFile: isFileOptionExplicit(arguments),
    );
    if (flutterLauncherIconsConfigs == null) {
      throw NoConfigFoundException(
        'No configuration found in $defaultConfigFile or in ${constants.pubspecFilePath}. '
        'In case file exists in different directory use --file option',
      );
    }
    try {
      await createIconsFromConfig(
        flutterLauncherIconsConfigs,
        logger,
        prefixPath,
      );
      print('\n✓ Successfully generated launcher icons');
    } catch (e) {
      stderr.writeln('\n✕ Could not generate launcher icons');
      stderr.writeln(e);
      exit(2);
    }
  } else {
    try {
      for (String flavor in flavors) {
        print('\nFlavor: $flavor');
        final flutterLauncherIconsConfigs =
            Config.loadConfigFromFlavor(flavor, prefixPath);
        if (flutterLauncherIconsConfigs == null) {
          throw NoConfigFoundException(
            'No configuration found for $flavor flavor.',
          );
        }
        await createIconsFromConfig(
          flutterLauncherIconsConfigs,
          logger,
          prefixPath,
          flavor,
        );
      }
      print('\n✓ Successfully generated launcher icons for flavors');
    } catch (e) {
      stderr.writeln('\n✕ Could not generate launcher icons for flavors');
      stderr.writeln(e);
      exit(2);
    }
  }
}

Future<void> createIconsFromConfig(
  Config flutterConfigs,
  FLILogger logger,
  String prefixPath, [
  String? flavor,
]) async {
  if (!flutterConfigs.hasPlatformConfig) {
    throw const InvalidConfigException(errorMissingPlatform);
  }

  final concurrentIconCreation = <Future<void>>[];
  if (flutterConfigs.isNeedingNewAndroidIcon) {
    concurrentIconCreation
        .add(android_launcher_icons.createDefaultIcons(flutterConfigs, flavor));
  }
  if (flutterConfigs.hasAndroidAdaptiveConfig) {
    concurrentIconCreation.add(
        android_launcher_icons.createAdaptiveIcons(flutterConfigs, flavor));
  }
  if (flutterConfigs.hasAndroidAdaptiveMonochromeConfig) {
    concurrentIconCreation.add(
      android_launcher_icons.createAdaptiveMonochromeIcons(
        flutterConfigs,
        flavor,
      ),
    );
  }
  await Future.wait(concurrentIconCreation);
  if (flutterConfigs.isNeedingNewAndroidIcon) {
    await android_launcher_icons.createMipmapXmlFile(
      flutterConfigs,
      flavor,
    );
  }
  if (flutterConfigs.isNeedingNewIOSIcon) {
    await ios_launcher_icons.createIcons(flutterConfigs, flavor);
  }

  // Generates Icons for given platform
  await generateIconsFor(
    config: flutterConfigs,
    logger: logger,
    prefixPath: prefixPath,
    flavor: flavor,
    platforms: (context) {
      final platforms = <IconGenerator>[];
      if (flutterConfigs.hasWebConfig) {
        platforms.add(WebIconGenerator(context));
      }
      if (flutterConfigs.hasWindowsConfig) {
        platforms.add(WindowsIconGenerator(context));
      }
      if (flutterConfigs.hasMacOSConfig) {
        platforms.add(MacOSIconGenerator(context));
      }
      if (flutterConfigs.hasLinuxConfig) {
        platforms.add(LinuxIconGenerator(context));
      }
      return platforms;
    },
  );
}

Config? loadConfigFileFromArgResults(
  ArgResults argResults, {
  bool explicitFile = false,
}) {
  final String prefixPath = argResults[prefixOption];
  final String filePath = argResults[fileOption] as String;
  final flutterLauncherIconsConfigs = Config.loadConfigFromPath(
        filePath,
        prefixPath,
      ) ??
      Config.loadConfigFromPubSpec(prefixPath);
  if (flutterLauncherIconsConfigs == null) {
    return null;
  }
  // #628: an unedited `:generate` template still points at the phantom
  // `assets/icon/icon.png`. When the default config file is in play (not an
  // explicit `-f`) and none of its images exist while pubspec's do, the stale
  // template is shadowing the real config — warn and prefer pubspec.
  // An explicitly requested file is always honored, with a warning.
  if (filePath == defaultConfigFile) {
    final pubspecConfigs = Config.loadConfigFromPubSpec(prefixPath);
    if (pubspecConfigs != null &&
        !_hasExistingImage(flutterLauncherIconsConfigs, prefixPath) &&
        _hasExistingImage(pubspecConfigs, prefixPath)) {
      stderr.writeln(
        'Warning: $defaultConfigFile looks like an unedited generated template '
        '(its icon files were not found) while pubspec.yaml declares icons that exist. ' +
            (explicitFile
                ? 'Continuing with $defaultConfigFile as requested.'
                : 'Using pubspec.yaml instead. '
                    'Delete $defaultConfigFile or pass -f to be explicit.'),
      );
      if (!explicitFile) {
        return pubspecConfigs;
      }
    }
  }
  return flutterLauncherIconsConfigs;
}

/// Whether `-f`/`--file` was explicitly passed on the command line.
bool isFileOptionExplicit(List<String> arguments) {
  return arguments.any(
    (arg) =>
        arg == '-f' ||
        arg == '--file' ||
        arg.startsWith('--file=') ||
        arg.startsWith('-f='),
  );
}

/// Whether any image referenced by [config] exists under [prefixPath].
bool _hasExistingImage(Config config, String prefixPath) {
  final candidates = <String?>[
    config.imagePath,
    config.androidConfig?.imagePath,
    config.iosConfig?.imagePath,
    config.webConfig?.imagePath,
    config.windowsConfig?.imagePath,
    config.macOSConfig?.imagePath,
    config.linuxConfig?.imagePath,
  ];
  return candidates
      .whereType<String>()
      .any((image) => File(path.join(prefixPath, image)).existsSync());
}
