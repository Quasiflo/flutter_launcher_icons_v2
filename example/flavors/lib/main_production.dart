import 'package:example_with_flavors/main.dart' as app;

/// Production entrypoint: `flutter run --flavor production -t lib/main_production.dart`.
void main() => app.runFlavor(app.Flavor.production);
