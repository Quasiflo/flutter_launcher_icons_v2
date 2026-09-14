# Flavors Example

A complete, runnable Flutter app (fresh `flutter create` template) with two
flavors — **development** and **production** — and a `launcher_icons-*` config
that fills in **every option for every platform**. Generated outputs are
checked in, so you can inspect exactly what each key produces.

## Run the Icon Generation

```shell
cd example/flavors
dart pub get
dart run launcher_icons -f launcher_icons-development.yaml
dart run launcher_icons -f launcher_icons-production.yaml
```

The flavor is discovered from the file name (`launcher_icons-<flavor>.yaml`).

## Run the App

```shell
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor production -t lib/main_production.dart
```

## What Each Flavor Shows Off

| Area | development (transparency showcase) | production (opaque + glass showcase) |
| --- | --- | --- |
| Source art | Transparent PNG: alpha-gradient disc + translucent stripe | Opaque full-bleed RGB gradient (no alpha channel) |
| Android | `transparent` adaptive background keyword (no `colors.xml` entry), foreground inset, monochrome, **round icon** (`android:roundIcon` wiring), **Play Store sidecar** (`play_store_icon.png` at the root) | Image adaptive background, tighter inset, round icon, no sidecar |
| iOS | `remove_alpha` matte blended onto `#123456`, transparent dark variant (system bg shows through), desaturated tinted variant, `flavor_mode: pbxproj` (rewrites `ASSETCATALOG_COMPILER_APPICON_NAME`) | Opaque art, `remove_alpha: false`, per-appearance glass layers + refractivity/lighting/specular placement, `flavor_mode: xcconfig` (`ios/Flutter/production-*.xcconfig` — assign as base configuration files in Xcode once) |
| Web | Dedicated maskable source, `favicon.ico` (16+32+48) + PNG, separate `web_development/` root | No maskable source → padded fallback derivation (watch for the warning), PNG-only favicon, separate `web_production/` root |
| Windows | Per-flavor `app_icon_development.ico` (matches `Runner.rc.in`) | Default `app_icon.ico` |
| macOS | `padding: 10` + `rounded_corners` squircle mask | Defaults (square, opaque) |
| Linux | Window icon + hicolor tree + `.desktop` + snap packaging | Same targets (strictly only-if-absent, so the first run wins) |

`icon_name` is deliberately absent from both configs: under flavors the
catalog is always `AppIcon-<flavor>` (iOS/macOS) / `src/<flavor>/res`
(Android), so a custom name would be ignored.

## Native Flavor Wiring (Current Flutter Pattern)

- **pubspec**: `flutter.default-flavor: development`.
- **Android** (`android/app/build.gradle.kts`): `productFlavors` with
  `applicationIdSuffix` + `app_name` res value; `AndroidManifest.xml` uses
  `@string/app_name`. Matches `docs.flutter.dev/deployment/flavors`.
- **iOS/macOS**: per-flavor build configurations (`Debug-development`, …)
  carrying `APP_DISPLAY_NAME` + flavor bundle-id suffix, one scheme per
  flavor, `Info.plist` display name `$(APP_DISPLAY_NAME)`. The tool's
  `pbxproj` mode wires configurations that share the base `.xcconfig`.
- **Linux**: `FLUTTER_APP_FLAVOR` application-id branches + window-title
  switch in `my_application.cc`.
- **Windows**: `Runner.rc.in` / `main.cpp.in` templates configured with the
  per-flavor title and icon name. Matches
  `docs.flutter.dev/deployment/flavors-windows`.
- **Web**: no native flavors upstream; separation is via per-flavor
  `output_path`. Serve that directory when building
  (`flutter build web` serves `web/` unless reconfigured).

## Regenerating from Scratch

Delete the generated outputs (or run the two commands above — every writer
is idempotent) and re-run. The per-platform sources live under
`assets/icon/` (`*-dev*` transparent set, `*-prod*` opaque set +
`*-glass*` liquid-glass layers).
