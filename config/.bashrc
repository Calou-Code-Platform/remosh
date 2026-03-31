PROMPT_COMMAND='if [ "$CCP_PROMPT_SHOWN" ]; then echo; else CCP_PROMPT_SHOWN=1; fi'
PS1='\[\e[1;2m\]╭―\[\e[0m\] \[\e[97;100m\] \[\e[1m\]\T\[\e[22m\] \[\e[1m\]\h\[\e[22m\] \[\e[0;102m\] \[\e[30;1m\]\u\[\e[22;39m\] \[\e[48;5;21m\] \[\e[97;1m\]\w \[\e[0m\] \n\[\e[0;1;2m\]╰►\[\e[0m\] '
trap 'echo -ne "\e[0m"' DEBUG

alias reboot='kill -TERM 1'

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