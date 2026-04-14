# 🚀 Enterprise-Grade Hybrid Homelab & Business Ops
### Zero Trust Networking | Multi-VLAN | Media, Gaming & 3D Printing Automation

This repository contains the **Infrastructure-as-Code (IaC)** and automation logic for a multi-layered home network. It is designed to provide a secure environment for **Etsy/eBay business operations** while hosting high-performance media and gaming services with **Zero Trust** security.

---

## 📐 1. Network Topology (UniFi Ecosystem)
The network is powered by a **UniFi Cloud Gateway Ultra (UCG Ultra)** and segmented into four distinct VLANs to enforce lateral movement protection.

| VLAN | Subnet | Name | Security Policy |
| :--- | :--- | :--- | :--- |
| **0** | `192.168.0.x` | **Main** | **The Admin Zone.** Full access to all other VLANs; hosts Etsy/eBay workstations. |
| **30** | `192.168.30.x` | **Lab** | **The Engine Room.** Isolated from Main. Hosts the Docker stack and Minecraft. |
| **10** | `192.168.10.x` | **IoT** | **Isolated Zone.** 3D Printers and smart devices. No access to other VLANs. |
| **20** | `192.168.20.x` | **Guest** | **Sandbox Zone.** Visitors get internet only; client isolation enabled. |

### 🔐 Remote Access Strategy
- **WireGuard (Router-Level):** Primary **Admin VPN** hosted on the UCG Ultra. Allows total management of the lab and 3D printers from anywhere.
- **Tailscale (Application-Level):** Deployed on **Server 1 (Media)**. Creates a Zero Trust tunnel where external users land directly inside the Jellyfin environment, bypassing the physical network hardware.

---

## 🐳 2. The Infrastructure Stack (`docker-compose.yml`)
All services are managed via Docker Compose for consistency and easy updates.

```yaml
services:
  # Media Server (Jellyfin)
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    volumes:
      - ~/home-lab/jellyfin-config:/config
      - ~/home-lab/jellyfin-cache:/cache
      - ~/home-lab/jellyfin-media:/media

  # Minecraft Bedrock Server
  minecraft:
    image: itzg/minecraft-bedrock-server
    container_name: minecraft-bedrock
    restart: unless-stopped
    ports:
      - "19132:19132/udp"
    environment:
      - EULA=TRUE
    volumes:
      - ~/home-lab/mcdata:/data

  # Management (Portainer)
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/home-lab/portainer-data:/data

  # Monitoring (Grafana)
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ~/home-lab/grafana-data:/var/lib/grafana

```
## 🛠 3. Master Automation Script (lab.sh)
This script replaces all individual startup/shutdown/setup files.
```bash
#!/bin/bash
# 🚀 Master Lab Controller - ItsSpres Homelab
set -e

LAB_DIR="$HOME/home-lab"
COMPOSE_FILE="$HOME/homelab/docker-compose.yml"

case "$1" in
    setup)
        echo "🏗️  Initializing local directories..."
        mkdir -p $LAB_DIR/mcdata $LAB_DIR/jellyfin-config $LAB_DIR/jellyfin-cache $LAB_DIR/jellyfin-media $LAB_DIR/portainer-data $LAB_DIR/grafana-data
        sudo chown -R $USER:$USER $LAB_DIR
        echo "✅ Setup Complete."
        ;;
    start)
        echo "⚡ Powering up Lab Services..."
        sudo systemctl start tailscaled
        sudo tailscale up --accept-dns || echo "Tailscale already active."
        sudo ufw allow 19132/udp # Minecraft
        sudo ufw allow 8096/tcp  # Jellyfin
        sudo ufw allow 9000/tcp  # Portainer
        sudo ufw allow 3000/tcp  # Grafana
        sudo ufw reload
        docker compose -f $COMPOSE_FILE up -d
        echo "🚀 LAB IS ONLINE."
        ;;
    stop)
        echo "🛑 Shutting down Lab Services..."
        docker compose -f $COMPOSE_FILE stop
        sudo systemctl stop docker
        echo "🔒 LAB IS OFFLINE."
        ;;
    shutdown)
        echo "⚠️  CRITICAL: SYSTEM SHUTDOWN INITIATED..."
        docker compose -f $COMPOSE_FILE stop
        sudo shutdown now
        ;;
    *)
        echo "Usage: ./lab.sh {setup|start|stop|shutdown}"
        exit 1
esac

```
## 🚀 4. Deployment Instructions
 1. **Initialize:** chmod +x lab.sh && ./lab.sh setup
 2. **Launch Stack:** ./lab.sh start
 3. **Emergency Stop:** ./lab.sh stop
## 💼 5. Career Portfolio Context (Disney Technical Support)
This project demonstrates technical proficiency in:
 * **Enterprise Networking:** Multi-VLAN architecture and firewall management.
 * **Linux Administration:** Bash automation, UFW configuration, and system service management.
 * **Virtualization:** Deploying production services via Docker and Infrastructure-as-Code.
 * **Security:** Implementing Zero Trust networking via Tailscale.
