# Changelog

All notable changes to the Kittens API are documented here. Versions follow
[Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

## v1.0.0

### Added
- `VERSION.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `commit.sh`/`commit.bat` — brought the repo onto the standard StuxAPIs release flow (bump `VERSION.md`, update this changelog, run `commit.sh`/`commit.bat` to commit and tag `vX.Y.Z`)
- A legal hub at `/legal`, linked from the homepage footer as "Boring Legal Stuff", with six sub-pages: Privacy Policy, Terms and Ethics, Cookies Policy, Imprint, Disclaimer, and Opt-Out Preferences (`templates/legal/`, routed in `index.py`)
- `dev-server.sh`/`dev-server.bat` — local dev launcher that forces dev-mode config (`"localhost": true`, pointing asset/redirect URLs at `127.0.0.1`) by default, with a `--no-dev-mode` flag to test production config locally; also bootstraps `config.json` and a placeholder `images/` folder if missing so the app doesn't crash on a fresh checkout

### Changed
- `README.md` given a proper header image, quick endpoint reference, local development instructions and license/copyright sections
- `LICENSE` copyright holder normalized to Stux.Group
