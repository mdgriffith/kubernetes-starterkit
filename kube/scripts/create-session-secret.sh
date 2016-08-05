#!/bin/bash
# Creates a session secret
SECRET=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

eval "kubectl create secret generic session-secret --from-literal=session-secret=$SECRET"
