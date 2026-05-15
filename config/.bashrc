update_prompt() {
    if [ "$CCP_PROMPT_SHOWN" ]; then echo; else export CCP_PROMPT_SHOWN=1; fi

    local devbox_tag=""
    if [ -n "$DEVBOX_PROJECT_ROOT" ]; then
        local project_name=$(basename "$DEVBOX_PROJECT_ROOT")
        devbox_tag="\[\e[48;5;39m\]\[\e[97;1m\] devbox: $project_name \[\e[0m\] "
    fi

    local venv_tag=""
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        venv_tag="\[\e[48;5;214m\]\[\e[30;1m\] venv: $venv_name \[\e[0m\] "
    fi

    export PS1="\[\e[1;2m\]╭―\[\e[0m\] ${devbox_tag}${venv_tag}\[\e[97;100m\] \[\e[1m\]\T\[\e[22m\] \[\e[1m\]\h\[\e[22m\] \[\e[0;102m\] \[\e[30;1m\]\u\[\e[22;39m\] \[\e[48;5;21m\] \[\e[97;1m\]\w \[\e[0m\] \n\[\e[1;2m\]╰►\[\e[0m\] "
}

export PROMPT_COMMAND="update_prompt"
export VIRTUAL_ENV_DISABLE_PROMPT=1
export DIRENV_LOG_FORMAT=""

trap 'echo -ne "\e[0m"' DEBUG

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

devbox() {
    command devbox "$@"
    local exit_code=$?
    
    if [[ "$1" == "init" || "$1" == "add" ]] && [ $exit_code -eq 0 ]; then
        if [ ! -f .envrc ]; then
            command devbox generate direnv > /dev/null 2>&1
            direnv allow > /dev/null 2>&1
        fi
    fi
    return $exit_code
}