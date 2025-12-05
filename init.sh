#!/bin/bash

mkdir -p /run/sshd

cat /cont/title
echo -e

if ! id "$username" &>/dev/null; then
  echo "initialization user setting..."
  useradd -m -s /bin/bash -u 1000 "$username"
  echo "$username:$password" | chpasswd
  usermod -aG sudo "$username"

  echo "root:$sudo_password" | chpasswd

  cp "/cont/get-builder.sh" "/home/$username/get-builder.sh"
else
  echo "$username already loaded."
fi

echo "Server is running..."
exec /usr/sbin/sshd -D
