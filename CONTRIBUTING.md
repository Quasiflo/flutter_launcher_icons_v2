# Contributing

Thanks for helping out — this repo is intentionally easy to work in: plain
Dart, no build system beyond `pub`, one test command.

## Setup

1. Install [mise](https://mise.jdx.dev/getting-started.html), then fetch the
   pinned tools from the repo root (hk, rumdl, zizmor, Flutter — see
   [.config/mise.toml](.config/mise.toml)):

   ```shell
   mise install
   ```

   You also need a Dart SDK (or the mise-provided Flutter) for everything
   below.
2. Install the git hooks — recommended once per machine (Git 2.54+, silent
   no-op in repos without hk config):

   ```shell
   hk install --global
   ```

   Or repo-only with `hk install`. Skip hooks for one command with `HK=0`.
   Optional global defaults (extra steps, `jobs`, …) live in
   `~/.config/hk/config.pkl`. More in the
   [hk docs](https://hk.jdx.dev/getting-started.html).
3. Get dependencies and confirm green:

   ```shell
   dart pub get
   hk check --all
   ```

## Workflow

- `hk check --all` verifies everything (format, lints, analyzer, markdown,
  workflows). `hk fix --all` applies what it can — formatting, fixes, and
  codegen — then re-run `hk check --all`.
- Touched a `@JsonSerializable` model? `hk fix` regenerates the code for you.
  Never run build_runner with `--delete-conflicting-outputs`, and never
  delete `lib/src/version.dart` — it is hand-maintained, edit only its version
  string.
- New config key? Add it to the `:generate` template in `bin/generate.dart`
  (there is a drift test), document it in `README.md`, and cover it with a
  test. Behavior changes to an existing platform should also refresh the
  [flavors example](example/flavors) outputs (`dart run launcher_icons` in
  `example/flavors`).
- Keep it simple: small focused diffs, one concern per commit, no drive-by
  reformatting (`dart format` is enforced by hk, so formatting takes care of
  itself).

## Commits and Releases

Use [Conventional Commits](https://www.conventionalcommits.org/):
`feat:` / `fix:` release a new version, `docs:` / `refactor:` / `chore:` /
`test:` / `style:` don't. [release-please](https://github.com/googleapis/release-please)
bumps the version and writes [CHANGELOG.md](CHANGELOG.md) from commit messages —
never edit either by hand, and keep the `x-release-please-version` markers in
`pubspec.yaml`, `README.md`, and `lib/src/version.dart`.

CI runs the analyzer and the full test suite on every pull request.
