#!/bin/bash

cat title
echo ""

export DEBIAN_FRONTEND=noninteractive
init_flag="/spc/.initialized"
cloudflared_file="/spc/cloudflared"

# 如果沒有初始化就執行
if [ ! -f "$init_flag" ]; then
    # 創建使用者
    if id "${username}" >/dev/null 2>&1; then
        echo "User [${username}] already exists."
    else
        # 兼容一堆奇怪預設有 1000 uid 的配置
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
            mkdir /home/${username}/workspace
        fi

        echo "${username}:${password}" | chpasswd
        echo "root:${sudo_password}" | chpasswd
        cp /spc/.bashrc /home/${username}/.bashrc
        cp /spc/.bash_profile /home/${username}/.bash_profile
        cp /spc/get-builder.sh /home/${username}/get-builder.sh
        echo "User and password configured."
    fi

    # 配置 Cloudflared
    if [ ! -f "$cloudflared_file" ]; then
        echo "$cloudflared" > "$cloudflared_file"
    fi

    # 配置direnv
    echo -e "\n\neval \"\$(direnv hook bash)\"" >> /home/${username}/.bashrc
    mkdir -p "/home/${username}/.config/direnv"
    {
        echo '[whitelist]'
        echo "prefix = [ \"/home/${username}/workspace\" ]"
    } > "/home/${username}/.config/direnv/direnv.toml"

    echo "Installing Nix & devbox ..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm >/dev/null 2>&1
    mkdir -p /etc/nix && echo "sandbox = false" >> /etc/nix/nix.conf && echo "build-users-group =" >> /etc/nix/nix.conf
    echo ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" >> /etc/profile
    echo ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" >> /etc/bash.bashrc
    curl -fsSL https://get.jetpack.io/devbox | bash -s -- -f >/dev/null 2>&1

    {
        echo 'export PATH="/nix/var/nix/profiles/default/bin:$PATH"'
        echo 'export NIX_REMOTE=daemon'
    } >> /etc/bash.bashrc

    {
        echo ""
        echo -e "\n\nexport PATH=\"/nix/var/nix/profiles/default/bin:\$PATH\""
        echo 'export NIX_REMOTE=daemon'
    } >> /home/${username}/.bashrc
    
    chmod +x /usr/local/bin/devbox
    chown -R ${username}:${username} /home/${username}

    touch "$init_flag"
    echo "Initialization complete."
fi

#更新並套用 Cloudflared
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
