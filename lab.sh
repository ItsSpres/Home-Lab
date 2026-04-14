#!/bin/bash
# 🚀 Server 2: Master Lab Controller
set -e

LAB_DIR="$HOME/home-lab"
COMPOSE_FILE="./docker-compose.yml"

case "$1" in
    setup)
        echo "🏗️  Initializing Server 2 Directories..."
        mkdir -p $LAB_DIR/{mcdata,portainer-data,grafana-data,prometheus}
        if [ ! -f $LAB_DIR/prometheus/prometheus.yml ]; then
          cat <<EOF > $LAB_DIR/prometheus/prometheus.yml
global: {scrape_interval: 15s}
scrape_configs:
  - job_name: 'server-2-lab'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'server-1-media'
    static_configs:
      - targets: ['SERVER_1_IP_HERE:9100']
EOF
        fi
        echo "✅ Setup Complete. Edit prometheus.yml with Server 1's IP."
        ;;
    start)
        if [ -z "$2" ]; then
            echo "⚡ Starting ALL Server 2 services..."
            docker compose up -d
        else
            echo "📦 Starting: $2..."
            docker compose up -d "$2"
        fi
        ;;
    status)
        echo "📊 --- SERVER 2 STATUS ---"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    stop)
        docker compose stop "$2"
        ;;
    *)
        echo "Usage: ./lab.sh {setup|start|stop|status}"
        exit 1
esac
