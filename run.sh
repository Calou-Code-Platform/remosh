#!/bin/bash

cat title
echo ""

export DEBIAN_FRONTEND=noninteractive

if [ -n "$cloudflared" ]; then
    echo "$cloudflared" > /spc/cloudflared
fi

cloudflared_file="/spc/cloudflared"
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