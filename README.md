# TOR Docker Container

This setup provides a TOR (The Onion Router) proxy container that can be used with Firefox or other applications.

## Features

- TOR SOCKS proxy on port 9050
- Bridge network for connecting other containers (like Firefox)
- Persistent TOR data directory
- Health checks

## Usage

### Starting TOR

```bash
docker-compose up -d
```

### Connecting Firefox Container

Since both Firefox and TOR are using `network_mode: bridge` (default bridge network), Firefox can connect to TOR via the Docker bridge gateway IP.

### Firefox Proxy Configuration

**Important**: On the default bridge network, containers cannot resolve each other by name. You must use the TOR container's IP address.

#### Get TOR Container IP Address

**Windows PowerShell:**
```powershell
docker inspect tor-proxy --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

**Linux/Mac:**
```bash
docker inspect tor-proxy --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Or use the helper script:
- Linux/Mac: `./get-tor-ip.sh`

#### Configure Firefox

**Important**: Make sure Firefox is configured for SOCKS5, not HTTP proxy.

In Firefox:
1. Go to **Settings** → **General** → **Network Settings** → **Settings**
2. Select **Manual proxy configuration**
3. **SOCKS Host**: Use the IP address from the command above (e.g., `172.17.0.3`)
4. **Port**: `9050`
5. **SOCKS v5** (NOT SOCKS v4)
6. **Check "Proxy DNS when using SOCKS v5"** (this is important!)
7. **Leave HTTP, SSL, and FTP proxy fields EMPTY** (only use SOCKS)
8. Click **OK**

**Alternative**: If SOCKS5 doesn't work, you can try HTTP proxy:
- **HTTP Proxy**: Use the TOR container IP
- **Port**: `9080`
- **No proxy for**: Leave empty or add `localhost, 127.0.0.1`

**Note**: Since both containers are on the default bridge network, they can only communicate by IP address, not by container name. The IP address may change when the container is recreated, so you may need to update Firefox settings if you restart the TOR container.

### Testing TOR Connection

Test if TOR is working:

```bash
# Check TOR container logs (look for "Bootstrapped 100%")
docker-compose logs tor

# Check if TOR is listening on port 9050
docker exec tor-proxy netstat -tlnp | grep 9050

# Test SOCKS proxy from host
curl --socks5-hostname localhost:9050 https://check.torproject.org/api/ip

# Test from inside Firefox container (replace 172.17.0.3 with TOR container IP)
# First, get into Firefox container, then:
curl --socks5-hostname 172.17.0.3:9050 https://check.torproject.org/api/ip
```

### Troubleshooting "Proxy server is refusing connections"

If Firefox shows "The proxy server is refusing connections":

1. **Check TOR is running and bootstrapped:**
   ```bash
   docker-compose logs tor | grep -i bootstrap
   ```
   Look for "Bootstrapped 100%" - TOR must be fully connected before it accepts connections.

2. **Verify TOR is listening:**
   ```bash
   docker exec tor-proxy netstat -tlnp | grep 9050
   ```
   Should show `0.0.0.0:9050` listening.

3. **Test connectivity from Firefox container:**
   ```bash
   # Get Firefox container name/IP, then from inside Firefox container:
   curl -v --socks5-hostname 172.17.0.3:9050 https://www.google.com
   ```

4. **Check TOR container IP hasn't changed:**
   ```bash
   docker inspect tor-proxy --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
   ```
   Update Firefox if IP changed.

5. **Verify Firefox proxy settings:**
   - SOCKS Host: TOR container IP (not hostname)
   - Port: 9050
   - SOCKS v5 (not v4)
   - "Proxy DNS when using SOCKS v5" checked
   - HTTP/SSL/FTP proxy fields are EMPTY

### Stopping TOR

```bash
docker-compose down
```

## Network Configuration

Both TOR and Firefox containers use `network_mode: bridge` (default bridge network). Firefox connects to TOR via the Docker bridge gateway IP (`172.17.0.1`) which routes to the exposed ports, or directly via the TOR container's IP address.

## Ports

- **9050**: SOCKS proxy port (for Firefox and other applications)
- **9080**: HTTP tunnel port (alternative HTTP proxy method)
- **9051**: Control port (for monitoring, optional)

## Volumes

- `tor-data`: Persistent storage for TOR's data directory
