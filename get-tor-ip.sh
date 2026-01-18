#!/bin/bash
# Script to get TOR container IP address
IP=$(docker inspect tor-proxy --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "TOR Container IP Address: $IP"
echo ""
echo "Configure Firefox SOCKS proxy:"
echo "  Host: $IP"
echo "  Port: 9050"
echo "  SOCKS v5"
