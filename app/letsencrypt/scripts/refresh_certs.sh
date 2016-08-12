#!/bin/bash
set -e

echo "$(date) Fetching certs..."
/letsencrypt/fetch_certs.sh

echo "$(date) Saving certs..."
/letsencrypt/save_certs.sh

echo "$(date) Recreating pods..."
/letsencrypt/recreate_pods.sh
