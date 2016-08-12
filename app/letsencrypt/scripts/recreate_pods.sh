#!/bin/bash

# Update the required env vars for the first pod in each Deployment.
# This will kick off a rolling update.
# Do this so that the secrets can be remounted.

# Current, incorrect command.  Need to get Pod Name.
# kubectl exec POD -c nginx nginx -s reload
