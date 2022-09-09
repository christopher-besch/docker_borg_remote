#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# $1 server repo::archive
# $2 client repo::archive
function pull_archive() {
    cd /
    rm -rf /origin
    mkdir /origin
    cd /origin
    borg extract --rsh "$RSH" $1
    borg create --error --compression $BORG_COMPRESSION "$2" /origin
}

function prune_and_compact() {
    if [ ! -z ${PRUNE_CFG+x} ]; then
        echo "running: borg prune $PRUNE_CFG $1"
        borg prune $PRUNE_CFG $1
    else
        echo "PRUNE_CFG not defined"
    fi

    echo "compacting borg repo"
    borg compact $1
}

# $1 archive
# $2 client archives
function is_archive_present() {
    for CLIENT_ARCHIVE in $2; do
        if [[ $CLIENT_ARCHIVE == $1 ]]; then
            return 0
        fi
    done
    return 1
}

function backup_repo() {
    SERVER_REPO="root@${BORG_SERVER}:/var/lib/borg_server/repos/$1"
    CLIENT_REPO="/var/lib/borg_client/repos/$1"
    echo "start backup of repo '$1' at $(date)"

    # validate repos
    if ! borg check --rsh "$RSH" $SERVER_REPO; then
        echo "ERROR: borg server repo '$1' invalid"
        return
    fi
    echo "borg server repo '$1' valid"
    if ! borg check $CLIENT_REPO; then
        echo "ERROR: borg client repo '$1' invalid"
        return
    fi
    echo "borg client repo '$1' valid"

    # get archive list
    SERVER_ARCHIVES=$(borg list --short --rsh "$RSH" $SERVER_REPO)
    echo "found server archives:"
    echo $SERVER_ARCHIVES
    CLIENT_ARCHIVES=$(borg list --short $CLIENT_REPO)
    echo "found client archives:"
    echo $CLIENT_ARCHIVES

    # pull required archives
    for ARCHIVE in $SERVER_ARCHIVES; do
        if is_archive_present $ARCHIVE "$CLIENT_ARCHIVES"; then
            echo "archive '$ARCHIVE' from '$1' is already present on client"
        else
            echo "pulling archive '$ARCHIVE' from '$1'"
            pull_archive "$SERVER_REPO::$ARCHIVE" "$CLIENT_REPO::$ARCHIVE"
        fi
    done

    prune_and_compact $CLIENT_REPO

    echo "finished backup of repo '$1' at $(date)"
}

for REPO in $(ls /var/lib/borg_client/repos/); do
    backup_repo $REPO
done
echo "all done"

