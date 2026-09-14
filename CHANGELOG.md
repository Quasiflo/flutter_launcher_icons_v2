# Changelog

## [1.0.0](https://github.com/Quasiflo/launcher_icons/compare/launcher_icons-v0.14.4...launcher_icons-v1.0.0) (2026-09-14)


### ⚠ BREAKING CHANGES

* remove dead minSdk apparatus
* rebrand flutter_launcher_icons to launcher_icons
* remove deprecated windows.icon_size, flutter_icons key and main shim
* modern universal iOS icon set for all paths, drop legacy list ([#528](https://github.com/Quasiflo/launcher_icons/issues/528))
* nested android/ios config schema, v3 breaking change ([#394](https://github.com/Quasiflo/launcher_icons/issues/394))

### Features

* accept http(s) image URLs for icon sources ([#511](https://github.com/Quasiflo/launcher_icons/issues/511)) ([5dc7178](https://github.com/Quasiflo/launcher_icons/commit/5dc717869c94594be9f34d5229795560f33a4629))
* add Linux support ([b0e5c01](https://github.com/Quasiflo/launcher_icons/commit/b0e5c0180755ba2e9a8de2c516b8b8baa1974a9e))
* added support for android 13+ themed icons ([#497](https://github.com/Quasiflo/launcher_icons/issues/497)) ([006cb1e](https://github.com/Quasiflo/launcher_icons/commit/006cb1ed53f969bf11816cde5b16dd520e1ee40e))
* android adaptive_icon_round opt-in and play_store_icon sidecar ([6815648](https://github.com/Quasiflo/launcher_icons/commit/681564822e59490fb6fc1d59e8b84b212e812ea7))
* command to generate config file template ([3aa0fe5](https://github.com/Quasiflo/launcher_icons/commit/3aa0fe571261aaa721f07566f06d3e0123841587))
* configurable web favicon size ([#614](https://github.com/Quasiflo/launcher_icons/issues/614)) ([ee0a0a6](https://github.com/Quasiflo/launcher_icons/commit/ee0a0a68fa7971f4b8a0706263fc2f2b26a7ca52))
* Configure dark and tinted mode icons for iOS 18+ ([#569](https://github.com/Quasiflo/launcher_icons/issues/569)) ([93a697f](https://github.com/Quasiflo/launcher_icons/commit/93a697fd50a9b857179ee1e712d0e4b347ed47d4))
* custom xcodeproj path for renamed Xcode projects ([#637](https://github.com/Quasiflo/launcher_icons/issues/637)) ([88f146c](https://github.com/Quasiflo/launcher_icons/commit/88f146c68f867416ce4cda4605a03ceed4c8e30d))
* dedicated web image_path_maskable source with padded fallback ([94f9177](https://github.com/Quasiflo/launcher_icons/commit/94f91778163adf44f202b97cf7104ec7c073c0a5))
* display command to run to use config file ([8394fd6](https://github.com/Quasiflo/launcher_icons/commit/8394fd6fbc9701ce71d06782862dc2eebceee096))
* emit favicon.ico alongside favicon.png ([#540](https://github.com/Quasiflo/launcher_icons/issues/540)) ([66e1917](https://github.com/Quasiflo/launcher_icons/commit/66e19170d59a11a4e2377fd9fe615691dba5593c))
* flavor-aware macOS icon sets ([#638](https://github.com/Quasiflo/launcher_icons/issues/638)) ([1c1d640](https://github.com/Quasiflo/launcher_icons/commit/1c1d640743169f295cb08cec10169e7eb289b393))
* ios xcconfig flavor mode with hardened pbxproj matching ([789c34f](https://github.com/Quasiflo/launcher_icons/commit/789c34fdc012b938ce19b045126840ad8bd2dfc6))
* linux hicolor tree, desktop entries, and snap packaging ([2672cda](https://github.com/Quasiflo/launcher_icons/commit/2672cdaba60945bd7c1465ffc421586c08cf5c77))
* liquid glass lighting, refractivity, and specular placement ([2c16d55](https://github.com/Quasiflo/launcher_icons/commit/2c16d55b1b6b96102983776e707a8b943dedd3a4))
* liquid glass per-appearance layer specializations ([0fe72cd](https://github.com/Quasiflo/launcher_icons/commit/0fe72cd813ad131b45018e34f27c1a5536276921))
* macOS padding and rounded-corner icon options ([#463](https://github.com/Quasiflo/launcher_icons/issues/463), [#655](https://github.com/Quasiflo/launcher_icons/issues/655)) ([94fead6](https://github.com/Quasiflo/launcher_icons/commit/94fead6ed3fc54725590f15e6fee51154fa2ec08))
* modern universal iOS icon set for all paths, drop legacy list ([#528](https://github.com/Quasiflo/launcher_icons/issues/528)) ([884b303](https://github.com/Quasiflo/launcher_icons/commit/884b30316cfcd222c702d8a20e971c7d60f92187))
* multi-size favicon.ico with opt-out and CSS hex validation ([a8dc1b6](https://github.com/Quasiflo/launcher_icons/commit/a8dc1b65bead4f411a0ea80dc384058f764cc3bf))
* nested android/ios config schema, v3 breaking change ([#394](https://github.com/Quasiflo/launcher_icons/issues/394)) ([2a65c3a](https://github.com/Quasiflo/launcher_icons/commit/2a65c3ae399cb6ed9749174ba3ff8c87d51619f1))
* PR [#252](https://github.com/Quasiflo/launcher_icons/issues/252) ([52da30d](https://github.com/Quasiflo/launcher_icons/commit/52da30d70cc88be641494abb2e5beac4309cf732))
* PR [#492](https://github.com/Quasiflo/launcher_icons/issues/492) ([4a46a59](https://github.com/Quasiflo/launcher_icons/commit/4a46a591d716da0ac41c4880461edb34607e6d48))
* PR [#519](https://github.com/Quasiflo/launcher_icons/issues/519) ([b0bd417](https://github.com/Quasiflo/launcher_icons/commit/b0bd417d7b3490671413da3107fe5b63982d8b7c))
* PR [#549](https://github.com/Quasiflo/launcher_icons/issues/549) ([bf88640](https://github.com/Quasiflo/launcher_icons/commit/bf88640480dfe93030830fa357ae7ce165838d3a))
* PR [#647](https://github.com/Quasiflo/launcher_icons/issues/647) ([b0e5c01](https://github.com/Quasiflo/launcher_icons/commit/b0e5c0180755ba2e9a8de2c516b8b8baa1974a9e))
* PR [#650](https://github.com/Quasiflo/launcher_icons/issues/650) ([b878028](https://github.com/Quasiflo/launcher_icons/commit/b87802886b682eb6427de0e9499bc98455799a6d))
* PR [#651](https://github.com/Quasiflo/launcher_icons/issues/651) ([f87184f](https://github.com/Quasiflo/launcher_icons/commit/f87184fbe3747d2fbc624b9f77b44a1584d66df6))
* PR [#656](https://github.com/Quasiflo/launcher_icons/issues/656) ([e4fe567](https://github.com/Quasiflo/launcher_icons/commit/e4fe5673ce6a986a545b6ac5fe70692d522b44a3))
* PR [#664](https://github.com/Quasiflo/launcher_icons/issues/664) ([9d6f719](https://github.com/Quasiflo/launcher_icons/commit/9d6f719cfee9d78d874436c38dcba19a66eb8145))
* PR [#668](https://github.com/Quasiflo/launcher_icons/issues/668) ([52a2be2](https://github.com/Quasiflo/launcher_icons/commit/52a2be250a19c2b0810f800bb509d96d33c41f85))
* PR [#670](https://github.com/Quasiflo/launcher_icons/issues/670) ([3b467b6](https://github.com/Quasiflo/launcher_icons/commit/3b467b6f75e133d2a92cd0df55608ec5ca5d9116))
* PR [#672](https://github.com/Quasiflo/launcher_icons/issues/672) ([4690ccc](https://github.com/Quasiflo/launcher_icons/commit/4690ccc190aa598a0f8b7e084f9a632a4df97076))
* route status output through FLILogger with print fallback ([#552](https://github.com/Quasiflo/launcher_icons/issues/552)) ([69ea727](https://github.com/Quasiflo/launcher_icons/commit/69ea727474790d0eb24b0b2694fc74a7719e7110))
* shared FLIException base class for package errors ([#378](https://github.com/Quasiflo/launcher_icons/issues/378)) ([605e9f6](https://github.com/Quasiflo/launcher_icons/commit/605e9f69362123a837640c8d48033ff9547b81d9))
* single-size iOS icon mode ([#592](https://github.com/Quasiflo/launcher_icons/issues/592)) ([3e0cd73](https://github.com/Quasiflo/launcher_icons/commit/3e0cd73c61db85dd983e2bfacbb76cbf235d825f))
* transparent adaptive icon background keyword ([#535](https://github.com/Quasiflo/launcher_icons/issues/535)) ([90b1a3a](https://github.com/Quasiflo/launcher_icons/commit/90b1a3a8796f0c6319aaf3a6d2682fb4740dbaa1))
* web output_path for separate flavor roots ([#426](https://github.com/Quasiflo/launcher_icons/issues/426)) ([dac0c69](https://github.com/Quasiflo/launcher_icons/commit/dac0c69503bf1986658ebf38db09b19b6a339442))
* windows icon_filename override, 40/64 frames, upscale warning ([5f8c05b](https://github.com/Quasiflo/launcher_icons/commit/5f8c05bef9ca1bf5dd7bafb7debe0b64e92cd595))
* **windows:** generate multi-size .ico by default; deprecate windows.icon_size ([f87184f](https://github.com/Quasiflo/launcher_icons/commit/f87184fbe3747d2fbc624b9f77b44a1584d66df6))


### Bug Fixes

* accept any pubspec-declared asset path for linux ([cb0060e](https://github.com/Quasiflo/launcher_icons/commit/cb0060e24a3f3dcacda866cac0b0c8d97717d995))
* **android:** show blank icon if no adaptive icon set ([#601](https://github.com/Quasiflo/launcher_icons/issues/601)) ([945eadd](https://github.com/Quasiflo/launcher_icons/commit/945eadd115ef7e3fb741bdc4bd17b345d415cfac))
* atomic pbxproj writes and loud warning for missing flavor keys ([#636](https://github.com/Quasiflo/launcher_icons/issues/636), [#341](https://github.com/Quasiflo/launcher_icons/issues/341)) ([a4fb2de](https://github.com/Quasiflo/launcher_icons/commit/a4fb2dedcbe8e25aaeb82f83997d8afe31ee1ff3))
* clear stale adaptive icons when config is not adaptive ([#328](https://github.com/Quasiflo/launcher_icons/issues/328)) ([21d9a20](https://github.com/Quasiflo/launcher_icons/commit/21d9a20eaf0d3cfd5d84130b3a0f03ac1a2da5c8))
* collect per-platform failures and exit non-zero ([8200740](https://github.com/Quasiflo/launcher_icons/commit/82007402d7f8e543e272ca531ce680b2954f2d93))
* correct background channels in iOS alpha blending ([#514](https://github.com/Quasiflo/launcher_icons/issues/514)) ([3369a53](https://github.com/Quasiflo/launcher_icons/commit/3369a53bf88200a93b34b8899dce894ddff3722f))
* detect adaptive background image paths ([3b467b6](https://github.com/Quasiflo/launcher_icons/commit/3b467b6f75e133d2a92cd0df55608ec5ca5d9116))
* emit canonical plain monochrome XML at zero inset ([0fd49b0](https://github.com/Quasiflo/launcher_icons/commit/0fd49b0a7f554f1233077630ff588d1f3240beaf))
* **example:** added example for pub.dev closes [#402](https://github.com/Quasiflo/launcher_icons/issues/402) ([ea57bf2](https://github.com/Quasiflo/launcher_icons/commit/ea57bf25ca2f19c53ae5ed1c4c1e25a348fcc749))
* explicit -f custom file bypasses flavor loop ([#426](https://github.com/Quasiflo/launcher_icons/issues/426)) ([55cb145](https://github.com/Quasiflo/launcher_icons/commit/55cb1451ff9ecc89875554ec6e69943d9fe8c65e))
* explicit -f flavor file runs only that flavor ([#215](https://github.com/Quasiflo/launcher_icons/issues/215)) ([8f5cb21](https://github.com/Quasiflo/launcher_icons/commit/8f5cb21ba16ccaa5f5c88c5c3d73862d937aba4b))
* fail loudly when no platform is enabled ([b4c86b3](https://github.com/Quasiflo/launcher_icons/commit/b4c86b36142dda0185af69b739e8bdee1ec5f25c))
* fixes the issue where the dark and tinted icons were placed in the wrong directory ([#597](https://github.com/Quasiflo/launcher_icons/issues/597)) ([d5d0775](https://github.com/Quasiflo/launcher_icons/commit/d5d0775a76b637c763f3f10d26baab5ba998b047))
* hand-holding error for removed windows.icon_size ([58b1960](https://github.com/Quasiflo/launcher_icons/commit/58b19607b9ea5a7273a9ec860a07dc2e85dfbc5a))
* include 1x switcher sizes in modern iOS icon set ([#661](https://github.com/Quasiflo/launcher_icons/issues/661)) ([fe92a07](https://github.com/Quasiflo/launcher_icons/commit/fe92a077638dc6105622aa8345631c234024b282))
* minSdk lookups tolerate missing files, fall back to default ([#644](https://github.com/Quasiflo/launcher_icons/issues/644)) ([c389d29](https://github.com/Quasiflo/launcher_icons/commit/c389d29e88d365e0b1284d0bfcf4550585e2f06c))
* no longer printing creating icons message for unused platforms ([683575e](https://github.com/Quasiflo/launcher_icons/commit/683575e4300fbecc92bcc2a8625df21f7b9b1ca2))
* normalize bare hex colors written to colors.xml ([#673](https://github.com/Quasiflo/launcher_icons/issues/673)) ([9cd9728](https://github.com/Quasiflo/launcher_icons/commit/9cd972897e8e8bcc83b31ab7d0ce24b4c57fdfdf))
* per-variant remove_alpha with unified hex parsing ([4f1f575](https://github.com/Quasiflo/launcher_icons/commit/4f1f575e3ac7a51e8eae65e5d65a4696859fe66c))
* remove dead minSdk apparatus ([2bff0b9](https://github.com/Quasiflo/launcher_icons/commit/2bff0b90e9dada036cf872e6d177d7ecdea17904))
* resolve renamed Xcode projects when editing pbxproj ([#543](https://github.com/Quasiflo/launcher_icons/issues/543)) ([2b90dbc](https://github.com/Quasiflo/launcher_icons/commit/2b90dbc002bb33bb03ebbb8db8c3c376db76d241))
* route iOS through decodeImageFile with non-nullable return ([80a5365](https://github.com/Quasiflo/launcher_icons/commit/80a536543c7ae8cb47b1846741869fcc5863f068))
* skip dark/tinted I/O entirely in iOS single-size mode ([520fca0](https://github.com/Quasiflo/launcher_icons/commit/520fca094ae6b6eaaf2b695db346b1975c6bb3fd))
* stale generated template no longer shadows pubspec config ([#628](https://github.com/Quasiflo/launcher_icons/issues/628)) ([c9b336b](https://github.com/Quasiflo/launcher_icons/commit/c9b336b43d94c1768f1c72cc44dde54a866887be))
* **template:** wrong attribute to remove alpha channel ([#586](https://github.com/Quasiflo/launcher_icons/issues/586)) ([127ab0f](https://github.com/Quasiflo/launcher_icons/commit/127ab0fb38df3c9945668c4510d58826682bdaeb))
* tests fails for the newly generated list ([#576](https://github.com/Quasiflo/launcher_icons/issues/576)) ([79077ee](https://github.com/Quasiflo/launcher_icons/commit/79077eee4d2da9194f3bc8d47247a1c0a4bd14db))
* typo in readme ([#639](https://github.com/Quasiflo/launcher_icons/issues/639)) ([4920f04](https://github.com/Quasiflo/launcher_icons/commit/4920f04c0164bf939561b50d1444ba588b3930f7))
* web index.html updater and opaque apple-touch-icon ([242225f](https://github.com/Quasiflo/launcher_icons/commit/242225f6d5c769fc5e01742d8a714b6c4bdaee0d))
* wire macOS flavor catalogs into project.pbxproj ([1e3c4af](https://github.com/Quasiflo/launcher_icons/commit/1e3c4af30e64e662c2d559329f7fe957abab6e86))
* write custom icon_name PNGs to their own catalog ([4e5ef1f](https://github.com/Quasiflo/launcher_icons/commit/4e5ef1f9531041c72b5c1ee184a6cebb2995e063))
* wrong PR mentioned in changelog ([#584](https://github.com/Quasiflo/launcher_icons/issues/584)) ([b6e97ad](https://github.com/Quasiflo/launcher_icons/commit/b6e97ad48fbca0a560ff0111e1187aa9f5a2db65))


### Miscellaneous Chores

* rebrand flutter_launcher_icons to launcher_icons ([1dad1c9](https://github.com/Quasiflo/launcher_icons/commit/1dad1c987bf400677db262f9cd8b51ca82b70469))
* remove deprecated windows.icon_size, flutter_icons key and main shim ([4c2c8ab](https://github.com/Quasiflo/launcher_icons/commit/4c2c8aba37038bbd109bdd3e088c99710e0733b7))

## 0.14.4 (10th June 2025)

- Removed rules which no longer exist from analysis_options [#598](https://github.com/fluttercommunity/flutter_launcher_icons/issues/598)
- Fix template generated within thegenerate command [#642](https://github.com/fluttercommunity/flutter_launcher_icons/issues/642)
- Standardize on async I/O and waiting for work to complete [#646](https://github.com/fluttercommunity/flutter_launcher_icons/issues/646)

## 0.14.3 (17th January 2025)

- Android: Avoids creating mipmap file used by adaptive and monochrome icons if no config exist for both [#601](https://github.com/fluttercommunity/flutter_launcher_icons/pull/601)

## 0.14.2 (5th December 2024)

- iOS: Fixed issue where dark and tinted icons were placed into the wrong directory [#597](https://github.com/fluttercommunity/flutter_launcher_icons/pull/597)

## 0.14.1 (24th September 2024)

- Fixed README

## 0.14.0 (21st September 2024)

- Android: Support for monochrome icons [#497](https://github.com/fluttercommunity/flutter_launcher_icons/pull/497)

**Before**

<img src="https://github.com/user-attachments/assets/ce16287d-1394-4404-b056-8308f0a69f07" width=40%>

**Now**

<img src="https://github.com/user-attachments/assets/a420fefd-28b0-4eb9-8fd0-2e03068d3d83" width=40%>

- Android: Ability to set inset for adaptive icon foreground and monochrome icon [#563](https://github.com/fluttercommunity/flutter_launcher_icons/pull/563)
- iOS: Dark and Tinted icons for iOS 18+ [#569](https://github.com/fluttercommunity/flutter_launcher_icons/pull/569)

## 0.13.1 (15th April 2023)

- Can now use `flutter_launcher_icons` instead of `flutter_icons` [#478](https://github.com/fluttercommunity/flutter_launcher_icons/pull/478)
- Can use command `flutter pub run flutter_launcher_icons:generate` to automatically generate config file [#475](https://github.com/fluttercommunity/flutter_launcher_icons/pull/475)


## 0.13.0 (7th April 2023)

- Fix remove alpha for iOS [#464](https://github.com/fluttercommunity/flutter_launcher_icons/pull/464)
- Updating code style [#472](https://github.com/fluttercommunity/flutter_launcher_icons/pull/472)
- Updated out of bounds dependency [#473](https://github.com/fluttercommunity/flutter_launcher_icons/pull/473)

## 0.12.0 (24th February 2023)

- Updated image package and other packages [#447](https://github.com/fluttercommunity/flutter_launcher_icons/pull/447)

## 0.11.0 (27th September 2022)
    
- Support for Macos Icons [#407](https://github.com/fluttercommunity/flutter_launcher_icons/pull/407)
- Cli-improvement [#400](https://github.com/fluttercommunity/flutter_launcher_icons/pull/400)
- Add `repository` and `issue_tracker` [#411](https://github.com/fluttercommunity/flutter_launcher_icons/pull/411) (thanks to [@patelpathik](https://github.com/patelpathik))
- Fix indent in web/manifest.json [#407](https://github.com/fluttercommunity/flutter_launcher_icons/pull/407)
- Fix the icons 50 and 57 in `contents.json` [#412](https://github.com/fluttercommunity/flutter_launcher_icons/pull/412) (thanks to [@adnanjpg](https://github.com/adnanjpg))
- Fix typos [#405](https://github.com/fluttercommunity/flutter_launcher_icons/pull/405) (thanks to [@edwardmp](https://github.com/edwardmp))
- Added newline to EOF [#325](https://github.com/fluttercommunity/flutter_launcher_icons/pull/325) (thanks to [@sandersaelmans](https://github.com/sandersaelmans))

## 0.10.0 (2nd August 2022)

- Support for Web Icons [#374](https://github.com/fluttercommunity/flutter_launcher_icons/pull/374)
- Support for Windows Icons [#382](https://github.com/fluttercommunity/flutter_launcher_icons/pull/382)
- Added missing IOS icon sizes [#298](https://github.com/fluttercommunity/flutter_launcher_icons/pull/298)
- Added `min_sdk_android` option [#392](https://github.com/fluttercommunity/flutter_launcher_icons/pull/392)
- Added documentation for `remove_alpha_ios` [#392](https://github.com/fluttercommunity/flutter_launcher_icons/pull/392)
- Fixed issue with loading config from `pubspec.yaml` [#398](https://github.com/fluttercommunity/flutter_launcher_icons/pull/398) (thanks to [@p-mazhnik](https://github.com/p-mazhnik))

## 0.9.3 (6th June 2022)

- Fixes to make sure it works for Flutter v2.8 (thanks to @RatakondalaArun)
- Fixed issue with incorrect version being shown

## 0.9.2 (22nd August 2021)

- Fixed issue where success message printed even when exception occured (thanks to @happy-san)

## 0.9.1 (25th July 2021)

- Upgrade args dependency to ^2.1.1 (thanks to @PiN73 and @comlaterra)
- Upgraded `image` and `test` dependencies

## 0.9.0 (28th Feb 2021)

- Null-safety support added (thanks to @SteveAlexander)
- Added option to remove alpha channel for iOS icons (thanks to @SimonIT)

## 0.8.1 (2nd Oct 2020)

- Fixed flavor support on windows (@slightfoot)

## 0.8.0 (12th Sept 2020)

- Added flavours support (thanks to @sestegra & @jorgecoca)
- Removed unassigned iOS icons (thanks to @melvinsalas)
- Fixing formatting (thanks to @mreichelt)

## 0.7.5 (24th April 2020)

- Fixed issue where new lines were added to Android manifest (thanks to @mreichelt)
- Improvements to code quality and general tidying up (thanks to @connectety)
- Fixed Android example project not running (needed to be migrated to AndroidX)

## 0.7.4 (28th Oct 2019)

- Worked on suggestions from [pub.dev](https://pub.dev/packages/flutter_launcher_icons#-analysis-tab-)

## 0.7.3 (3rd Sept 2019)

- Lot of refactoring and improving code quality (thanks to @connectety)
- Added correct App Store icon settings (thanks to @richgoldmd)

## 0.7.2 (25th May 2019)

- Reverted back using old interpolation method

## 0.7.1 (24th May 2019)

- Fixed issue with image dependency not working on latest version of Flutter (thanks to @sboutet06)
- Fixed iOS icon sizes which were incorrect (thanks to @sestegra)
- Removed dart_config git dependency and replaced with yaml dependency
- Refactoring of code

## 0.7.0 (22nd November 2018)

- Now ensuring that the Android file name is valid - An error will be thrown if it doesn't meet the criteria
- Fixed issue where there was a git diff when there was no change
- Fixed issue where iOS icon would be generated when it shouldn't be
- Added support for drawables to be used for adaptive icon backgrounds
- Added support for Flutter Launcher Icons to be able to run with it's own config file (no longer necessary to add to pubspec.yaml)

## 0.6.1 (26th August 2018)

- Upgraded test package
- Due to issue with dart_config not working with Dart 2.1.0, now using forked version of dart_config which contains fixes from both @v3rm0n and @SPodjasek

## 0.6.0 (8th August 2018)

- Moved the package to [Flutter Community](https://github.com/fluttercommunity/community)

## 0.5.2 (19th June 2018)

- Previous release didn't fix adaptive icons, just prevented the error message from appearing. This should hopefully fix it!

## 0.5.1 (18th June 2018)

- Fix for adaptive icons

## 0.5.0 (12th June 2018)

- [Android] Support for adaptive icons added (Suggestion #23)

## 0.4.0 (9th June 2018)

- Now possible to generate icons for each platform with different image paths (one for iOS icon and a separate one for Android)

## 0.3.3 (28th May 2018)

- Upgraded dart image package dependency to 2.0.0 (issue #26)

## 0.3.2 (2nd May 2018)

- Bug fixing

## 0.3.1 (1st May 2018)

- Bug fixing

## 0.3.0 (1st May 2018)

- Fixed issue where icons produced weren't the correct size (Due to images not with a 1:1 aspect r    ation)
- Improved quality of smaller icons produced (Thanks to PR #17 - Thank you!)
- Updated console printed messages to keep them consistent
- Added example folder to GitHub project

## 0.2.1 (25th April 2018)

- Added extra iOS icon size (1024x1024)
- Fixed iOS default icon name (Thanks to PR #15 - Thank you!)
- Fixed issue #10 where creation of the icons was failing due to the target folder not existing

## 0.2.0 (18th January 2018)

- Ability to create new launcher icons without replacing the old ones added (#6)
- Fixed issue with launcher icons for iOS not correctly being set

## 0.0.5

- Quick Fix on if statement

## 0.0.4

- Fixing strong mode error

## 0.0.3

- Adding flutter as a dependency so its listed as a flutter package.

## 0.0.2

- Fix Doc typo

## 0.0.1

- Initial version, Resizes Icon to Android sizes only.
