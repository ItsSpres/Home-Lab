#!/bin/bash

# =============================================================================

# server-2.sh — Command Center Controller

# Server 2: Minecraft + Prometheus + Grafana + Node Exporter

# Usage: ./server-2.sh {setup|start|stop|restart|status|logs} [service]

# =============================================================================

set -euo pipefail

# — Configuration —

COMPOSE_FILE=”$(dirname “$0”)/server-2-compose.yml”
LAB_DIR=”$HOME/home-lab”
PROMETHEUS_CONFIG=”$LAB_DIR/prometheus/prometheus.yml”

# — Colors —

RED=’\033[0;31m’
GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
CYAN=’\033[0;36m’
BOLD=’\033[1m’
RESET=’\033[0m’

# — Helpers —

info()    { echo -e “${CYAN}[INFO]${RESET}  $1”; }
success() { echo -e “${GREEN}[OK]${RESET}    $1”; }
warn()    { echo -e “${YELLOW}[WARN]${RESET}  $1”; }
error()   { echo -e “${RED}[ERROR]${RESET} $1”; exit 1; }
header()  { echo -e “\n${BOLD}$1${RESET}”; echo “$(printf ‘─%.0s’ {1..50})”; }

# — Preflight check —

check_deps() {
command -v docker >/dev/null 2>&1 || error “Docker is not installed. Run: curl -fsSL https://get.docker.com | sh”
}

# =============================================================================

# COMMANDS

# =============================================================================

cmd_setup() {
header “🏗️  Server 2 — Initial Setup”

info “Creating required directories…”
mkdir -p “$LAB_DIR”/{mcdata,grafana-data,prometheus}
success “Directories created at $LAB_DIR”

if [ ! -f “$PROMETHEUS_CONFIG” ]; then
info “Generating default prometheus.yml…”
cat <<EOF > “$PROMETHEUS_CONFIG”

# =============================================================================

# Prometheus Configuration

# Scrapes Node Exporter metrics from both Server 1 and Server 2.

# Replace SERVER_1_IP_HERE with Server 1’s static IP (e.g., 192.168.30.10).

# =============================================================================

global:
scrape_interval: 15s
evaluation_interval: 15s

scrape_configs:

- job_name: ‘server-2-lab’
  static_configs:
  - targets: [‘localhost:9100’]
- job_name: ‘server-1-media’
  static_configs:
  - targets: [‘SERVER_1_IP_HERE:9100’]   # <– REPLACE THIS
    EOF
    success “Created $PROMETHEUS_CONFIG”
    echo “”
    warn “ACTION REQUIRED: Update prometheus.yml with Server 1’s static IP:”
    echo “  nano $PROMETHEUS_CONFIG”
    echo “  Replace ‘SERVER_1_IP_HERE’ with Server 1’s IP (e.g. 192.168.30.10)”
    else
    warn “prometheus.yml already exists — skipping generation. Verify it manually.”
    fi

echo “”
success “Setup complete. Update prometheus.yml then run ‘./server-2.sh start’.”
}

cmd_start() {
local service=”${2:-}”
header “⚡ Server 2 — Starting Services”

if [ -n “$service” ]; then
info “Starting individual service: $service”
docker compose -f “$COMPOSE_FILE” up -d “$service”
success “$service is running.”
else
info “Starting all Server 2 containers…”
docker compose -f “$COMPOSE_FILE” up -d
success “All Server 2 services are running.”
fi

echo “”
cmd_status
}

cmd_stop() {
local service=”${2:-}”
header “🛑 Server 2 — Stopping Services”

if [ -n “$service” ]; then
info “Stopping: $service”
docker compose -f “$COMPOSE_FILE” stop “$service”
success “$service stopped.”
else
info “Stopping all containers…”
docker compose -f “$COMPOSE_FILE” stop
success “All Server 2 services stopped.”
fi
}

cmd_restart() {
local service=”${2:-}”
header “🔄 Server 2 — Restarting Services”

if [ -n “$service” ]; then
info “Restarting: $service”
docker compose -f “$COMPOSE_FILE” restart “$service”
success “$service restarted.”
else
cmd_stop
sleep 2
cmd_start
fi
}

cmd_status() {
header “📊 Server 2 — Status”

echo -e “${BOLD}Containers:${RESET}”
docker ps   
–filter “name=minecraft-bedrock”   
–filter “name=prometheus”   
–filter “name=grafana”   
–filter “name=node-exporter-s2”   
–format “  {{.Names}}\t{{.Status}}\t{{.Ports}}” | column -t

local ip
ip=$(hostname -I | awk ‘{print $1}’)

echo “”
echo -e “${BOLD}Service URLs (local network):${RESET}”
echo “  Grafana:       http://$ip:3000”
echo “  Prometheus:    http://$ip:9090”
echo “  Node Exporter: http://$ip:9100/metrics”
echo “  Minecraft:     $ip:19132 (UDP)”

echo “”
echo -e “${BOLD}Prometheus Config:${RESET}”
if grep -q “SERVER_1_IP_HERE” “$PROMETHEUS_CONFIG” 2>/dev/null; then
warn “prometheus.yml still contains placeholder ‘SERVER_1_IP_HERE’ — update before monitoring Server 1.”
else
success “prometheus.yml looks configured.”
fi
}

cmd_logs() {
local service=”${2:-}”
header “📋 Server 2 — Logs”

if [ -n “$service” ]; then
info “Showing logs for: $service (Ctrl+C to exit)”
docker compose -f “$COMPOSE_FILE” logs -f “$service”
else
info “Showing logs for all services (Ctrl+C to exit)…”
docker compose -f “$COMPOSE_FILE” logs -f
fi
}

# =============================================================================

# ENTRYPOINT

# =============================================================================

check_deps

case “${1:-}” in
setup)   cmd_setup ;;
start)   cmd_start “$@” ;;
stop)    cmd_stop “$@” ;;
restart) cmd_restart “$@” ;;
status)  cmd_status ;;
logs)    cmd_logs “$@” ;;
*)
echo “”
echo -e “${BOLD}server-2.sh — Command Center Controller${RESET}”
echo “Usage: ./server-2.sh {command} [service]”
echo “”
echo “Commands:”
echo “  setup              Create directories and generate prometheus.yml”
echo “  start [service]    Start all containers, or a specific service”
echo “  stop [service]     Stop all containers, or a specific service”
echo “  restart [service]  Restart all containers, or a specific service”
echo “  status             Show container state and service URLs”
echo “  logs [service]     Stream logs for all services or a specific one”
echo “”
echo “Examples:”
echo “  ./server-2.sh start                 # Start everything”
echo “  ./server-2.sh start minecraft        # Start only Minecraft”
echo “  ./server-2.sh stop grafana           # Stop only Grafana”
echo “  ./server-2.sh logs prometheus        # Tail Prometheus logs”
echo “”
exit 1
;;
esac
