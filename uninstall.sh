#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/lib/common"

# needs sudo
if [ "$(id -u)" -ne 0 ]; then
    printf "${COL_R}Sorry, this script must be run as root.${COL_RESET}\n"
    exit 1
fi

printf "${COL_P}Uninstalling nak...${COL_RESET}\n"

nak disable

rm -rf "$LIB_DIR" "${BIN_DIR}/nak" "$DATA_DIR" "$LOG_FILE" "$CONFIG_FILE"
rm -rf /etc/systemd/system/nak-caddy.service
if systemctl is-enabled --quiet nak.service 2>/dev/null; then
    systemctl disable nak.service
fi
rm -rf /etc/systemd/system/nak.service
systemctl daemon-reload

printf "${COL_G}Uninstallation complete!${COL_RESET}\n"
