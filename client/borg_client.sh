#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function prune_and_compact() {
    if [ ! -z ${PRUNE_CFG+x} ]; then
        echo "running: borg -r $1 prune $PRUNE_CFG"
        borg -r $1 prune $PRUNE_CFG
    else
        echo "PRUNE_CFG not defined"
    fi

    echo "compacting borg repo"
    borg -r $1 compact
}

function backup_repo() {
    SERVER_REPO="ssh://root@${BORG_SERVER}/var/lib/borg_server/repos/$1"
    CLIENT_REPO="/var/lib/borg_client/repos/$1"
    echo "start backup of repo '$1' at $(date)"

    # validate repos
    if ! borg -r $SERVER_REPO check --rsh "$RSH"; then
        echo "ERROR: borg server repo '$1' invalid"
        return
    fi
    echo "borg server repo '$1' valid"
    if ! borg -r $CLIENT_REPO check; then
        echo "ERROR: borg client repo '$1' invalid"
        return
    fi
    echo "borg client repo '$1' valid"

    borg -r $CLIENT_REPO transfer --other-repo $SERVER_REPO --dry-run
    borg -r $CLIENT_REPO transfer --other-repo $SERVER_REPO
    borg -r $CLIENT_REPO transfer --other-repo $SERVER_REPO --dry-run

    prune_and_compact $CLIENT_REPO

    echo "finished backup of repo '$1' at $(date)"
}

for REPO in $(ls /var/lib/borg_client/repos/); do
    backup_repo $REPO
done
echo "all done"

