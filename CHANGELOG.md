# Changelog

All notable changes to the Kittens API are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.4

### Changed
- `LICENSE` and `README.md` copyright year updated from `2024` to `2024-2026`

## v1.0.3

### Changed
- `README.md`'s footer brand-attribution block updated to the new two-line format (Built & Maintained by StuxAPIs, Hosted by Stuxedo / StuxAPIs is a part of the Stux.Group brand of businesses), replacing the older single-line disclaimer

## v1.0.2

### Changed
- This changelog's preamble now uses the standard Keep a Changelog wording

## v1.0.1

### Changed
- `README.md`'s "StuxAPIs is part of the Stux.Group Brand of Companies" line now includes the Stux.Group icon inline

## v1.0.0

### Added
- `VERSION.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `commit.sh`/`commit.bat` — brought the repo onto the standard StuxAPIs release flow (bump `VERSION.md`, update this changelog, run `commit.sh`/`commit.bat` to commit and tag `vX.Y.Z`)
- A legal hub at `/legal`, linked from the homepage footer as "Boring Legal Stuff", with six sub-pages: Privacy Policy, Terms and Ethics, Cookies Policy, Imprint, Disclaimer, and Opt-Out Preferences (`templates/legal/`, routed in `index.py`)
- `dev-server.sh`/`dev-server.bat` — local dev launcher that forces dev-mode config (`"localhost": true`, pointing asset/redirect URLs at `127.0.0.1`) by default, with a `--no-dev-mode` flag to test production config locally; also bootstraps `config.json` and a placeholder `images/` folder if missing so the app doesn't crash on a fresh checkout

### Changed
- `README.md` given a proper header image, quick endpoint reference, local development instructions and license/copyright sections
- `LICENSE` copyright holder normalized to Stux.Group
