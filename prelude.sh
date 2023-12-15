#!/bin/bash -e
mkdir -p /root/.ssh
chmod 700 /root/.ssh

(
  umask 0077
  cat > /root/.ssh/id_ed25519 <<<"$NETBOX_SSH_ID_ED25519"
)

