#!/bin/sh
set -e

# Fix permissions on TOR data directory if mounted as volume
# This needs to run as root before switching to tor user
if [ "$(id -u)" = "0" ]; then
    if [ -d /var/lib/tor ]; then
        chown -R tor:tor /var/lib/tor
        chmod 700 /var/lib/tor
    fi
    # Switch to tor user and execute command
    # Find su-exec (usually in /sbin or /usr/sbin in Alpine)
    if command -v su-exec >/dev/null 2>&1; then
        exec su-exec tor "$@"
    elif [ -x /sbin/su-exec ]; then
        exec /sbin/su-exec tor "$@"
    else
        echo "Error: su-exec not found" >&2
        exit 1
    fi
else
    # Already running as tor user, just execute
    exec "$@"
fi
