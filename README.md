<p align="center">
  <img src="https://global.media.stuxapis.net/kittens/logo.svg" width="300" alt="Kittens">
</p>

# Kittens

An API that provides random images of kittens. Built & Maintained by [StuxAPIs](https://stuxapis.net), Hosted by [Stuxedo](https://stuxedo.com).

- Live: https://kittens.stuxapis.net
- `GET /random` — redirect to a random kitten image
- `GET /random.json` — `{ "file": "<url>" }`
- `GET /randomfile` — random kitten image, served directly
- `GET /randomaf` — random kitten image, served as an attachment

## Open Source

The project is fully open source.

## Website

- About: [/about](https://kittens.stuxapis.net/about)
- Legal: [/legal](https://kittens.stuxapis.net/legal)
- Changelog: [/changelog](https://kittens.stuxapis.net/changelog) — renders [CHANGELOG.md](CHANGELOG.md) as HTML
- Styling: a small self-contained stylesheet (`assets/css/kittens.css`), no external framework
- Font: [Fredoka](https://fonts.google.com/specimen/Fredoka), self-hosted under `assets/fonts/` (SIL Open Font License, see `OFL.txt` there)
- Branding (`logo.svg`/`icon.png`): hosted on the shared StuxAPIs media CDN at [global.media.stuxapis.net/kittens](https://global.media.stuxapis.net/kittens), not vendored in this repo

## Local development

```bash
pip install -r requirements.txt
cp config.json.example config.json
python index.py
```

Or use the bundled dev server, which forces dev-mode config for you:

```bash
./dev-server.sh      # Linux/macOS
dev-server.bat       # Windows
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

## Copyright

(C) 2024-2026 Stux.Group. All rights reserved.

---

*Built & Maintained by <img src="https://global.media.stuxapis.net/icon.png" height="14" alt="StuxAPIs" valign="middle"> [StuxAPIs](https://stuxapis.net), Hosted by <img src="https://github.com/Stuxedo.png" height="14" alt="Stuxedo" valign="middle"> [Stuxedo](https://stuxedo.com).    
StuxAPIs is a part of the <img src="https://global.media.stux.group/global/icon.png" height="14" alt="Stux.Group" valign="middle"> Stux.Group brand of businesses.*
