#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "init at $(date)"
# save borg server fingerprint
ssh-keyscan -H $BORG_SERVER  >> /root/.ssh/known_hosts
# save passphrase
eval "$(ssh-agent -s)"
DISPLAY=":0.0" SSH_ASKPASS="/var/lib/borg_client/echo_passphrase.sh" setsid ssh-add /var/lib/borg_client/priv_key </dev/null

# call script when receiving SIGHUP
# set -e exits script after trap
set +e
# ensure containers are started
trap 'bash "/var/lib/borg_client/borg_client.sh" || echo "borg_backup.sh failed"' HUP

# await SIGHUP
while :; do
    sleep 10 & wait ${!}
done

