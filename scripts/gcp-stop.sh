#!/usr/bin/env bash
# Off switch for the Google Cloud worker. Run only after Henry agrees.
#   scripts/gcp-stop.sh         stop the server (reversible, DMs wait in the queue)
#   scripts/gcp-stop.sh --hard  also unlink billing from the project (nothing can bill)
set -euo pipefail
# Your project and billing ids live in the local .env (never committed)
if [[ -f .env ]]; then set -a; source .env; set +a; fi
PROJECT="${GCP_PROJECT:?set GCP_PROJECT to your Google Cloud project id}"
ZONE=us-central1-a

gcloud compute instances stop openreply-worker --project="$PROJECT" --zone="$ZONE" --quiet
echo "Server stopped. Comments queue up; start it again with scripts/gcp-start.sh"

if [[ "${1:-}" == "--hard" ]]; then
  gcloud billing projects unlink "$PROJECT" --quiet
  echo "Billing unlinked. Relink within 30 days or Google may delete the server."
fi
