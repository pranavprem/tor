FROM alpine:latest

# Install TOR and required packages (su-exec for user switching)
RUN apk add --no-cache tor netcat-openbsd su-exec

# Create TOR data directory with proper permissions
RUN mkdir -p /var/lib/tor && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor

# Copy TOR configuration
COPY torrc /etc/tor/torrc

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Fix permissions on config file
RUN chown tor:tor /etc/tor/torrc && \
    chmod 644 /etc/tor/torrc

# Expose TOR SOCKS proxy port (default 9050)
EXPOSE 9050

# Expose TOR control port (optional, for monitoring)
EXPOSE 9051

# Set entrypoint (runs as root to fix permissions, then switches to tor user)
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Run TOR (entrypoint will switch to tor user)
CMD ["tor", "-f", "/etc/tor/torrc"]
