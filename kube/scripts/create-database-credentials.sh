#!/bin/bash
# Prompts the user for a postgres username and password and
# then creates a kubernetes secret using those values

echo "Postgres username?"
read -s username
echo "Postgres password?"
read -s password

eval "kubectl create secret generic postgres-credentials --from-literal=username=$username --from-literal=password=$password"
