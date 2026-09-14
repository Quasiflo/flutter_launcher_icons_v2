import 'package:launcher_icons/src/cli.dart' as launcher_icons;
import 'package:launcher_icons/src/core/constants.dart';
import 'package:launcher_icons/src/version.dart';

void main(List<String> arguments) {
  print(introMessage(packageVersion));
  launcher_icons.createIconsFromArguments(arguments);
}
