cfd() {
    if [ -z "$1" ]; then
        echo "If you want change your cloudflared tunnel token, please use 'cfd <YOUR_TOKEN>'."
        return 1
    fi

    if pgrep -x "cloudflared" > /dev/null; then
        pkill -x "cloudflared"
    fi

    CLOUDFLARED_FLAGS="/ccp/flags/cloudflared"

    mkdir -p "$(dirname "$CLOUDFLARED_FLAGS")"

    echo "$1" > "$CLOUDFLARED_FLAGS"
    echo "Token has been changed."

    cloudflared_token=$(cat "$CLOUDFLARED_FLAGS" | tr -d '\n\r' | xargs)
    nohup cloudflared tunnel run --token "$cloudflared_token" > /var/log/cloudflared.log 2>&1 &
}