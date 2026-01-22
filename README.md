# NAK

Active defense for a server on the public Internet.

## Features

- Downloads country-based zone files for whitelist/blacklist ipset filtering
- Monitors Caddy logs for bot/hack attempts with automatic addition to a banned ipset

## Installation

```zsh
sudo ./install.sh
```

## Enable

```zsh
sudo nak enable
```

## Disable

```zsh
sudo nak disable
```

## Installation

```zsh
sudo ./uninstall.sh
```

## Default installation directories are defined in lib/common:

```zsh
LIB_DIR="/usr/local/lib/nak"
BIN_DIR="/usr/local/bin"
DATA_DIR="/var/lib/nak"
CONFIG_FILE="/etc/nak"
LOG_FILE="/var/log/nak"
```

## to watch caddy tailer:

```zsh
sudo journalctl -u nak-caddy --no-pager -f
```

## To troubleshoot by watching caddy logs:

```zsh
sudo journalctl -u caddy -n 50 --no-pager -f
```

## To see what's in the current ipset

```zsh
ipset list nak-caddy
```

## to extract matching uris

```zsh
grep -o '"uri":"[^"]*"' "/var/log/caddy/nak.log" | sed 's/.*"uri":"\([^"]*\)".*/\1/' > "/var/log/caddy/nak_uris"
```

## To get caddy working:

- Make sure caddy can write to /var/log/caddy/nak.log
- See the enclosed Caddyfile.sample for directives


## quick summary of entries in ipsets

```bash
sudo ipset list -t
```