#!/bin/bash
cat /ccp/title
echo ""

# 創建旗標
if [ ! -e "flags" ]; then
    mkdir -p flags
fi

# 建立使用者旗標和通道旗標
USER_FLAGS="user"
CLOUDFLARED_FLAGS="cloudflared"

# 判斷使用者帳號是否修改
if [ ! -f "flags/$USER_FLAGS" ]; then
    echo "Initialization root password..."
    printf 'root:%s\n' "$password" | chpasswd

    cp /ccp/.bashrc /root/.bashrc
    cp /ccp/.bash_profile /root/.bash_profile

    touch "flags/$USER_FLAGS"
fi

# 更新Cloudflared
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
apt-get update -qq >/dev/null 2>&1
apt-get install -y cloudflared >/dev/null 2>&1
apt-get clean >/dev/null 2>&1
rm -rf /var/lib/apt/lists/* >/dev/null 2>&1

# 判斷是否有 Cloudflared Env
if [ ! -z "$cloudflared" ] && [ ! -f "flags/$CLOUDFLARED_FLAGS" ]; then
    echo "Initialization cloudflared..."
    echo "$cloudflared" > "flags/$CLOUDFLARED_FLAGS"
fi

# 判斷 Cloudflared 旗標是否存在
if [ -f "flags/$CLOUDFLARED_FLAGS" ]; then
    cloudflared_token=$(cat "flags/$CLOUDFLARED_FLAGS" | tr -d '\n\r' | xargs)
    nohup cloudflared tunnel run --token "$cloudflared_token" > /var/log/cloudflared.log 2>&1 &
fi

# 自啟動目錄
STARTUP_DIR="/root/startup"

# 建立自動運行目錄
if [ ! -e "$STARTUP_DIR" ]; then
    mkdir -p "$STARTUP_DIR"
fi

# 自啟動
if [ -d "$STARTUP_DIR" ]; then
    for file in "$STARTUP_DIR"/*; do
        if [ -f "$file" ]; then
            session=$(basename "$file")
            chmod +x "$file"
            tmux new-session -d -s "$session" "$file"
        fi
    done
fi

echo "Server opened."
exec /usr/sbin/sshd -D