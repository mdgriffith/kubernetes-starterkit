#!/bin/bash

CRON_FREQUENCY=${CRON_FREQUENCY:-"$minute $hour $day * *"}


echo "Configuring cron..."
echo "DOMAINS: " $DOMAINS
echo "EMAIL: " $EMAIL
echo "SECRET_NAME: " $SECRET_NAME
echo "RENEWAL_FREQUENCY: " $RENEWAL_FREQUENCY
# Once a month, fetch and save certs + restart pods.

if [ -n "${LETSENCRYPT_ENDPOINT+1}" ]; then
    echo "server = $LETSENCRYPT_ENDPOINT" >> /etc/letsencrypt/cli.ini
fi

# The process running under cron needs to know where the to find the kubernetes api
env_vars="PATH=$PATH KUBERNETES_PORT=$KUBERNETES_PORT KUBERNETES_PORT_443_TCP_PORT=$KUBERNETES_PORT_443_TCP_PORT KUBERNETES_SERVICE_PORT=$KUBERNETES_SERVICE_PORT KUBERNETES_SERVICE_HOST=$KUBERNETES_SERVICE_HOST KUBERNETES_PORT_443_TCP_PROTO=$KUBERNETES_PORT_443_TCP_PROTO KUBERNETES_PORT_443_TCP_ADDR=$KUBERNETES_PORT_443_TCP_ADDR KUBERNETES_PORT_443_TCP=$KUBERNETES_PORT_443_TCP"

line="$RENEWAL_FREQUENCY $env_vars SECRET_NAME=$SECRET_NAME DOMAINS='$DOMAINS' EMAIL=$EMAIL /bin/bash /letsencrypt/refresh_certs.sh >> /var/log/cron-encrypt.log 2>&1"
(crontab -u root -l; echo "$line" ) | crontab -u root -
