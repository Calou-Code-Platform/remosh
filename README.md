# Remosh
A lightweight and simple SSH environment for Docker.

## What's New in v2.0? (Breaking Changes)
We have completely migrated the base image from Ubuntu 24.04 LTS to **Debian 13 Slim**. This architectural change drastically reduces the overall image size and memory footprint, providing a much cleaner and faster development experience.

## Environment Variables

| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `username` | The username for SSH login. | `linux` |
| `password` | The password for the user. | `password` |
| `sudo_password`| The password required for `sudo` privileges. | `sudo_password` |
| `cloudflared` | (Optional) Your Cloudflare Tunnel token. | *None* |

## Exposed Ports
* **`22`** : Used for standard SSH connections.

## Quick Start
Run the following command to start your Remosh container in the background:

```bash
docker run -d \
  --name=ccp \
  --restart always \
  -e username=your_username \
  -e password=your_password \
  -p 2222:22 \
  ghcr.io/calou-code-platform/remosh:latest
```

## Container Commands
`chcfd <token>`: If you want change cloudflared token, just use `chcfd <token>`
