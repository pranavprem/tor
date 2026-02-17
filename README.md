# Tor + Firefox (Private Browsing via Tor)

A self-hosted Tor SOCKS proxy with a browser-in-browser Firefox instance, all routed through the Tor network.

## Quick Start

```bash
docker compose up -d
```

Access Firefox at **`https://NAS_IP:3001`** (accept the self-signed cert warning).

## Configure Firefox to Use Tor

The proxy must be configured **inside the remote Firefox browser**, not via env vars:

1. In the remote Firefox, go to `about:preferences`
2. Search for **"proxy"**
3. Select **Manual proxy configuration**
4. Set **SOCKS Host:** `tor` | **Port:** `9050`
5. Select **SOCKS v5**
6. ✅ Check **"Proxy DNS when using SOCKS v5"**
7. Leave HTTP/SSL/FTP proxy fields **empty**
8. Click **OK**

### Verify Tor is Working

Navigate to `https://check.torproject.org` — you should see "Congratulations. This browser is configured to use Tor."

## Architecture

Both containers share the `tornet` Docker network, so Firefox can reach the Tor proxy by container name (`tor`).

```
Firefox (KasmVNC) → tor:9050 (SOCKS5) → Tor Network → Internet
```

## Ports

| Port | Service | Purpose |
|------|---------|---------|
| 3001 | Firefox | HTTPS Web UI (KasmVNC) |
| 9050 | Tor | SOCKS5 proxy (for other apps on the LAN) |
| 9051 | Tor | Control port (optional, for monitoring) |

## Testing Tor from CLI

```bash
# Check Tor is bootstrapped
docker compose logs tor | grep -i "bootstrapped 100%"

# Test SOCKS proxy from host
curl --socks5-hostname localhost:9050 https://check.torproject.org/api/ip
```

## Troubleshooting

**"Proxy server is refusing connections"**
- Check Tor is fully bootstrapped: `docker compose logs tor | grep bootstrap`
- Verify Tor is listening: `docker exec tor-proxy netstat -tlnp | grep 9050`
- Make sure Firefox proxy is set to SOCKS v5 (not v4) with DNS proxying enabled

**Firefox Web UI requires HTTPS**
- Use `https://NAS_IP:3001` (not port 3000)

## Volumes

- `tor-data` — Persistent Tor data directory
- `tor-firefox-config` — Firefox profile and settings
