#!/bin/bash

set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# restrict to borg server command
sed 's@^ssh-rsa@command="borg serve --restrict-to-path /var/lib/borg_server/repos",restrict ssh-rsa@g' /var/lib/borg_server/authorized_keys > /root/.ssh/authorized_keys

# don't detach and print log into stdout
/usr/sbin/sshd -De

