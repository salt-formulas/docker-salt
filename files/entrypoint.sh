#!/bin/bash -e

## Overridable parameters

ENABLE_SALT_API=${ENABLE_SALT_API:-1}
SETUP_SALT_ENV=${COPY_FORMULAS:-1}

SALT_API_PASSWORD=${SALT_API_PASSWORD:-}

## Functions

function log_info() {
    echo "[INFO] $*"
}

## Main

if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
    if [[ $SETUP_SALT_ENV -eq 1 ]]; then
        # Copy production salt formulas
        log_info "Setting up prd salt env"
        [ -d /srv/salt/env ] || mkdir -p /srv/salt/env
        [ -e /srv/salt/env/prd ] || ln -s /usr/share/salt-formulas/env /srv/salt/env/prd

        for i in /usr/share/salt-formulas/reclass/service/*; do
            [ -d /srv/salt/reclass/classes/service ] || mkdir -p /srv/salt/reclass/classes/service
            fn=$(basename $i)
            [ -e /srv/salt/reclass/classes/service/$fn ] || ln -s $i /srv/salt/reclass/classes/service/$fn
        done
    fi

    if [[ $ENABLE_SALT_API -eq 1 ]]; then
        if [ -n $SALT_API_PASSWORD ]; then
            SALT_API_PASSWORD=$(pwgen -1 8)
            log_info "No SALT_API_PASSWORD provided, using auto-generated ${SALT_API_PASSWORD}"
        fi
        log_info "Setting password for user salt"
        echo "salt:${SALT_API_PASSWORD}" | chpasswd

        log_info "Starting salt-api"
        /usr/bin/salt-api --log-file-level=quiet --log-level=info -d
    fi

    log_info "Starting salt-master"
    exec /usr/bin/salt-master --log-file-level=quiet --log-level=info "$@"
else
    exec "$@"
fi
