# Contributing to Kittens

Thanks for your interest in contributing!

## Local setup

```bash
pip install -r requirements.txt
cp config.json.example config.json
python index.py
```

Or use `./dev-server.sh` (`dev-server.bat` on Windows), which bootstraps
`config.json` and a placeholder `images/` folder for you and forces dev-mode
config so local URLs resolve to `127.0.0.1` out of the box. Pass
`--no-dev-mode` to test the app with your real `config.json` instead.

## Making a change

1. Fork the repository and create a branch for your change.
2. Keep pull requests focused — one change or fix per PR.
3. Test locally with the dev server before submitting.
4. Open a pull request with a clear description of what changed and why.

## Releases

Releases follow [Semantic Versioning](https://semver.org/):

1. Update [CHANGELOG.md](CHANGELOG.md) with what changed.
2. Bump [VERSION.md](VERSION.md).
3. Run `commit.sh` (or `commit.bat` on Windows) to commit and tag the release.

## Questions

Reach out at [hello@stuxapis.net](mailto:hello@stuxapis.net).
