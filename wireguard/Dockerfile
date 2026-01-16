FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0

# wg-quick requirements: iproute2, procps
# envsubst util: gettext-base
RUN apt-get update && \
    apt-get install -y wireguard iproute2 procps gettext-base wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Patch wg-quick if getting "sysctl: permission denied on key net.ipv4.conf.all.src_valid_mark" error.
#
# Credits: @kianbahasadri from (https://forums.docker.com/t/sysctl-error-setting-key-net-ipv4-conf-all-src-valid-mark-read-only-file-system/92567/10) 
# and https://github.com/linuxserver/docker-wireguard
#
# See also
# https://github.com/wg-easy/wg-easy/issues/2261
# and 
# https://github.com/WireGuard/wireguard-tools/pull/29/files
RUN sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick

RUN mkdir /opt/app
WORKDIR /opt/app

RUN wget -O - https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.15/dnscrypt-proxy-linux_x86_64-2.1.15.tar.gz | tar -xz && cp linux-x86_64/dnscrypt-proxy ./ && rm -r linux-x86_64
COPY ./dnscrypt-proxy.toml ./

COPY ./wg0.conf-template ./
