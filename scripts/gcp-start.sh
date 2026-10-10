#!/usr/bin/env bash
# Turn the Google Cloud worker back on (relinks billing if it was unlinked).
set -euo pipefail
# Your project and billing ids live in the local .env (never committed)
if [[ -f .env ]]; then set -a; source .env; set +a; fi
PROJECT="${GCP_PROJECT:?set GCP_PROJECT to your Google Cloud project id}"
ZONE=us-central1-a
BILLING="${GCP_BILLING:?set GCP_BILLING to your billing account id}"

if [[ "$(gcloud billing projects describe "$PROJECT" --format='value(billingEnabled)')" != "True" ]]; then
  gcloud billing projects link "$PROJECT" --billing-account="$BILLING" --quiet
fi
gcloud compute instances start openreply-worker --project="$PROJECT" --zone="$ZONE" --quiet
echo "Server starting. The worker service starts on boot."
