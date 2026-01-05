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

  touch "/home/$username/.sudo_as_admin_successful"

  cp "/cont/get-builder.sh" "/home/$username/get-builder.sh"
  cp "/cont/.bashrc" "/home/$username/.bashrc"
  cp "/cont/.bash_profile" "/home/$username/.bash_profile"

  mkdir "/home/$username/workspace"
  
  chown -R $username:$username "/home/$username/"
else
  echo "$username already loaded."
fi

echo "Server is running..."
exec /usr/sbin/sshd -D
