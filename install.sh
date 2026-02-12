#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/lib/common"
printf "${COL_C}Welcome to${COL_RESET} ${COL_P}nak${COL_RESET}${COL_C}!${COL_RESET}\n"

# needs sudo
if [ "$(id -u)" -ne 0 ]; then
    printf "${COL_R}Sorry, this script must be run as root.${COL_RESET}\n"
    exit 1
fi

if [[ ! -f $LOG_FILE ]]; then
    printf "Creating log file at ${LOG_FILE}...              "
    touch "$LOG_FILE"
    if [[ -f "${LOG_FILE}" ]]; then
        printf "${COL_G}✔${COL_RESET}\n"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        echo "Please check the installation script and try again."
        log "install.sh: Failed installing log file to ${LOG_FILE}"
        exit 1
    fi
fi

install_bin() {
    printf "Installing binary files to ${BIN_DIR}...      "
    mkdir -p $BIN_DIR
    cp $SCRIPT_DIR/bin/nak $BIN_DIR/
    chmod 755 $BIN_DIR/nak
    if [[ -f "${BIN_DIR}/nak" ]]; then
        printf "${COL_G}✔${COL_RESET}\n"
        log "install.sh: Installed binary to ${BIN_DIR}/nak"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        echo "Please check the installation script and try again."
        log "install.sh: Failed installing binary to ${BIN_DIR}/nak"
        exit 1
    fi
}

install_lib() {
    printf "Installing library files to ${LIB_DIR}... "
    mkdir -p $LIB_DIR $CMD_DIR $MOD_DIR
    cp -r $SCRIPT_DIR/lib/* $LIB_DIR/
    cp -r $SCRIPT_DIR/lib/cmd/* $CMD_DIR/
    cp -r $SCRIPT_DIR/lib/mod/* $MOD_DIR/
    chmod -R 755 $LIB_DIR $CMD_DIR $MOD_DIR

    if [[ -f "${LIB_DIR}/common" ]]; then
        printf "${COL_G}✔${COL_RESET}\n"
        log "install.sh: Installed lib files to ${LIB_DIR}"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        echo "Please check the installation script and try again."
        log "install.sh: Failed installing lib to ${LIB_DIR}"
        exit 1
    fi
}

if [[ -d $LIB_DIR ]]; then
    read -rp "${LIB_DIR} already exists. Reinstall? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        log "install.sh: Deleted old installation at ${LIB_DIR}"
        rm -rf $LIB_DIR
    else
        echo "Exiting installer."
        exit 0
    fi
fi

install_lib
install_bin

install_data() {
    printf "Creating data directories at ${DATA_DIR}...      "
    mkdir -p $DATA_DIR $ZONE_DIR $TMP_DIR

    if [[ -d "${DATA_DIR}" ]]; then
        printf "${COL_G}✔${COL_RESET}\n"
        log "install.sh: Installed lib files to ${LIB_DIR}"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        echo "Please check the installation script and try again."
        log "install.sh: Failed installing data directories at ${DATA_DIR}"
        exit 1
    fi
}

if [[ -d $DATA_DIR ]]; then
    read -rp "${DATA_DIR} already exists (zone files). Delete? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf $DATA_DIR
        log "install.sh: Removed existing data directory"
        install_data
    fi
else
    install_data
fi

# /etc/nak

install_config() {
    printf "Copying default config file to ${CONFIG_FILE}...        "
    cp $SCRIPT_DIR/etc/nak $CONFIG_FILE

    if [[ -f "${CONFIG_FILE}" ]]; then
        printf "${COL_G}✔${COL_RESET}\n"
        log "install.sh: Installed default config file at ${CONFIG_FILE}"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        echo "Please check the installation script and try again."
        log "install.sh: Failed installing config at ${CONFIG_FILE}"
        exit 1
    fi
}

if [[ -f $CONFIG_FILE ]]; then
    read -rp "${CONFIG_FILE} already exists. Overwrite with defaults? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf $CONFIG_FILE
        log "install.sh: Removed existing config file"
        install_config
    fi
else
    install_config
fi

check_and_install_netfilter_persistent() {
    if ! command -v netfilter-persistent >/dev/null 2>&1; then
        echo
        echo "netfilter-persistent not found on this system."

        if [[ -f /etc/debian_version ]]; then
            read -rp "Install netfilter-persistent? [y/N]: " answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                apt-get update
                apt-get install -y netfilter-persistent
            else
                echo "Skipping installation of netfilter-persistent."
            fi
        else
            echo "Skipping netfilter-persistent installation (not a Debian system)."
        fi
    fi
}

check_and_install_netfilter_persistent



## Caddy

install_caddy() {
    # check if caddy exists
    if ! command -v caddy >/dev/null 2>&1; then
        echo
        echo "Caddy not found on this system. Skipping."
    else
        # Caddy log file
        mkdir -p /var/log/caddy
        touch /var/log/caddy/nak.log

        # Caddy rules - import into Caddyfile
        cp -r $SCRIPT_DIR/caddy/nak.caddy $DATA_DIR/

        # zone file
        touch "${ZONE_DIR}/caddy.zone"

        # tail script
        cp $SCRIPT_DIR/caddy/nak-caddy ${LIB_DIR}/nak-caddy
        chmod +x ${LIB_DIR}/nak-caddy

        # service
        cp $SCRIPT_DIR/caddy/nak-caddy.service /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable nak-caddy.service
        # systemctl start nak-caddy.service
    fi
}

install_caddy

install_service() {
    printf "Installing nak.service...                            "
    cp $SCRIPT_DIR/nak.service /etc/systemd/system/nak.service
    systemctl daemon-reload
    systemctl enable nak.service
    if systemctl is-enabled --quiet nak.service; then
        printf "${COL_G}✔${COL_RESET}\n"
        log "install.sh: Installed and enabled nak.service"
    else
        printf "${COL_R}✘${COL_RESET}\n"
        log "install.sh: Failed to enable nak.service"
    fi
}

install_service

printf "${COL_G}Installation complete!${COL_RESET}\n"
printf "You can now run ${COL_C}nak enable${COL_RESET} to enable modules.\n"
printf "It's probably a good idea to whitelist yourself in /usr/local/lib/nak/nak-caddy\n"
printf "For help, run ${COL_C}nak help${COL_RESET}.\n"
