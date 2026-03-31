#!/bin/bash

cat title
echo ""

export DEBIAN_FRONTEND=noninteractive
init_flag="/spc/.initialized"
cloudflared_file="/spc/cloudflared"

if [ ! -f "$init_flag" ]; then
    if id "${username}" >/dev/null 2>&1; then
        echo "User [${username}] already exists."
    else
        old_user=$(getent passwd 1000 | cut -d: -f1)
        if [ -n "$old_user" ]; then
            if [ "$old_user" != "$username" ]; then
                echo "Updating username from $old_user to $username..."
                usermod -l ${username} -aG sudo $old_user
                usermod -d /home/${username} -m ${username}
                groupmod -n ${username} $old_user
            fi
        else
            echo "Creating new user $username..."
            useradd -m -s /bin/bash -u 1000 -G sudo ${username}
        fi

        echo "${username}:${password}" | chpasswd
        echo "root:${sudo_password}" | chpasswd
        cp /spc/.bashrc /home/${username}/.bashrc
        cp /spc/.bash_profile /home/${username}/.bash_profile
        cp /spc/get-builder.sh /home/${username}/get-builder.sh
        chown -R ${username}:${username} /home/${username}
        echo "User and password configured."
    fi

    if [ ! -f "$cloudflared_file" ]; then
        echo "$cloudflared" > "$cloudflared_file"
    fi

    touch "$init_flag"
    echo "Initialization complete."
fi

if [ -s "$cloudflared_file" ]; then
    echo "cloudflared token detect."
    cloudflared_token=$(cat "$cloudflared_file" | tr -d '\n\r' | xargs)

    echo "updating cloudflared..."
    mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y cloudflared >/dev/null 2>&1
    apt-get clean >/dev/null 2>&1
    rm -rf /var/lib/apt/lists/* >/dev/null 2>&1

    if [ -n "$cloudflared_token" ]; then
        nohup cloudflared tunnel run --token "$cloudflared_token" > /var/log/cloudflared.log 2>&1 &
        echo "cloudflared is openned."
    else
        echo "Where is the token go?"
    fi
else
    echo "Where is the token go?"
fi

echo "Server is running..."
exec /usr/sbin/sshd -D
