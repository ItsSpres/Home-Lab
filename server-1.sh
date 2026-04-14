#!/bin/bash
# 🎬 Server 1: Media Controller
set -e

case "$1" in
    setup)
        mkdir -p ~/jellyfin-data/{config,cache,media}
        echo "✅ Media folders created."
        ;;
    start)
        echo "⚡ Starting Tailscale & Jellyfin..."
        sudo tailscale up --accept-dns
        docker compose up -d
        ;;
    status)
        echo "📊 --- SERVER 1 STATUS ---"
        docker ps --format "table {{.Names}}\t{{.Status}}"
        tailscale status | head -n 1
        ;;
    *)
        echo "Usage: ./media.sh {setup|start|status}"
        exit 1
esac
