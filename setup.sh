#!/bin/bash

# Exit script on any error
set -e

# Configure firewall rules
echo "Configuring firewall rules..."
sudo ufw allow 19132/udp   # Minecraft Bedrock server
sudo ufw allow 9000/tcp    # Portainer web interface
sudo ufw allow 8096/tcp    # Jellyfin web interface
sudo ufw reload            # Reload firewall to apply changes

# Ensure necessary directories exist and set correct permissions
echo "Setting up directories and permissions..."

# Minecraft data directory (used only within the container, bind to the host directory)
mkdir -p ~/home-lab/mcdata
sudo chown -R $USER:$USER ~/home-lab/mcdata
chmod -R 755 ~/home-lab/mcdata

# Jellyfin directories (used only within the container)
mkdir -p ~/home-lab/jellyfin-config ~/home-lab/jellyfin-cache ~/home-lab/jellyfin-media
sudo chown -R $USER:$USER  ~/home-lab/jellyfin-config ~/home-lab/jellyfin-cache ~/home-lab/jellyfin-media
chmod -R 755  ~/home-lab/jellyfin-config ~/home-lab/jellyfin-cache ~/home-lab/jellyfin-media

echo "Directories and permissions set."

# Create Minecraft Bedrock container with local storage (bind mount to host machine)
echo "Creating Minecraft Bedrock container..."
docker run -d \
  --name minecraft-bedrock-server \
  --restart unless-stopped \
  --network bridge \
  -p 19132:19132/udp \
  -v ~/home-lab/mcdata:/data \
  itzg/minecraft-bedrock-server

# Create Portainer container with local storage (no mount to host)
echo "Creating Portainer container..."
docker run -d \
  --name portainer \
  --restart unless-stopped \
  --network bridge \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce

# Create Jellyfin container with local storage (no mount to host)
echo "Creating Jellyfin container..."
docker run -d \
  --name jellyfin \
  --restart unless-stopped \
  --network bridge \
  -p 8096:8096 \
  -v ~/home-lab/jellyfin-config:/config \
  -v ~/home-lab/jellyfin-cache:/cache \
  -v ~/home-lab/jellyfin-media:/media \
  jellyfin/jellyfin

echo "All containers are set up and running, with Minecraft using local storage on the host!"
