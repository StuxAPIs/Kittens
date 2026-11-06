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

## Deploying

Merging to `main` deploys automatically. Once CI (`.github/workflows/ci.yml`) passes on the push,
`.github/workflows/deploy.yml` connects to the server with a key that can run only
`/usr/local/sbin/kittens-deploy`. Given the tested commit, that script:

1. refuses if `main` has moved on since that commit was tested,
2. backs up `config.json`, then fast-forwards the checkout as the site's own user,
3. installs `requirements.txt` into the venv when it changed, putting the checkout back if that fails,
4. restarts the `Kittens` pm2 app,
5. checks `/health.json` reports `ok` and the new version, failing the run if not.

It never runs `git clean`, so `config.json` and `images/` are left alone.

### Setting it up (once per server)

1. On the server, pull this release into the live checkout and restart the app, so it serves `/health.json`.
2. Make a new ed25519 key used only for this server's Kittens deploys (never a login key, never shared with
   another server).
3. As root, run `deploy/auto-deploy/install.sh "<public key>" <venv path> [health URL]` from the checkout. It
   installs the script root-owned outside the checkout, and adds the key to root's `authorized_keys` as
   `restrict,command="/usr/local/sbin/kittens-deploy"`. The health URL defaults to
   `http://127.0.0.1:8000/health.json`, and the installer checks it answers.
4. Add the repository secrets: `DEPLOY_SSH_KEY` (the private key, then delete it locally),
   `DEPLOY_KNOWN_HOSTS` (the server's ed25519 host key line, checked against its known fingerprint) and
   `DEPLOY_TARGET` (`root@<server>`).

Re-run `install.sh` whenever `deploy/auto-deploy/kittens-deploy.sh` changes: root runs the installed copy, not
the repository's.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

This project uses [Date Versioning](https://datevers.ing): each release is numbered by its UTC release date as `YY.MM.DD` (for example `26.10.23`), with `-1`, `-2`… for later releases the same day. See [CHANGELOG.md](CHANGELOG.md) for what changed in each release.

## License

MIT — see [LICENSE](LICENSE).

## Copyright

(C) 2024-2026 Stux.Group. All rights reserved.

---

*Built & Maintained by <picture><source media="(prefers-color-scheme: dark)" srcset="https://global.media.stuxapis.net/icon-light.png"><source media="(prefers-color-scheme: light)" srcset="https://global.media.stuxapis.net/icon-dark.png"><img src="https://global.media.stuxapis.net/icon-dark.png" height="14" alt="StuxAPIs" valign="middle"></picture> [StuxAPIs](https://stuxapis.net), Hosted by <img src="https://github.com/Stuxedo.png" height="14" alt="Stuxedo" valign="middle"> [Stuxedo](https://stuxedo.com).    
StuxAPIs is a part of the <picture><source media="(prefers-color-scheme: dark)" srcset="https://global.media.stux.group/icon-light.png"><source media="(prefers-color-scheme: light)" srcset="https://global.media.stux.group/icon-dark.png"><img src="https://global.media.stux.group/icon-dark.png" height="14" alt="Stux.Group" valign="middle"></picture> Stux.Group brand of businesses.*
