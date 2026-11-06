#!/bin/bash
# Kittens - deploys main to the live site. Installed root-owned as /usr/local/sbin/kittens-deploy by
# install.sh, outside the site's checkout, so nothing pushed to the repo can change what root runs here.
#
# It's the forced command of the deploy key (see install.sh), so the only thing that key can do is ask for:
#   deploy <40-character commit sha>
# GitHub Actions (.github/workflows/deploy.yml) sends the sha that CI just tested on main. If main has moved
# on since, this deploys nothing and leaves it to the newer commit's own run.
#
# Steps: one deploy at a time (lock), back up config.json, fast-forward the checkout as the site's own user,
# install requirements.txt into the venv when it changed (a missing dependency crash-loops the app), restart
# the pm2 app, then check /health.json reports ok and the new version. Untracked live data (config.json,
# images/) is never removed: there is no git clean here.
# Settings come from /etc/default/kittens-deploy (written by install.sh).
set -euo pipefail

CONF=/etc/default/kittens-deploy
# shellcheck source=/dev/null
[ -r "$CONF" ] && . "$CONF"
SITE_DIR="${SITE_DIR:?SITE_DIR is not set in $CONF}"
SITE_USER="${SITE_USER:?SITE_USER is not set in $CONF}"
HEALTH_URL="${HEALTH_URL:?HEALTH_URL is not set in $CONF}"
VENV="${VENV:-}"
PM2_APP="${PM2_APP:-Kittens}"
BACKUP_DIR="${BACKUP_DIR:-/root/kittens-backups}"
KEEP_BACKUPS="${KEEP_BACKUPS:-30}"

REQUEST="${SSH_ORIGINAL_COMMAND:-${*:-}}"
if ! [[ "$REQUEST" =~ ^deploy\ ([0-9a-f]{40})$ ]]; then
    echo "usage: deploy <40-character commit sha>" >&2
    exit 2
fi
SHA="${BASH_REMATCH[1]}"

exec 9>/run/kittens-deploy.lock
flock -w 300 9 || { echo "another deploy is still running" >&2; exit 1; }

site_git() { sudo -u "$SITE_USER" git -C "$SITE_DIR" "$@"; }
# A login shell, so the site user's PATH (where pm2 is installed) applies.
site_pm2() { sudo -u "$SITE_USER" -H bash -lc "pm2 $*"; }

[ "$(site_git rev-parse --abbrev-ref HEAD)" = main ] || { echo "the checkout is not on main" >&2; exit 1; }
site_git fetch -q origin main
LATEST="$(site_git rev-parse FETCH_HEAD)"
if [ "$LATEST" != "$SHA" ]; then
    echo "main has moved on to ${LATEST:0:7} since ${SHA:0:7} was tested; its own run deploys it"
    exit 0
fi

OLD="$(site_git rev-parse HEAD)"
if [ "$OLD" = "$SHA" ]; then
    echo "already at ${SHA:0:7}"
else
    DEPS_CHANGED=0
    if site_git diff --name-only "$OLD" "$SHA" -- requirements.txt | grep -q .; then
        DEPS_CHANGED=1
        if [ -z "$VENV" ] || [ ! -x "$VENV/bin/pip" ]; then
            echo "requirements.txt changed but VENV ($VENV) has no bin/pip: set VENV in $CONF; nothing deployed" >&2
            exit 1
        fi
    fi

    STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
    install -d -m 700 "$BACKUP_DIR" "$BACKUP_DIR/$STAMP"
    cp -p "$SITE_DIR/config.json" "$BACKUP_DIR/$STAMP/"
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d | sort | head -n -"$KEEP_BACKUPS" | xargs -r rm -rf
    echo "config.json backed up to $BACKUP_DIR/$STAMP"

    site_git merge -q --ff-only "$SHA"

    if [ "$DEPS_CHANGED" = 1 ]; then
        if ! sudo -u "$SITE_USER" -H "$VENV/bin/pip" install -q -r "$SITE_DIR/requirements.txt"; then
            # The running app still has the old code loaded; put the checkout back to match it.
            site_git reset -q --keep "$OLD"
            echo "pip install failed; checkout put back to ${OLD:0:7} and the app left running" >&2
            exit 1
        fi
        echo "requirements.txt installed into $VENV"
    fi

    site_pm2 restart "$PM2_APP" >/dev/null
    echo "deployed $(site_git log --oneline -1)"

    if site_git diff --name-only "$OLD" "$SHA" -- deploy/ | grep -q .; then
        echo "NOTE: deploy/ changed in this release. The installed copy of this script is not updated automatically: re-run deploy/auto-deploy/install.sh by hand"
    fi
fi

WANT="$(tr -d '[:space:]' < "$SITE_DIR/VERSION.md")"
for _ in 1 2 3 4 5 6; do
    sleep 3
    BODY="$(curl -fsS -m 30 "$HEALTH_URL" 2>/dev/null)" || BODY=""
    VERSION="$(printf '%s' "$BODY" | grep -o '"version": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
    if printf '%s' "$BODY" | grep -q '"ok": *true' && [ "$VERSION" = "$WANT" ]; then
        echo "health check ok: version $VERSION"
        exit 0
    fi
done
echo "health check failed: wanted version $WANT and ok, got: ${BODY:-no response}" >&2
exit 1
