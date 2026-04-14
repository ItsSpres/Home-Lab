#!/bin/bash

# =============================================================================

# server-1.sh — Media Node Controller

# Server 1: Jellyfin + Node Exporter

# Usage: ./server-1.sh {setup|start|stop|restart|status|logs}

# =============================================================================

set -euo pipefail

# — Configuration —

COMPOSE_FILE=”$(dirname “$0”)/server-1-compose.yml”
JELLYFIN_DATA_DIR=”$HOME/jellyfin-data”

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
command -v tailscale >/dev/null 2>&1 || warn “Tailscale not found. Remote access will be unavailable.”
}

# =============================================================================

# COMMANDS

# =============================================================================

cmd_setup() {
header “🎬 Server 1 — Initial Setup”

info “Creating Jellyfin data directories…”
mkdir -p “$JELLYFIN_DATA_DIR”/{config,cache,media}
success “Directories created at $JELLYFIN_DATA_DIR”

echo “”
warn “ACTION REQUIRED: Open server-1-compose.yml and update the media volume path:”
echo “      - /your/media/path:/media”
echo “  Replace ‘/your/media/path’ with your actual mounted drive path.”
echo “  Example: /mnt/media:/media”
echo “”
success “Setup complete. Run ‘./server-1.sh start’ when ready.”
}

cmd_start() {
header “⚡ Server 1 — Starting Services”

info “Bringing up Tailscale…”
if command -v tailscale >/dev/null 2>&1; then
sudo tailscale up –accept-dns && success “Tailscale connected.” || warn “Tailscale already up or failed — check manually.”
else
warn “Tailscale not installed — skipping.”
fi

info “Starting containers…”
docker compose -f “$COMPOSE_FILE” up -d
success “All Server 1 services are running.”
echo “”
cmd_status
}

cmd_stop() {
header “🛑 Server 1 — Stopping Services”
info “Stopping containers…”
docker compose -f “$COMPOSE_FILE” stop
success “All Server 1 services stopped.”
}

cmd_restart() {
header “🔄 Server 1 — Restarting Services”
cmd_stop
sleep 2
cmd_start
}

cmd_status() {
header “📊 Server 1 — Status”

echo -e “${BOLD}Containers:${RESET}”
docker ps –filter “name=jellyfin” –filter “name=node-exporter-s1”   
–format “  {{.Names}}\t{{.Status}}\t{{.Ports}}” | column -t

echo “”
echo -e “${BOLD}Tailscale:${RESET}”
if command -v tailscale >/dev/null 2>&1; then
tailscale status 2>/dev/null | head -n 3 | sed ‘s/^/  /’
else
echo “  Tailscale not installed.”
fi

echo “”
echo -e “${BOLD}Service URLs (local network):${RESET}”
echo “  Jellyfin:      http://$(hostname -I | awk ‘{print $1}’):8096”
echo “  Node Exporter: http://$(hostname -I | awk ‘{print $1}’):9100/metrics”
}

cmd_logs() {
local service=”${2:-}”
header “📋 Server 1 — Logs”
if [ -n “$service” ]; then
info “Showing logs for: $service”
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
start)   cmd_start ;;
stop)    cmd_stop ;;
restart) cmd_restart ;;
status)  cmd_status ;;
logs)    cmd_logs “$@” ;;
*)
echo “”
echo -e “${BOLD}server-1.sh — Media Node Controller${RESET}”
echo “Usage: ./server-1.sh {command}”
echo “”
echo “Commands:”
echo “  setup    Create required directories and confirm configuration”
echo “  start    Start Tailscale and all containers”
echo “  stop     Stop all running containers”
echo “  restart  Stop then start all containers”
echo “  status   Show container state, Tailscale status, and service URLs”
echo “  logs     Stream logs for all services (./server-1.sh logs [service])”
echo “”
exit 1
;;
esac
