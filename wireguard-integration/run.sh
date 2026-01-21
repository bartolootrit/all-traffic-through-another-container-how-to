#!/usr/bin/env bash
set -e
envsubst < wg0.conf-template > /etc/wireguard/wg0.conf
wg-quick up wg0
./dnscrypt-proxy -service start
wait-for-it 127.0.0.1:53

exec "$@"
