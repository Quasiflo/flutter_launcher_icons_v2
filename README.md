# Flutter Launcher Icons

[![pub package](https://img.shields.io/pub/v/launcher_icons.svg)](https://pub.dev/packages/launcher_icons)

> **A maintained fork of [fluttercommunity/flutter_launcher_icons](https://github.com/fluttercommunity/flutter_launcher_icons).** Thank you to [@MarkOSullivan94](https://github.com/MarkOSullivan94) and all the original contributors for building the tool this continues. Bug reports, ideas, and pull requests are welcome here — see [CONTRIBUTING.md](CONTRIBUTING.md).

A command-line tool that generates your Flutter app's launcher icons from a source image. Pick which platforms to generate with `generate: true`, and use `icon_name` when you want a new icon alongside the old one instead of replacing it.

## Quickstart

Add the dependency and generate a starter config:

<!-- x-release-please-start-version -->

```yaml
dev_dependencies:
  launcher_icons: "^0.14.4"
```

<!-- x-release-please-end -->

```shell
dart run launcher_icons:generate
```

This writes `launcher_icons.yaml` in your project root. Or skip the file and configure inside `pubspec.yaml` — both work. See [the examples](https://github.com/Quasiflo/launcher_icons/tree/main/example) for complete projects.

Then run the tool:

```shell
flutter pub get
dart run launcher_icons
```

Your config file must sit next to `pubspec.yaml`. With `-f` you can point at a differently named file for both commands:

```shell
dart run launcher_icons:generate -f my_icons.yaml
dart run launcher_icons -f my_icons.yaml
```

## Source Image

Use one high-resolution **PNG** — **1024×1024 recommended**. Everything is downscaled from it (iOS needs the 1024px App Store icon), so starting smaller loses quality. JPG/JPEG/WebP are only accepted for Android adaptive backgrounds. All outputs are PNG, except the Windows `.ico`.

| Platform | What gets generated |
| --- | --- |
| Android legacy | 48, 72, 96, 144, 192 (`mipmap-mdpi` → `mipmap-xxxhdpi`) |
| Android adaptive | 108, 162, 216, 324, 432 foreground (`drawable-*`) + `mipmap-anydpi-v26` XML |
| iOS | 20 – 1024, plus optional dark, tinted, and liquid-glass variants |
| Web | 192, 512 (+ maskable), 180px apple-touch-icon, favicon PNG + multi-size ICO |
| Windows | `.ico` with 16, 24, 32, 40, 48, 64, 256px frames |
| macOS | 16 – 1024 (`@1x`/`@2x` sets) |
| Linux | hicolor tree (16–512), `.desktop` entries, `snap/` packaging, X11 window icon |

## Configuration

Top-level `image_path` is the default for every platform; any platform-level `image_path` overrides it. Paths must be local files (PNG, JPG/JPEG/WebP where noted, or SVG). Top-level `svg_rasterize_per_size` (`false` by default, see Source Image) applies to every SVG source.

### Android

- `generate`, `image_path`, `icon_name` — a custom name (e.g. `"ic_launcher"`) creates a new icon without removing the default, and updates `AndroidManifest.xml`.
- `adaptive_icon_background` — hex color (`"#ffffff"`), `"transparent"` (no `colors.xml` entry), or image (png/jpg/jpeg/webp). Adaptive icons need this **and** `adaptive_icon_foreground`; `image_path` is never used as the foreground.
- `adaptive_icon_foreground` — foreground image. Inset with `adaptive_icon_foreground_inset` (percent, default `16`). Without both keys, round launchers may show your square icon inside a white circle — the tool never auto-rounds or pads.
- `adaptive_icon_monochrome` — Android 13+ themed-icon silhouette. Inset `0` emits the canonical plain `<monochrome android:drawable>` form. See [Android Adaptive Icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive).
- `adaptive_icon_round` — opt-in round icon: drawables, `ic_launcher_round.xml`, and `android:roundIcon` wiring.
- `play_store_icon` — off by default. When `true`, writes a 512px `play_store_icon.png` sidecar next to the project for store upload (never into `android/res`; warns past the 1024KB budget).

### iOS

- `generate`, `image_path`, `icon_name` (own `<name>.appiconset`, like flavors), `xcodeproj_path` (default `"ios/Runner.xcodeproj"`), `single_size` (one 1024px icon; dark/tinted ignored; default `false`).
- `remove_alpha` — blends transparency onto `background_color` (`"#RRGGBB"`, default `"#ffffff"`; only used when removing alpha). The dark variant keeps its transparency (Apple shows the system background through it); the tinted variant is forced opaque.
- `image_path_dark_transparent`, `image_path_tinted_grayscale`, `desaturate_tinted_to_grayscale` (default `false`) — iOS 18+ variants. See [Apple's app-icon guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons#iOS-iPadOS). Fill the whole image; transparent borders render black.
- `flavor_mode` — `"pbxproj"` (default) rewrites `ASSETCATALOG_COMPILER_APPICON_NAME` per build configuration; `"xcconfig"` writes `ios/Flutter/<flavor>-<Mode>.xcconfig` overrides instead (assign them as base configuration files in Xcode once).
- Liquid glass (writes a `.icon` bundle for Apple's Icon Composer alongside the PNG catalog, which stays the fallback on older systems): `image_path_liquid_glass_icon` (enables it; SVGs pass through), `image_path_liquid_glass_icon_dark` / `_tinted` (fall back to the dark/tinted sources), `remove_liquid_glass`, `liquid_glass_icon_scale` (1.0), `liquid_glass_translucency` (0.5), `liquid_glass_specular` (true), `liquid_glass_shadow_kind` (`"Neutral"`/`"Chromatic"`), `liquid_glass_shadow_opacity` (0.5), `liquid_glass_blur` (0.5), `liquid_glass_offset_x` / `_y` (0.0), `liquid_glass_lighting` (`"individual"`/`"combined"`), `liquid_glass_refractivity_enabled` (+ `liquid_glass_refractivity_depth` / `_strength`), `liquid_glass_specular_highlight_placement` (`"inside"`/`"outside"`).

After generating, Xcode must point at the set: `Build Settings` > `Asset Catalog App Icon Set Name` (`AppIcon`, or `AppIcon-<flavor>`).

### Web

- `generate`, `image_path`, `image_path_favicon` (falls back to the web, then global, image), `image_path_maskable` (safe-zone-aware source; otherwise a padded derivation off the logo at ~80% on the opaque `background_color`).
- `favicon_size` (PNG size, default `16`; the `.ico` always holds 16+32+48), `favicon_ico` (default `true`; `false` ships the PNG only).
- `output_path` (web root, default `web`; set per flavor to keep outputs apart — serve that directory when building).
- `background_color` / `theme_color` — must be hex. Written to `web/manifest.json` (background also flattens the opaque 180px `apple-touch-icon.png`; theme also adds the `<meta name="theme-color">` tag). The tool manages one `<!--LI-->…<!--LIEND-->` block in `index.html`.

### Windows

- `generate`, `image_path` (sources under 256px warn about upscaling), `icon_filename` (default `app_icon.ico`, the `Runner.rc` contract — set per flavor so runs don't clobber each other, and wire it into `Runner.rc(.in)`).

### macOS

- `generate`, `image_path`, `padding` (safe-area margin as % per side, default `0`), `rounded_corners` (continuous-corner squircle mask, default `false`). Flavors write `AppIcon-<flavor>.appiconset`; select it in Xcode like iOS. Transparency is preserved, never filled — prefer opaque art.
- Liquid glass (writes a `.icon` bundle for Apple's Icon Composer next to the PNG catalog, which stays the fallback on macOS older than Tahoe 26 — same document format and options as iOS): `image_path_liquid_glass_icon` (enables it; SVGs pass through), `image_path_liquid_glass_icon_dark` / `_tinted` (no fallbacks — macOS has no dark/tinted catalog variants), `remove_liquid_glass`, `background_color` (`#ffffff`), `liquid_glass_icon_scale` (1.0), `liquid_glass_translucency` (0.5), `liquid_glass_specular` (true), `liquid_glass_shadow_kind` (`"Neutral"`/`"Chromatic"`), `liquid_glass_shadow_opacity` (0.5), `liquid_glass_blur` (0.5), `liquid_glass_offset_x` / `_y` (0.0), `liquid_glass_lighting` (`"individual"`/`"combined"`), `liquid_glass_refractivity_enabled` (+ `liquid_glass_refractivity_depth` / `_strength`), `liquid_glass_specular_highlight_placement` (`"inside"`/`"outside"`).

After generating, add `<name>.icon` to the Xcode project (the tool registers the file reference in `project.pbxproj` automatically) and set the target's App Icon to it; the PNG set keeps working untouched.

### Linux

- `generate`, `image_path` — must be declared under `flutter: assets:` in `pubspec.yaml` (any asset path, not just `assets/`) so it ships inside the bundle. Emits the hicolor tree, `.desktop` entries, and `snap/` files — each strictly only-if-absent — and patches `my_application.cc` with an executable-relative icon path that works under `flutter run` and in release bundles.

## Flavors

Declare each variant as a `launcher_icons-<flavor>` section in your config file or `pubspec.yaml`. Each section stands alone with the same shape as `launcher_icons:`:

```yaml
launcher_icons-dev:
  image_path: "assets/icon/icon-dev.png"
  android:
    generate: true
launcher_icons-prod:
  image_path: "assets/icon/icon-prod.png"
  android:
    generate: true
```

```shell
dart run launcher_icons                  # every flavor
dart run launcher_icons --flavor dev     # one flavor
```

One `launcher_icons-<flavor>.yaml` file per flavor works too; a file wins over a section with the same name. `icon_name` is ignored inside flavor configs — the catalog is always `AppIcon-<flavor>` / `src/<flavor>/res`. See the [flavors example](https://github.com/Quasiflo/launcher_icons/tree/main/example/flavors) for the full native setup (schemes, bundle ids, display names) on every platform.

## Command-Line Options

| Option | Description |
| --- | --- |
| `-f, --file <path>` | Config file. Defaults to `launcher_icons.yaml` |
| `-o, --override` | Overwrite the `:generate` output file |
| `-v, --verbose` | Verbose output |
| `-p, --prefix <path>` | Project root. Defaults to the current directory |
| `--flavor-path <path>` | Where to search for flavor files (recursive). Defaults to `.` |
| `--flavor <name>` | Run a single flavor from a section or file |

Exit codes: `0` success, `1` a platform failed, `2` bad config or CLI usage. A failed platform never reports success, and every platform runs before the command exits.

## Troubleshooting

**Old icon still shows after regenerating.** The files are usually right and a cache is stale: `flutter clean`, uninstall the app from the device/emulator, rebuild. iOS: re-check `Asset Catalog App Icon Set Name`. Android flavors: delete leftover `mipmap-anydpi-v26/ic_launcher.xml` under `src/main/` shadowing the flavor resources.

Anything else: [open an issue](https://github.com/Quasiflo/launcher_icons/issues).

## Credits

Icon resizing via Brendan Duncan's [image package](https://pub.dev/packages/image). Full history and attributions in [CHANGELOG.md](CHANGELOG.md) and the [upstream repository](https://github.com/fluttercommunity/flutter_launcher_icons).
