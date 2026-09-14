import 'package:test/test.dart';

import 'abs/icon_generator_test.dart' as icon_generator_test;
import 'android_test.dart' as android_test;
import 'cli_flavor_test.dart' as cli_flavor_test;
import 'config_test.dart' as fli_config;
import 'custom_exceptions_test.dart' as custom_exceptions_test;
import 'ios/ios_change_icon_test.dart' as ios_change_icon_test;
import 'ios/ios_liquid_glass_test.dart' as ios_liquid_glass_test;
import 'ios/ios_pbxproj_test.dart' as ios_pbxproj_test;
import 'ios/ios_remove_alpha_test.dart' as ios_remove_alpha_test;
import 'linux/linux_icon_generator_test.dart' as linux_icon_gen_test;
import 'macos/macos_icon_effects_test.dart' as macos_effects_test;
import 'macos/macos_icon_generator_test.dart' as macos_icons_gen_test;
import 'macos/macos_icon_template_test.dart' as macos_template_test;
import 'main_test.dart' as main_test;
import 'utils_test.dart' as utils_test;
import 'web/web_icon_generator_test.dart' as web_icon_gen_test;
import 'web/web_template_test.dart' as web_template_test;
import 'windows/windows_icon_generator_test.dart' as windows_icon_gen_test;

void main() {
  group('Launcher icons', () {
    // others
    utils_test.main();
    fli_config.main();
    custom_exceptions_test.main();
    icon_generator_test.main();

    main_test.main();
    cli_flavor_test.main();
    // android
    android_test.main();
    // ios
    ios_change_icon_test.main();
    ios_liquid_glass_test.main();
    ios_pbxproj_test.main();
    ios_remove_alpha_test.main();
    // web
    web_template_test.main();
    web_icon_gen_test.main();
    // windows
    windows_icon_gen_test.main();
    // macos
    macos_template_test.main();
    macos_effects_test.main();
    macos_icons_gen_test.main();
    // linux
    linux_icon_gen_test.main();
  });
}
