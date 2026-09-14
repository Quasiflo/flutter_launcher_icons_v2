# Flutter Launcher Icons

[![Flutter Community: launcher_icons](https://fluttercommunity.dev/_github/header/launcher_icons)](https://github.com/fluttercommunity/community)

[![pub package](https://img.shields.io/pub/v/launcher_icons.svg)](https://pub.dartlang.org/packages/launcher_icons)

A command-line tool which simplifies the task of updating your Flutter app's launcher icon. Fully flexible, allowing you to choose what platform you wish to update the launcher icon for and if you want, the option to keep your old launcher icon in case you want to revert back sometime in the future.

<!-- rumdl-disable-next-line MD063 -->
## :book: Guide

### 1. Setup the Config File

Run the following command to create a new config automatically:

```shell
dart run launcher_icons:generate
```

This will create a new file called `launcher_icons.yaml` in your `flutter` project's root directory.

If you want to override the default location or name of the config file, use the `-f` flag:

```shell
dart run launcher_icons:generate -f <your config file name here>
```

To override an existing config file, use the `-o` flag:

```shell
dart run launcher_icons:generate -o
```

OR

Add your Flutter Launcher Icons configuration to your `pubspec.yaml`.  
An example is shown below. More complex examples [can be found in the example projects](https://github.com/Quasiflo/launcher_icons/tree/master/example).

```yaml
dev_dependencies:
  launcher_icons: "^0.14.4" # x-release-please-version

launcher_icons:
  image_path: "assets/icon/icon.png"
  android:
    generate: true
    # image_path: "assets/icon/icon-android.png"
    # icon_name: "launcher_icon" # generate a new icon without removing the old default
    # adaptive_icon_background: "assets/icon/background.png"  # color or png/jpg/jpeg/webp image
    # adaptive_icon_foreground: "assets/icon/foreground.png"
    # adaptive_icon_foreground_inset: 16
    # adaptive_icon_monochrome: "assets/icon/monochrome.png"
    # adaptive_icon_round: "assets/icon/round.png" # opt-in round icon + manifest roundIcon
    # play_store_icon: true # 512px store-upload sidecar next to the project, off by default
  ios:
    generate: true
    # single_size: true # single 1024px icon; dark/tinted variants are ignored
    # image_path: "assets/icon/icon-ios.png"
    # icon_name: "My-Launcher-Icon" # generate a new icon without removing the old default
    # xcodeproj_path: "ios/Runner.xcodeproj" # set when the Xcode project was renamed
    # flavor_mode: "xcconfig" # "pbxproj" (default) or "xcconfig" flavor wiring
    remove_alpha: true
    # background_color: "#ffffff"
    # image_path_dark_transparent: "assets/icon/icon_dark.png"
    # image_path_tinted_grayscale: "assets/icon/icon_tinted.png"
    # desaturate_tinted_to_grayscale: true
    # iOS Liquid Glass Icon (optional)
    # image_path_liquid_glass_icon: "assets/icon/liquid_glass_icon.png"
    # image_path_liquid_glass_icon_dark: "assets/icon/liquid_glass_icon_dark.png"
    # image_path_liquid_glass_icon_tinted: "assets/icon/liquid_glass_icon_tinted.png"
    # remove_liquid_glass: true # flat icon without glass effects
    # liquid_glass_icon_scale: 1.0
    # liquid_glass_translucency: 0.5
    # liquid_glass_specular: true
    # liquid_glass_shadow_kind: "Neutral" # "Neutral" or "Chromatic"
    # liquid_glass_shadow_opacity: 0.5
    # liquid_glass_blur: 0.5
    # liquid_glass_offset_x: 0.0
    # liquid_glass_offset_y: 0.0
    # liquid_glass_lighting: "combined" # "individual" or "combined"
    # liquid_glass_refractivity_enabled: true # requires depth + strength
    # liquid_glass_refractivity_depth: 0.5
    # liquid_glass_refractivity_strength: 0.5
    # liquid_glass_specular_highlight_placement: "inside" # "inside" or "outside"
  web:
    generate: true
    image_path: "path/to/image.png"
    # image_path_favicon: "assets/icon/icon-favicon.png"
    # image_path_maskable: "assets/icon/icon-maskable.png" # safe-zone-aware source
    # favicon_size: 16
    # favicon_ico: false # skip favicon.ico, ship the PNG only
    # output_path: "web" # custom web root, e.g. per flavor
    # background_color: "#0175C2" # hex color
    # theme_color: "#0175C2" # hex color
  windows:
    generate: true
    image_path: "path/to/image.png"
    # icon_filename: "app_icon_staging.ico" # per-flavor output name
  macos:
    generate: true
    image_path: "path/to/image.png"
    # padding: 10 # safe-area margin as % of icon size, 0 disables
    # rounded_corners: true # mask corners with a continuous-corner shape
  linux:
    generate: true
    image_path: "path/to/image.png"
```

### 2. Run the Package

After setting up the configuration, all that is left to do is run the package.

```shell
flutter pub get
dart run launcher_icons
```

If you name your configuration file something other than `launcher_icons.yaml` or `pubspec.yaml` you will need to specify
the name of the file when running the package.

```shell
flutter pub get
dart run launcher_icons -f <your config file name here>
```

Note: If you are not using the existing `pubspec.yaml` ensure that your config file is located in the same directory as it.

If you encounter any issues [please report them here](https://github.com/Quasiflo/launcher_icons/issues).

In the above configuration, the package is setup to replace the existing launcher icons
with the icon located in the image path specified above for every platform with
`generate: true`. Set `android.icon_name` / `ios.icon_name` to generate a new
icon under a custom name without removing the old default one.

### Command-Line Options

Shown below is the full list of options supported by the `launcher_icons:generate` command.

| Option                 | Description |
| ---------------------- | ----------- |
| `-f, --file <path>`    | Path to the config file. Defaults to `launcher_icons.yaml` |
| `-o, --override`       | Override an existing config file (only used by `launcher_icons:generate`) |
| `-v, --verbose`        | Verbose output |
| `-p, --prefix <path>`  | Generates icons in the given path (project root by default) |
| `--flavor-path <path>` | Path to search for flavor configuration files. Defaults to the current directory |
| `--flavor <name>`      | Run a single flavor (from a `launcher_icons-<flavor>` section or file) |

<!-- rumdl-disable-next-line MD063 -->
## :mag: Attributes

Shown below is the full list of attributes which you can specify within your Flutter Launcher Icons configuration.

### Global

- `image_path`: The location of the icon image file which you want to use as the app launcher icon. Must be a local file path.

### Source Image

Use a single high-resolution **PNG** as your source — **`1024x1024` recommended**.
iOS requires a 1024px App Store icon and every other size is downscaled from the
source, so starting smaller loses quality. JPG/JPEG/WebP sources are only
accepted for Android adaptive backgrounds; all generated icons are PNG, except
the Windows `.ico`.

| Platform | Generated sizes |
| --- | --- |
| Android legacy | 48, 72, 96, 144, 192 (`mipmap-mdpi` → `mipmap-xxxhdpi`) |
| Android adaptive foreground | 108, 162, 216, 324, 432 (`drawable-mdpi` → `drawable-xxxhdpi`) |
| iOS | 20 – 1024 (up to the 1024px App Store icon) |
| Web | 192, 512 (+ safe-zone-aware maskable variants), 180px apple-touch-icon, 16px favicon.png + 16+32+48 favicon.ico |
| Windows | multi-size `.ico`: 16, 24, 32, 40, 48, 64, 256 |
| macOS | 16 – 1024 (`@1x`/`@2x` sets) |
| Linux | hicolor tree (16–512) + `.desktop` entries + `snap/` packaging (plus the X11 window-icon patch) |

### Android

- `android`: Add Android related configs
  - `generate`: Specifies whether to generate icons for Android platform or not
  - `image_path`: The location of the icon image file specific for Android platform (optional - if not defined then the image_path is used)
  - `icon_name`: Custom icon name (e.g. `"ic_launcher"`). When specified, a new launcher icon is generated without removing the old default existing Flutter launcher icon (also updates `AndroidManifest.xml`). When omitted, the default icon is overridden.
**The next attributes are only used when generating Android launcher icon**
- `adaptive_icon_background`: The color (E.g. `"#ffffff"`), the keyword `"transparent"` (maps to `@android:color/transparent` with no `colors.xml` entry), or image asset (png, jpg, jpeg, or webp - E.g. `"assets/images/christmas-background.png"`) which will
be used to fill out the background of the adaptive icon.
- `adaptive_icon_foreground`: The image asset which will be used for the icon foreground of the adaptive icon
*Note: Adaptive Icons will only be generated when both adaptive_icon_background and adaptive_icon_foreground are specified. (the image_path is not automatically taken as foreground)*
*Note: If you only set `image_path`, launchers that use round icons (e.g. many Android launchers) may show a white circle with your square icon inside. For correct round/adaptive icons, always set both `adaptive_icon_background` and `adaptive_icon_foreground` (plus `adaptive_icon_monochrome` for Android 13+ themed icons). The tool does not auto-round artwork or add padding — use `adaptive_icon_foreground_inset` to control foreground padding.*
- `adaptive_icon_foreground_inset`: This is used to add padding (in %) to the foreground icon when generating an adaptive icon. The default value is `16`.
- `adaptive_icon_monochrome`: The image asset which will be used for the icon
foreground of the Android 13+ themed icon. Zero `adaptive_icon_foreground_inset` emits the canonical plain `<monochrome android:drawable>` form. For more information see [Android Adaptive Icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive)
- `adaptive_icon_round`: Opt-in round icon image. Emits `ic_launcher_round.png` drawables, an `ic_launcher_round.xml` adaptive icon, and `android:roundIcon` manifest wiring (plus stale cleanup). Requires `adaptive_icon_background` + `adaptive_icon_foreground`.
- `play_store_icon`: When `true`, emits a 512px `play_store_icon.png` sidecar next to the project for store upload (never an `android/res` deliverable, warns past the 1024KB budget). Off by default.

### IOS

- `ios`: Add iOS related configs
  - `generate`: Specifies whether to generate icons for iOS platform or not
  - `image_path`: The location of the icon image file specific for iOS platform (optional - if not defined then the image_path is used)
  - `icon_name`: Custom icon set name (e.g. `"My-Launcher-Icon"`). When specified, a new launcher icon is generated without removing the old default existing Flutter launcher icon. When omitted, the default icon is overridden.
  - `xcodeproj_path`: Custom path to the `.xcodeproj` directory (default `"ios/Runner.xcodeproj"`). Set this when the Xcode project was renamed.
  - `flavor_mode`: `"pbxproj"` (default) rewrites `ASSETCATALOG_COMPILER_APPICON_NAME` per build configuration; `"xcconfig"` instead writes `ios/Flutter/<flavor>-<Mode>.xcconfig` overrides (assign them as base configuration files in Xcode once).
  - `single_size`: When `true`, generates only the single 1024px universal icon instead of the full icon set. Dark/tinted variants are ignored in this mode, *defaults to false*.
- `remove_alpha`: Removes alpha channel for iOS icons (blended against `background_color`). The dark variant intentionally keeps its transparency (Apple: the system background shows through); the tinted variant is forced opaque like the base image.
- `image_path_dark_transparent`: The location of the dark mode icon image file specific for iOS 18+ platform. *Note: Apple recommends this icon to be transparent. For more information see [Apple Human Interface Guidelines for App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons#iOS-iPadOS)*
- `image_path_tinted_grayscale`: The location of the tinted mode icon image file specific for iOS 18+ platform. *Note: This icon should be an grayscale image. Use `desaturate_tinted_to_grayscale: true` to automatically desaturate the image provided here.*
- `desaturate_tinted_to_grayscale`: Automatically desaturates tinted mode icon image to grayscale, *defaults to false*
- `background_color`: The color (in the format "#RRGGBB") to be used as the background when removing the alpha channel. **Only takes effect when `remove_alpha: true`** — it is the matte color blended under transparent pixels. Without `remove_alpha`, this setting is ignored and transparent regions stay transparent (rendered black by some viewers). (optional - if not defined then `#ffffff` is used)

**Liquid Glass Icon Settings (iOS)**
*Liquid glass icons create modern, translucent app icons with customizable glass effects, shadows, and positioning. These settings generate .icon files compatible with Apple's Icon Composer.*

- `image_path_liquid_glass_icon`: The location of the icon image file specific for iOS liquid glass icon generation (optional - enables liquid glass icon generation when specified). SVG sources pass through undecoded.
- `image_path_liquid_glass_icon_dark`: Dark-appearance layer source (optional - falls back to `image_path_dark_transparent`)
- `image_path_liquid_glass_icon_tinted`: Tinted-appearance layer source (optional - falls back to `image_path_tinted_grayscale`)
- `remove_liquid_glass`: Disables the glass effect for the liquid glass icon, *defaults to false*
- `liquid_glass_icon_scale`: Scale factor for the icon within the liquid glass effect, *defaults to 1.0*
- `liquid_glass_translucency`: Translucency value for the glass effect (0.0 = opaque, 1.0 = fully transparent), *defaults to 0.5*
- `liquid_glass_specular`: Enable specular highlights on the glass surface, *defaults to true*
- `liquid_glass_shadow_kind`: Type of shadow effect - "Neutral" for standard shadows or "Chromatic" for colored shadows, *defaults to "Neutral"*
- `liquid_glass_shadow_opacity`: Opacity of the shadow effect (0.0 = no shadow, 1.0 = full opacity), *defaults to 0.5*
- `liquid_glass_blur`: Amount of blur applied to the glass effect (0.0 = no blur, higher values = more blur), *defaults to 0.5*
- `liquid_glass_offset_x`: Horizontal offset for icon positioning within the glass effect in points, *defaults to 0.0*
- `liquid_glass_offset_y`: Vertical offset for icon positioning within the glass effect in points, *defaults to 0.0*
- `liquid_glass_lighting`: Group lighting model, `"individual"` or `"combined"` (only observable with 2+ layers), unset by default
- `liquid_glass_refractivity_enabled`: Enables group refractivity (requires `liquid_glass_refractivity_depth` + `liquid_glass_refractivity_strength`), unset by default
- `liquid_glass_refractivity_depth`: Refractivity depth, required when refractivity is enabled
- `liquid_glass_refractivity_strength`: Refractivity strength, required when refractivity is enabled
- `liquid_glass_specular_highlight_placement`: Specular highlight placement, `"inside"` or `"outside"`, unset by default

### Web

- `web`: Add web related configs
  - `generate`: Specifies whether to generate icons for this platform or not
  - `image_path`: Path to web icon.png
  - `image_path_favicon`: The location of the icon image file used to generate the favicon (optional - if not defined then falls back to using the web image_path then the global image_path)
  - `image_path_maskable`: Dedicated safe-zone-aware maskable source (optional - falls back to a padded derivation: logo at ~80% on the opaque `background_color`)
  - `favicon_size`: Favicon PNG size in pixels, *defaults to 16* (`favicon.ico` always holds 16+32+48)
  - `favicon_ico`: Set to `false` to skip `favicon.ico` and ship the PNG only, *defaults to true*
  - `output_path`: Web root directory for generated files (default `web`). Set per flavor (e.g. `web_prod`) to keep flavor outputs separate.
  - `background_color`: Updates *background_color* in `web/manifest.json`. Must be a hex color (also used to flatten the 180px `apple-touch-icon.png`).
  - `theme_color`: Updates *theme_color* in `web/manifest.json` (plus a `<meta name="theme-color">` tag in `index.html`). Must be a hex color.

### Windows

- `windows`: Add Windows related configs
  - `generate`: Specifies whether to generate icons for Windows platform or not
  - `image_path`: Path to windows icon.png (a multi-size `.ico` of 16, 24, 32, 40, 48, 64 and 256 is generated by default; sources under 256px warn about upscaling)
  - `icon_filename`: Output `.ico` file name inside `windows/runner/resources/` (default `app_icon.ico`, the `Runner.rc` contract). Set per flavor so sequential flavor runs don't clobber each other (wire the name into `Runner.rc(.in)` manually).

### MacOS

- `macos`: Add MacOS related configs
  - `generate`: Specifies whether to generate icons for MacOS platform or not
  - `image_path`: Path to macos icon.png file
  - `padding`: Safe-area margin as a percent of the icon size on every side (artwork is scaled into the inner area and centered on a transparent canvas). `0` disables it. Prefer a `1024x1024` source so upscaling doesn't soften edges.
  - `rounded_corners`: Mask the icon corners with a continuous-corner (squircle) shape at the Apple-like 22.5% default, *defaults to false*
  - Flavors: a flavor run writes `AppIcon-<flavor>.appiconset`; select it in Xcode under `Build Settings` > `Asset Catalog App Icon Set Name`.

*Note: macOS icons are resized copies of your source image — transparency is preserved, not filled (unlike iOS `remove_alpha`). Prefer an opaque source image: transparent regions can render unpredictably under system themes (e.g. macOS Tahoe), and macOS will not round the artwork for you.*

### Linux

- `linux`: Add Linux related configs
  - `generate`: Specifies whether to generate icons for Linux platform or not
  - `image_path`: Path to linux icon.png file. Must be declared in the `assets:` list under `flutter:` in your `pubspec.yaml` so it is
  bundled with the app (any asset path works, not just `assets/`).

Generates the hicolor tree (`share/icons/hicolor/<size>/apps/<name>.png`,
16–512 off the pubspec name), freedesktop + snap `.desktop` entries,
`snap/gui/<name>.png`, and `snap/snapcraft.yaml` (name/version off pubspec,
build number stripped) — every file strictly only-if-absent, never
overwritten.

*Note: Linux support edits `linux/runner/my_application.cc`, resolving the
icon path relative to the running executable (`data/flutter_assets/`), so the
window icon works both under `flutter run` and in packaged release bundles.*

*Note: iOS icons should [fill the entire image](https://stackoverflow.com/questions/26014461/black-border-on-my-ios-icon) and not contain transparent borders.*

After running the icon generation you'll have to set the wished icon for your configuration in XCode project for your main target under `Build Settings` > `Asset Catalog App Icon Set Name`.

![XCode Build Settings Example](https://i.imgur.com/HxiAHlj.png)

## Flavor Support

Declare each flavor variant as a `launcher_icons-<flavor>` section in your config file or `pubspec.yaml`, replacing `<flavor>` by the name of your desired flavor. Each section has the same format as the plain `launcher_icons:` config and stands alone:

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

Run all flavors with `dart run launcher_icons`, or a single one with `dart run launcher_icons --flavor <name>`.

Alternatively, keep one `launcher_icons-<flavor>.yaml` file per flavor — the format is the same, and a file wins over a section with the same name. `icon_name` is ignored inside flavor configs: the catalog is always `AppIcon-<flavor>` (iOS/macOS) / `src/<flavor>/res` (Android).

Flavor configuration files are looked up recursively, so they may live in a subdirectory of your project. To search a directory other than the current directory, use the `--flavor-path` option:

```shell
dart run launcher_icons --flavor-path=<directory>
```

*Note: `--flavor-path` only controls where flavor configuration files are searched for and the search is performed recursively. Each flavor's configuration file (`launcher_icons-<flavor>.yaml`) is still loaded from the directory you run the command from (the current working directory).*

An example project with flavor support enabled [has been added to the examples](https://github.com/Quasiflo/launcher_icons/tree/master/example/flavors).

<!-- rumdl-disable-next-line MD063 -->
## :question: Troubleshooting

Listed a couple common issues with solutions for them

### App Still Shows the Old Icon After Regenerating

The generated files are usually correct — the OS, Xcode/Gradle, or the Flutter
build cache is serving the stale icon. Work through these steps:

1. Run `flutter clean` to drop the build cache.
2. Uninstall the app from the device/simulator/emulator (upgrades can keep the old icon).
3. Rebuild and reinstall.
4. iOS: check Xcode `Build Settings` > `Asset Catalog App Icon Set Name` points at the generated set (`AppIcon`, or `AppIcon-<flavor>` for flavors).
5. Android flavors: make sure no leftover `mipmap-anydpi-v26/ic_launcher.xml` in `android/app/src/main/` is shadowing the flavor resources.

### Generated Icon Color Is Different from the Original Icon

Caused by an update to the image dependency which is used by Flutter Launcher Icons.

```txt
Use #AARRGGBB for colors instead of #AABBGGRR, to be compatible with Flutter image class.
```

[Related issue](https://github.com/Quasiflo/launcher_icons/issues/98)

### Dependency Incompatible

You may receive a message similar to the following

```log
Because launcher_icons >=0.9.0 depends on args 2.0.0 and flutter_native_splash 1.2.0 depends on args ^2.1.1, launcher_icons >=0.9.0 is incompatible with flutter_native_splash 1.2.0.
And because no versions of flutter_native_splash match >1.2.0 <2.0.0, launcher_icons >=0.9.0 is incompatible with flutter_native_splash ^1.2.0.
So, because enstack depends on both flutter_native_splash ^1.2.0 and launcher_icons ^0.9.0, version solving failed.
pub get failed (1; So, because enstack depends on both flutter_native_splash ^1.2.0 and launcher_icons ^0.9.0, version solving failed.)
```

For a quick fix, you can temporarily override all references to a dependency: [See here for an example](https://github.com/Quasiflo/launcher_icons/issues/262#issuecomment-879872076).

<!-- rumdl-disable-next-line MD063 -->
## :eyes: Example

[![Video Example](https://i.imgur.com/R28hqdz.png)](https://www.youtube.com/watch?v=RjNAxwcP3Tc)

Note: This is showing a very old version (v0.0.5)

### Special Thanks

- Thanks to Brendan Duncan for the underlying [image package](https://pub.dev/packages/image) to transform the icons.
- Big thank you to all the contributors to the project. Every PR / reported issue is greatly appreciated!
