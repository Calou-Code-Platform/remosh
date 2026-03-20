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

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install cloudflared

if "$cloudflared" != ""; then
  echo "Detect cloudflared tunnel token."
  nohup cloudflared tunnel run --token "$cloudflared" > /var/log/cloudflared.log 2>&1 &
else
  echo "Skip cloudflared tunnel, if need open tunnel, please token to ENV -> cloudflared"
fi

echo "Server is running..."
exec /usr/sbin/sshd -D