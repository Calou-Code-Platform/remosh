# Remosh
A lightweight and simple SSH environment for Docker.

## What's New in v3.0?
We make default user to root, and fixed `chcfd` command to `cfd`.

## Environment Variables
| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `password` | The sudo password for the root. | `password` |
| `cloudflared` | (Optional) Your Cloudflared Tunnel token. | *None* |

## Exposed Ports
* **`22`** : Used for standard SSH connections.

## Quick Start
Run the following command to start your Remosh container in the background:

```bash
docker run -d \
  --name=ccp \
  --restart always \
  -e password=your_password \
  -p 2222:22 \
  ghcr.io/calou-code-platform/remosh:latest
```

## Container Commands
`cfd <token>`: If you want change cloudflared token, just use `cfd <token>`