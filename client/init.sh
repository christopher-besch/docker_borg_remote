#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "init at $(date)"
# save passphrase
eval "$(ssh-agent -s)"
DISPLAY=":0.0" SSH_ASKPASS="/var/lib/borg_client/echo_passphrase.sh" setsid ssh-add /var/lib/borg_client/priv_key </dev/null

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export RSH="ssh -i /var/lib/borg_client/priv_key -o 'StrictHostKeyChecking no' -p ${PORT}"

for REPO in $(ls /var/lib/borg_client/repos/); do
    CLIENT_REPO="/var/lib/borg_client/repos/$REPO"
    if [ -z "$(ls -A $CLIENT_REPO)" ]; then
       echo "$CLIENT_REPO is empty, creating borg repo"
       borg -r $CLIENT_REPO rcreate --encryption=none
    else
        echo "$CLIENT_REPO is not empty"
    fi
done

# call script when receiving SIGHUP
# set -e exits script after trap
set +e
trap 'bash "/var/lib/borg_client/borg_client.sh" || echo "borg_client.sh failed"' HUP

# await SIGHUP
while :; do
    sleep 10 & wait ${!}
done

