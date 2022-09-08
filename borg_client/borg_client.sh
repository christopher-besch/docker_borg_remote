#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
borg list --short \
    --rsh "ssh -i /var/lib/borg_client/priv_key -p ${PORT}" \
    root@${BORG_SERVER}:/var/lib/borg_server/repos/borg_repo1

