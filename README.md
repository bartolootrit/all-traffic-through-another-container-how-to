### How to route all Docker container's traffic through a VPN in another container

#### Setup:

- `docker network create vpn`

- `cd wireguard`

- `docker compose build --progress plain wireguard`

- `docker compose up -d wireguard`

- `cd ../app`

- `docker compose up -d app`

#### Check:

This command should print a VPN exit node address without making any DNS queries from the host machine:

`docker compose run --rm app bash -c "apt-get update && apt-get install -y curl && curl 'https://ident.me'"`
 

Other local containers in the Docker network should be accessible by their names:

`docker compose run --rm app bash -c "apt-get update && apt-get install -y redis-tools && redis-cli -h redis set a b"`

### How it works

`network_mode: "container:vpn"` tells Docker to attach `app` to the `wireguard` networking stack. All `app` network traffic will be routed through the `wireguard` network. The [documentation](https://docs.docker.com/reference/compose-file/services/#network_mode) says: "container:{name}: Gives the container access to the specified container by referring to its container ID". It's not clear from the documentation whether a container name can also be used. 

`container_name: vpn` gives a short name to the `wireguard` container.

`app` container is now integrated into the `wireguard` container's network, so `app` cannot reach `redis`, because `redis` is not in `wireguard`'s Docker Compose file. `redis` container is added to the `vpn` external network to fix this.

`app` DNS queries will go through the `wireguard` container's network, but the `wireguard` container will use a  host machine's DNS by default. One of the approaches to address this issue is "DNS over HTTPS". [DNSCrypt proxy](https://github.com/DNSCrypt/dnscrypt-proxy) is used as a local DNS proxy for sending DoH requests through the Wireguard tunnel. Note `dns: - 127.0.0.1` in the Docker Compose file.

DNSCrypt fetches a [public server list](https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md) by default. `server_names = ['static_cloudflare']` tells it to use the static server list in [DNS stamp](https://adguard-dns.io/kb/miscellaneous/create-dns-stamp/) format.

The downside of this approach is that `app` will lose network access if `wireguard` is restarted
