#!/bin/bash
# Kittens - sets up automatic deploys from GitHub on the live server (run as root).
#
# Usage: deploy/auto-deploy/install.sh "DEPLOY_PUBLIC_KEY" VENV [HEALTH_URL] [SITE_DIR] [SITE_USER]
#   DEPLOY_PUBLIC_KEY  the public half of a key made only for this server's Kittens deploys (never a login key)
#   VENV               the virtualenv the app runs from (its bin/pip installs requirements.txt)
#   HEALTH_URL         default: http://127.0.0.1:8000/health.json (the app itself, not a cached copy)
#   SITE_DIR / USER    default: the checkout this script is in, and the user that owns it
#
# Installs:
#   /usr/local/sbin/kittens-deploy      root-owned copy of kittens-deploy.sh (outside the checkout)
#   /etc/default/kittens-deploy         its settings
#   root's authorized_keys              the deploy key, restricted to running only that command
# Safe to run again: it replaces the installed copy and the settings, and adds the key only once.
# Re-run it when kittens-deploy.sh changes, since root runs the installed copy, not the repo's.
set -euo pipefail

USAGE='usage: install.sh "DEPLOY_PUBLIC_KEY" VENV [HEALTH_URL] [SITE_DIR] [SITE_USER]'
PUBKEY="${1:?$USAGE}"
VENV="$(cd "${2:?$USAGE}" && pwd)"
HEALTH_URL="${3:-http://127.0.0.1:8000/health.json}"
SITE="$(cd "${4:-$(dirname "$0")/../..}" && pwd)"
USER_NAME="${5:-$(stat -c %U "$SITE")}"
[ "$(id -u)" = 0 ] || { echo "run as root" >&2; exit 1; }
[[ "$PUBKEY" =~ ^ssh-ed25519\ [A-Za-z0-9+/=]+(\ .*)?$ ]] || { echo "that is not an ed25519 SSH public key" >&2; exit 1; }
[ -x "$VENV/bin/pip" ] || { echo "no pip in $VENV/bin" >&2; exit 1; }
[ -f "$SITE/config.json" ] || { echo "no config.json in $SITE: is that the live checkout?" >&2; exit 1; }
for cmd in git curl flock sudo; do
    command -v "$cmd" >/dev/null || { echo "missing: $cmd" >&2; exit 1; }
done
sudo -u "$USER_NAME" -H bash -lc 'command -v pm2' >/dev/null || { echo "pm2 is not on $USER_NAME's PATH" >&2; exit 1; }
# The running app must already serve /health.json (this release, pulled and restarted by hand once), or every
# deploy would fail its health check. Pass the right HEALTH_URL if the app listens somewhere else.
curl -fsS -m 30 "$HEALTH_URL" | grep -q '"ok": *true' || {
    echo "$HEALTH_URL does not answer ok: pull this release, restart the app, and pass the right HEALTH_URL" >&2
    exit 1
}

install -m 755 -o root -g root "$(dirname "$0")/kittens-deploy.sh" /usr/local/sbin/kittens-deploy
cat > /etc/default/kittens-deploy <<EOF
# Kittens automatic deploys (deploy/auto-deploy/install.sh)
SITE_DIR=$SITE
SITE_USER=$USER_NAME
HEALTH_URL=$HEALTH_URL
VENV=$VENV
PM2_APP=Kittens
EOF
chmod 644 /etc/default/kittens-deploy

install -d -m 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
KEY_BODY="$(echo "$PUBKEY" | cut -d' ' -f2)"
if grep -qF "$KEY_BODY" /root/.ssh/authorized_keys; then
    echo "deploy key already in root's authorized_keys"
else
    printf 'restrict,command="/usr/local/sbin/kittens-deploy" %s\n' "$PUBKEY" >> /root/.ssh/authorized_keys
    echo "deploy key added to root's authorized_keys (it can only run /usr/local/sbin/kittens-deploy)"
fi
echo "installed /usr/local/sbin/kittens-deploy for $SITE (as $USER_NAME, venv $VENV)"
