#!/bin/bash -e
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
cp /opt/netbox/ssh_config "$HOME/.ssh/config"

(
  umask 0077
  cat > "$HOME/.ssh/id_ed25519" <<<"$NETBOX_SSH_ID_ED25519"
)
