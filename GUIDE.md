# Limondox CCP Remosh v3.0 Guide

Hi! We are so happy to help you build your SSH container. This guide will help you learn all about the features of Remosh.

## Connecting to the Container
- **Visual Studio Code**
    1. Click the icon in the bottom-left corner.
    2. Select `Install Remote - SSH`.
    3. Select `Connect to Host...`.
    4. Select `Add New SSH Host...`.
    5. Enter `ssh root@<ip-address> -p <port>`.
    6. Select `Connect to Host...` again.
    7. Select your server from the list.
    8. Select `Linux` -> `Yes`.
    9. Enter your password.

- **Terminal**
    1. Enter `ssh root@<ip-address> -p <port>`.
    2. Type `yes` when prompted to continue connecting.
    3. Enter your password.

## Initialization
Run the `~/get-builder.sh` command in your terminal.

## Programming Language Managers
We use the following packages to manage programming languages:
- Node.js -> [nvm](https://github.com/nvm-sh/nvm)
- Python -> [pyenv](https://github.com/pyenv/pyenv)

## About tmux
Learn more at the [tmux official wiki](https://github.com/tmux/tmux/wiki).

## Auto-Startup Scripts
Auto-startup is a new feature in v3. Any shell scripts placed in the `/root/startup` folder will automatically execute in the background (via tmux) whenever your container reboots.

## About Cloudflared
We have updated the command. You can now use `cfd <your-token>` to run your Cloudflared tunnel.

## About the Workspace
We suggest making this folder your default working directory.

## Restart your container
```shell
kill 1
```