#!/usr/bin/env bash
# Ship the committed code and the local .env to the Google Cloud worker, then
# restart it. Run from the repo root after committing a change.
set -euo pipefail

ZONE=us-central1-a
VM=openreply-worker
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git archive --format=tar.gz -o "$TMP/openreply.tgz" HEAD
cp .env "$TMP/openreply.env"
gcloud compute scp "$TMP/openreply.tgz" "$TMP/openreply.env" "$VM:~" --zone="$ZONE" --quiet

gcloud compute ssh "$VM" --zone="$ZONE" --quiet --command='set -e
tar -xzf ~/openreply.tgz -C /opt/openreply && rm ~/openreply.tgz
mv ~/openreply.env /opt/openreply/.env && chmod 600 /opt/openreply/.env
cd /opt/openreply && npm ci --no-audit --no-fund >/dev/null && npx prisma generate >/dev/null
sudo systemctl restart openreply-worker
sleep 10 && systemctl is-active openreply-worker'
