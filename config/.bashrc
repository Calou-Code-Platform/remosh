export VIRTUAL_ENV_DISABLE_PROMPT=1

PROMPT_COMMAND='if [ "$CCP_PROMPT_SHOWN" ]; then echo; else CCP_PROMPT_SHOWN=1; fi'

_get_venv_prompt() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        echo -ne "${venv_name} | "
    fi
}

PS1='╭-  | \A | $(_get_venv_prompt)\u@\h | \w | \n╰► '

chcfd() {
    if [ -z "$1" ]; then
        echo "Missing token."
        echo "Usage: chcfd <your_token>"
        return 1
    fi

    echo "$1" | sudo tee /spc/cloudflared > /dev/null
    echo "Token updated to /spc/cloudflared"

    sudo pkill -f cloudflared 2>/dev/null

    sudo sh -c "nohup cloudflared tunnel run --token '$1' > /var/log/cloudflared.log 2>&1 &"
    echo "Cloudflared tunnel restarted."
}
