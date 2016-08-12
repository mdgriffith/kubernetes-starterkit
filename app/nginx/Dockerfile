FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY serve /etc/nginx/html/
RUN mkdir -p /usr/local/bin/letsencrypt
RUN mkdir -p /letsencrypt/challenges/.well-known/acme-challenge
