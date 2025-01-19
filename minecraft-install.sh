#!/bin/bash

# Script to install and start a Minecraft Bedrock server using Docker with firewall configuration

# Step 1: Pull the Latest Docker Image
echo "Pulling the latest Minecraft Bedrock Docker image..."
docker pull itzg/minecraft-bedrock-server

# Step 2: Create Directory for Server Files
echo "Creating directory for Minecraft server files..."
mkdir -p ~/minecraft-bedrock-server
chmod -R 755 ~/minecraft-bedrock-server

# Step 3: Configure Firewall to Allow Minecraft Bedrock Traffic
echo "Configuring firewall to allow Minecraft Bedrock traffic..."
sudo ufw allow 19132/udp
echo "Firewall updated to allow traffic on port 19132/udp."

# Step 4: Run the Docker Container
echo "Starting the Minecraft Bedrock server..."
docker run -d \
  --name=minecraft-bedrock-server \
  -p 19132:19132/udp \
  -v ~/minecraft-bedrock-server:/data \
  -e EULA=TRUE \
  itzg/minecraft-bedrock-server

# Step 5: Verify the Container is Running
echo "Verifying that the Minecraft Bedrock server is running..."
docker ps | grep minecraft-bedrock-server && echo "Minecraft Bedrock server is running!" || echo "Failed to start the server. Check the logs with 'docker logs minecraft-bedrock-server'."
