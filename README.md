# NAK

Active defense for a server on the public Internet.

## Features

- Downloads country-based zone files for whitelist/blacklist ipset filtering
- Monitors Caddy logs for bot/hack attempts with automatic addition to a banned ipset

## Installation

sudo ./install.sh

## Enable

sudo nak enable

## Disable

sudo nak disable

## Installation

sudo ./uninstall.sh

## Default installation directories are defined in lib/common:

LIB_DIR="/usr/local/lib/nak"
BIN_DIR="/usr/local/bin"
DATA_DIR="/var/lib/nak"
CONFIG_FILE="/etc/nak"
LOG_FILE="/var/log/nak"

## to watch caddy tailer:

```zsh
sudo journalctl -u nak-caddy -f
```

## To see what's in the current ipset

ipset list nak-caddy

## to extract matching uris

grep -o '"uri":"[^"]*"' "/var/log/caddy/nak.log" | sed 's/.*"uri":"\([^"]*\)".*/\1/' > "/var/log/caddy/nak_uris"

## To get caddy working:

- Make sure caddy can write to /var/log/caddy/nak.log
- See the enclosed Caddyfile.sample for directives

