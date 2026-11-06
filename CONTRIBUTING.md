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

## Questions

Reach out at [hello@stuxapis.net](mailto:hello@stuxapis.net).

## Branches

- Work on `test`, or on a branch off it. Never push to `main`
- Changes reach `main` only through a pull request from `test` into `main`, which needs CI to pass and is reviewed and merged by Leo
- Release commits and tags are made on `test` (`git push origin test --tags`) and take effect when the pull request is merged. Merging deploys to the live server (see the README's "Deploying" section).

## Versioning

This project uses [Date Versioning](https://datevers.ing). To release:

1. Add a `## vYY.MM.DD` entry at the top of `CHANGELOG.md`, with its sections in this order: Added, Changed, Fixed, Removed, Security, Deprecated.
2. Set `VERSION.md` to the same bare version (no `v`): today's **UTC** date as `YY.MM.DD`, or `YY.MM.DD-1`, `-2`… for later releases the same UTC day. Never a future date. Use UTC, not local time: just after midnight in the UK it is still the previous day in UTC.
3. Run `bash tests/version.sh` and `python -m unittest discover -s tests`.
4. Run `./commit.sh` (or `commit.bat` on Windows). It checks the version, commits and tags `vYY.MM.DD`, and never pushes.
