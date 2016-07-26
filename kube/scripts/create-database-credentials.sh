#!/bin/bash
# Prompts the user for a postgres username and password and
# then creates a kubernetes secret using those values

echo -n "Postgres username?"
read username
echo -n "Postgres password?"
read password

eval "kubectl create secret generic postgres-credentials --from-literal=username=$username --from-literal=password=$password"
