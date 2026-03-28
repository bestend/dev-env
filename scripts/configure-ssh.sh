#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}

mkdir -p /var/run/sshd "${TARGET_HOME}/.ssh"
chmod 700 "${TARGET_HOME}/.ssh"
cat > /etc/ssh/sshd_config.d/99-dev-image.conf <<SEOF
Port 2222
Protocol 2
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
AllowTcpForwarding yes
PrintMotd no
Subsystem sftp /usr/lib/openssh/sftp-server
AllowUsers ${TARGET_USER}
SEOF
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}/.ssh"
