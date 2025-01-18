
# Home-Lab

This repository contains scripts to set up and manage a home lab environment using Docker, Docker Swarm, and Tailscale. The provided scripts automate the setup, startup, and shutdown processes for your containers and services.

## Files

1. **`setup_docker_swarm_containers_and_firewall.sh`**  
   Sets up Docker Swarm, initializes containers (Minecraft Bedrock, Portainer, Jellyfin), configures file permissions, and applies firewall rules.

2. **`shutdown.sh`**  
   Stops all running Docker containers and gracefully shuts down the system.

3. **`startup_with_tailscale.sh`**  
   Ensures Tailscale, Docker services, and all containers are running after a reboot.

---

## How to Use

### Clone the Repository
Clone this repository to your home directory:
```bash
git clone https://github.com/ItsSpres/Home-Lab.git ~/home-lab
```

### Setup Script
Run the setup script to initialize your Docker environment:
```bash
cd ~/home-lab
chmod +x setup_docker_swarm_containers_and_firewall
./setup_docker_swarm_containers_and_firewall
```

### Startup Script
Use this script to start Tailscale, Docker services, and containers after a system reboot:
```bash
chmod +x startup_with_tailscale
./startup_with_tailscale
```

### Shutdown Script
Use this script to stop all containers and power down the system:
```bash
chmod +x shutdown
./shutdown
```

---

## Automating Scripts

### Startup on Boot
To ensure the startup script runs automatically on boot, create a systemd service:

1. Create a service file:
   ```bash
   sudo nano /etc/systemd/system/startup_with_tailscale.service
   ```

2. Add the following content:
   ```ini
   [Unit]
   Description=Run Startup Script with Tailscale
   After=network.target docker.service tailscaled.service

   [Service]
   Type=oneshot
   ExecStart=/bin/bash /home/$USER/home-lab/startup_with_tail-scale
   User=$USER
   Group=$USER

   [Install]
   WantedBy=multi-user.target
   ```

3. Reload systemd and enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable startup_with_tailscale.service
   ```

---

## Dependencies

- **Docker**: Install using:
  ```bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  ```

- **Tailscale**: Install using:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  ```

---

## Contributing

Feel free to open issues or submit pull requests for improvements and additional features.
