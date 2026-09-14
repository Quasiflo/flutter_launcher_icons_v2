import 'package:launcher_icons/constants.dart';
import 'package:launcher_icons/main.dart' as launcher_icons;
import 'package:launcher_icons/src/version.dart';

void main(List<String> arguments) {
  print(introMessage(packageVersion));
  launcher_icons.createIconsFromArguments(arguments);
}
