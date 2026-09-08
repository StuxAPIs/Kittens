<p align="center">
  <img src="templates/assets/logo.svg" width="300" alt="Kittens">
</p>

# Kittens

An API that provides random images of kittens. Built & Maintained by [StuxAPIs](https://github.com/StuxAPIs), Hosted by [Stuxedo](https://stuxedo.com).

- Live: https://kittens.stuxapis.net
- `GET /random` — redirect to a random kitten image
- `GET /random.json` — `{ "file": "<url>" }`
- `GET /randomfile` — random kitten image, served directly
- `GET /randomaf` — random kitten image, served as an attachment

## Open Source

The project is fully open source.

## Website

- Legal: [/legal](https://kittens.stuxapis.net/legal)

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

*Built & Maintained by <img src="https://github.com/StuxAPIs.png" height="14" alt="StuxAPIs" valign="middle"> [StuxAPIs](https://github.com/StuxAPIs), Hosted by <img src="https://github.com/Stuxedo.png" height="14" alt="Stuxedo" valign="middle"> [Stuxedo](https://stuxedo.com).    
StuxAPIs is a part of the <img src="https://media.stux.group/global/icon.png" height="14" alt="Stux.Group" valign="middle"> Stux.Group brand of businesses.*
