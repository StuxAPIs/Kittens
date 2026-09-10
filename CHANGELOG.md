# Changelog

All notable changes to Kittens are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.7.1

### Changed
- `/changelog` restyled to match the TIGHC changelog page (tighc.stuxie.dev/changelogs): each `### Added`/`Changed`/`Fixed`/`Removed`/`Deprecated`/`Security` heading now renders as a colored uppercase pill badge instead of plain text, version headings use a bold monospace font, and list items get an accent-colored dash marker instead of the default bullet. `index.py`'s `/changelog` route now post-processes the rendered Markdown to swap `<h3>` headings for badge `<p>` tags and tag `<ul>` elements for the new styling; `kittens.css` gains the corresponding `.cl-label`/`.cl-list` rules

## v1.7.0

### Added
- `/about` — a new page describing what Kittens is, its endpoints, and who runs it, linked from the homepage footer, `/changelog` footer, and the legal pages' shared footer

### Fixed
- `/changelog` (and any other page using the shared `.legal-body` narrow-column layout) could overflow horizontally on mobile: long unbroken inline `code` spans and URLs in the rendered Markdown had no wrapping rule, so they'd extend past the content column instead of breaking onto a new line — `body.legal-body` now sets `overflow-wrap: break-word`
- The `/legal` hub page inherited the shared legal-page header link ("&larr; Back to Boring Legal Stuff") from `legal/_base.html`, which pointed right back at itself — it now reads "&larr; Back to Kittens" and links to `/`, like every other page's back link. `legal/_base.html`'s top link is now a `{% block backlink %}` so the hub page can override it

### Changed
- The legal pages' shared footer contact address is now `legal@stuxapis.net` instead of the general `contact@stuxapis.net`; the Imprint and Disclaimer pages' own contact links, and `CONTRIBUTING.md`'s "Questions" section, now point at the general `hello@stuxapis.net` instead

## v1.6.2

### Changed
- `logo.svg`/`icon.png` (`profile.png` renamed) moved from being vendored locally to the shared CDN at `https://global.media.stuxapis.net/kittens/logo.svg` / `/icon.png` — every template/README reference updated accordingly and no longer carries the `?v=` cache-buster, since cache invalidation for that asset is now the CDN's concern rather than this repo's release version
- `assets/` moved out of `templates/` to the project root, since it's not Jinja template content — only `templates/assets/css/kittens.css` and `templates/assets/fonts/` survive the move (to `assets/css/` and `assets/fonts/`); `templates/assets/images/` is gone entirely now that those assets live on the CDN. `index.py`'s `/assets/<path:filename>` route now serves from `assets` instead of `templates/assets`, and the `/assets/css/kittens.css` route no longer goes through Jinja's `render_template` (which requires the file to live under `templates/`) — it's now a plain file read with a manual `{{ version }}` substitution, since that placeholder was the only reason it was ever Jinja-rendered in the first place
- Legal sub-page titles now follow the `(Page) | Legal - Kittens` format (e.g. `Privacy Policy | Legal - Kittens`), matching the convention used across the org; the hub page itself is titled just `Legal - Kittens`

## v1.6.1

### Changed
- `README.md`'s footer "Built & Maintained by StuxAPIs" icon now uses StuxAPIs' own logo (`https://global.media.stuxapis.net/icon.png`) instead of the GitHub org avatar (`github.com/StuxAPIs.png`), now that StuxAPIs has real branding of its own

## v1.6.0

### Added
- `?v={{ version }}` cache-busting extended to every asset reference, not just `kittens.css`: `logo.svg` and `profile.png` (favicon/`og:image`, across all three page templates) now carry it too
- `kittens.css` is now served through a dedicated route (`/assets/css/kittens.css`) that renders it via Jinja instead of as a static file, so the Fredoka `@font-face` URL embedded *inside* the CSS can also carry `?v={{ version }}` — the one asset reference that couldn't be versioned just by editing HTML templates, since it lives inside the CSS file itself

## v1.5.4

### Fixed
- `logo.svg`'s viewBox was cropped tight horizontally (v1.5.0) but the "Kittens" wordmark was still only font-size 52 against a 96px-tall icon badge, leaving a lot of visually empty space above/below the text relative to the icon's weight. Bumped to font-size 80 (measured the actual rendered text width/height to keep the crop tight rather than guessing) for a much better-balanced icon/wordmark lockup
- `/changelog` (and any other long-content page using `.legal-body`) had its bottom padding effectively swallowed: the global `body { height: 100% }` rule (needed for the homepage's fullscreen single-viewport layout) clamped the body's box to one viewport tall, so on pages taller than the viewport the specified `5rem` bottom padding was calculated relative to that clamped box instead of after the actual (overflowing) content — visually, the last element sat flush against the bottom of the page with no padding at all. `body.legal-body` now sets `height: auto` to opt out of that constraint

## v1.5.3

### Fixed
- **This is what was actually causing the "site is broken / stylised wrong" and "favicon/profile.png still wrong" reports.** `kittens.css` was linked with a hardcoded `?v=1.0.0` query string that was never bumped across any release since it was introduced in v1.2.0 — Cloudflare/the browser kept serving a stale cached copy of the CSS from before v1.5.0 forever, since the cache key (the URL) never changed even though the file's actual content kept changing underneath it. Confirmed directly: the browser's parsed stylesheet had 33 rules and was missing `.site-footer` entirely, while the origin file (verified via a cache-busted fetch) was the correct, current 175-line file all along — the server-side files (`profile.png` included) were never actually wrong, they just weren't being fetched
- All three templates (`index.html`, `legal/_base.html`, `changelog.html`) now link `kittens.css?v={{ version }}` instead of a hardcoded string, so every release automatically busts the cache going forward — `legal()`, `legal_page()`, and `changelog()` now also pass `version=VERSION` to their templates (previously only `index()` did)

## v1.5.2

### Changed
- `README.md`'s two "Built & Maintained by StuxAPIs" links (tagline and footer disclaimer) now also point to [stuxapis.net](https://stuxapis.net), matching the homepage change in v1.5.1

## v1.5.1

### Changed
- Homepage's "Built & Maintained by StuxAPIs" link now points to [stuxapis.net](https://stuxapis.net) instead of `github.com/StuxAPIs` — the README's own disclaimer footer still links to GitHub, matching the convention used across the rest of the org's repos

## v1.5.0

### Fixed
- `/` (the homepage route) never passed `domain` to its template, unlike every other route — `{{ domain }}` silently rendered as empty everywhere on the homepage. It happened to still resolve correctly by coincidence there (root-relative paths behave the same as domain-absolute ones at `/`), but broke the Open Graph `og:image` tag, which requires an absolute URL for link previews on Discord/Twitter/etc. Now passes `domain=domain` like every other route
- `templates/assets/images/profile.png` (used for the favicon and `og:image`) was still the literal old Twemoji cat-emoji graphic — the one that used to sit in the homepage `<h1>` before the logo redesign, never actually replaced when that redesign happened. Replaced with a proper square icon matching the new logo's cat-face design
- `logo.svg`'s viewBox was 400 wide, but the actual icon+wordmark content only occupied about the first 300px, leaving ~70px of dead space on the right — this made the logo look off-center on the page even though its bounding box genuinely was centered. Trimmed the viewBox to fit the content tightly (measured the actual rendered text width rather than guessing)
- `.logo-img` set both a fixed `height: 90px` and `max-width: 85vw` without `height: auto` — on any viewport narrower than ~423px this would have squished the logo's aspect ratio once `max-width` became the binding constraint. Changed to `max-height` + `max-width` with both `width`/`height: auto`, the standard "fit in box, preserve aspect ratio" pattern

### Changed
- Homepage responsiveness overhaul: hero title/tagline/subtext now use `clamp()`-based fluid font sizing instead of fixed `rem` values (which didn't scale down for mobile), `.center-object` gained horizontal padding, `body` gained `overflow-x: hidden` as a safety net, and the viewport meta tag no longer disables pinch-zoom (`user-scalable=no, maximum-scale=1.0` removed — an accessibility/mobile-friendliness anti-pattern)
- "Images in API: N" moved out of the hero block and into the footer, alongside the copyright/version line

## v1.4.2

### Fixed
- `README.md`'s header logo pointed at `templates/assets/logo.svg`, which moved to `templates/assets/images/logo.svg` in the v1.4.0 asset reorg — the `.md` file wasn't caught by that pass since it only swept `.html` templates, so the logo stopped rendering on the GitHub repo page

### Changed
- `README.md`'s "Website" section updated to reflect the site as it actually is now: added the `/changelog` page link, and notes on the self-hosted `kittens.css` stylesheet and self-hosted Fredoka font (previously undocumented)
- `config.json.example`'s `description` field ("Get random pictures of kittens") reworded to "An API that provides random images of kittens", matching `README.md`'s tagline. **Note:** this only updates the template — the actual `config.json` on the production server is gitignored and won't pick this up automatically; it needs updating there by hand (same as the `title` field previously)

## v1.4.1

### Fixed
- Homepage footer's copyright line showed `{{ config.title }}` ("Kittens") as the copyright holder with only the current year — now reads `2024-{{ year }} StuxAPIs`, matching the copyright holder/start year used in `LICENSE`

## v1.4.0

### Added
- Self-hosted [Fredoka](https://fonts.google.com/specimen/Fredoka) (SIL Open Font License, variable weight 400-700, Latin subset) — `templates/assets/fonts/Fredoka.woff2` plus its `OFL.txt` license, wired up via `@font-face` in `kittens.css`. Replaces the default system font stack site-wide; no external Google Fonts request is made

### Changed
- `templates/assets/` reorganized into `css/`, `fonts/`, and `images/` subfolders instead of one flat directory
- `/assets/<filename>` route changed to `/assets/<path:filename>` so nested asset paths (e.g. `assets/fonts/Fredoka.woff2`) actually resolve — the previous single-segment route 404'd on anything not directly in `templates/assets/`. This only affects the `/assets/*` prefix; the root-level kitten image routes (`/<filename>`, `/random`, etc.) are untouched and still resolve exactly as before (e.g. `https://kittens.stuxapis.net/ch5brn70egd_kitten.jpeg`)

## v1.3.0

### Added
- `/changelog` — renders this file (minus the leading title/intro) as HTML via the new `markdown` dependency, styled to match the legal pages
- Homepage footer now shows a copyright line and the running version (read from `VERSION.md` at startup), linked to `/changelog` — replacing the old bare "Boring Legal Stuff" link

### Changed
- Moved the legal pages' shared container/typography styles out of `templates/legal/_base.html`'s embedded `<style>` block and into `templates/assets/kittens.css`, so the new changelog page (which isn't part of the legal-page block hierarchy) can reuse the same layout

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
