#!/bin/bash -e

if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
    # Copy production salt formulas
    [ -d /srv/salt/env ] || mkdir -p /srv/salt/env
    [ -e /srv/salt/env/prd ] || ln -s /usr/share/salt-formulas/env /srv/salt/env/prd

    for i in /usr/share/salt-formulas/env/*; do
        [ -d /srv/salt/reclass/classes/service ] || mkdir -p /srv/salt/reclass/classes/service
        fn=$(basename $i)
        [ -e /srv/salt/reclass/classes/service/$fn ] || ln -s $i /srv/salt/reclass/classes/service/$fn
    done

    exec /usr/bin/salt-master --log-file-level=quiet --log-level=info "$@"
else
    exec "$@"
fi
