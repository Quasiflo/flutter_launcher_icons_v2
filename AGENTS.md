# AGENTS.md

Dart CLI package (`launcher_icons`, SDK `>=3.0.0 <4.0.0`). No monorepo. Entrypoints: `bin/launcher_icons.dart` → `lib/src/cli.dart`; config-template generator `bin/generate.dart`. Platform generators: `lib/src/platforms/{android,ios,linux,macos,web,windows}/`. Config schema: `lib/src/config/`.

## Commands

```shell
dart pub get
dart test                     # canonical entrypoint: discovers every test/**/*_test.dart
hk check --all                  # verify: format, lints, analyzer, markdown, workflows (no writes)
hk fix --all                    # apply fixes: format + `dart fix` + codegen
```

- Setup (see `CONTRIBUTING.md`): `mise install`, then `hk install --global` (or repo-only `hk install`). Skip hooks once with `HK=0`.
- CI (`.github/workflows/ci-open-pr.yml`): `dart format --output=none --set-exit-if-changed lib test bin` + `dart analyze --fatal-infos` + `dart test`. Match it locally via `hk check --all`.
- `dart_test.yaml` sets `concurrency: 1` because android/ios-liquid-glass suites mutate process-wide CWD. Never raise it or pass `--concurrency`; single file e.g. `dart test test/config_test.dart` is fine for focus.
- Fixture PNGs/JPG/WebP derive from checked-in SVG masters: after editing an SVG, run `dart run tool/render_fixtures.dart` (`--check` verifies without writing).

## Codegen — Never Delete Outputs

```shell
dart run build_runner build   # plain build only
```

- `build.yaml` scopes builders to `lib/**`, `bin/**`, `test/**`. The checked-in `example/` apps are standalone Flutter projects — never scan them (json_serializable chokes on their newer syntax).
- Never use `--delete-conflicting-outputs`: it deletes hand-maintained `lib/src/version.dart`.
- `hk fix` runs codegen; `hk check` skips it (no read-only freshness probe exists — see `.config/hk.pkl`).

## Versioning — Hands Off

- Never edit `lib/src/version.dart`, `CHANGELOG.md`, or the version in `pubspec.yaml` by hand. Release-please bumps all three via `x-release-please-version` markers (`pubspec.yaml`, `README.md`, `lib/src/version.dart`).
- `test/package_version_test.dart` enforces `version.dart` ↔ `pubspec.yaml` sync. If it fails, you edited something release-please owns.
- Conventional Commits: `feat:`/`fix:` release a version; `docs:`/`refactor:`/`chore:`/`test:`/`style:` don't.

## Adding Config Keys / Changing Platforms

- New config key: add it to the `:generate` template (`configFileTemplate` in `bin/generate.dart`), document in `README.md`, cover with a test. `test/generate_template_test.dart` is a drift test that fails if template and schema (`*Config().toJson()` keys) diverge.
- Behavior change to a platform: also refresh `example/flavors` outputs by running `dart run launcher_icons` inside `example/flavors`.
