# Changelog

All notable changes to Kittens are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.2.0

### Added
- `templates/assets/kittens.css` — a small, self-contained stylesheet replacing the ModestaCSS/Twemoji framework dependency, covering exactly what the homepage and legal pages actually use (dark theme base, hero layout, buttons, animation keyframe)

### Changed
- Homepage: the emoji cat icon is now the actual logo (`logo.svg`); "Built & Maintained by StuxAPIs, Hosted by Stuxedo" moved to its own line, after the "Images in API" count instead of sharing a line with it
- Homepage's accent color (title, links, buttons) now matches the logo's orange (`#d35400`) exactly, instead of ModestaCSS's default honey/orange/pinewood palette (`#eab543`/`#f39c12`/`#fdcb6e`) — classes renamed `honey-text`/`pinewood-text`/`orange-bg` → `accent-text`/`accent-bg` to match
- `README.md`'s "Open Source"/"Website" sections no longer credit AlexFlipnote's Coffee API fork or ModestaCSS, since neither is used anymore

### Removed
- `templates/assets/modesta.css`, `modesta3.1.0.css`, `twemoji.css` — no longer referenced by anything

## v1.1.1

### Fixed
- `templates/assets/logo.svg` redesigned — the plain circle-with-triangle-ears silhouette didn't read as a cat at all. Added whiskers and shaded inner ears (the actual recognizable cat cues) and dropped the mouth curves, which were rendering as an unintentional frown

## v1.1.0

### Added
- `templates/assets/logo.svg` — a full wordmark logo (cat-face icon + "Kittens" text), used as the README header image. The existing `templates/assets/profile.png` icon is unchanged and still used for the site's favicon/`og:image`.

### Changed
- Renamed "Kittens API" to "Kittens" throughout: `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `config.json`/`config.json.example`'s `title` field, `pm2.json`'s app name, and all five `templates/legal/*.html` pages
- Homepage's "Powered by StuxAPIs" line replaced with "Built & Maintained by StuxAPIs, Hosted by Stuxedo" (both now linked, to `github.com/StuxAPIs` and `stuxedo.com`), matching the branding used everywhere else in the org
- `README.md`'s tagline now matches the live GitHub description, ending in "Built & Maintained by StuxAPIs, Hosted by Stuxedo."

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
