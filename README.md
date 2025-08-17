# Home Automation & Media Server Setup

This project contains Docker Compose configurations for a complete home automation and media server setup including:

- **Home Assistant** - Home automation platform
- **Matter Server** - Matter protocol support for Home Assistant
- **Media Server Stack** - Complete media management solution
  - qBittorrent - Torrent client
  - Sonarr - TV series management
  - Radarr - Movie management
  - Prowlarr - Indexer management
  - Emby - Media streaming server
- **Portainer** - Docker container management UI

## Prerequisites

- Docker and Docker Compose installed
- Linux-based system (tested on Ubuntu/Debian)
- Root or sudo access for folder creation
- External storage device (optional, for media storage)

## Initial Setup

### 1. Create Required Directories

Before starting the containers, create all necessary directories with proper permissions:

```bash
# Create main service directories
sudo mkdir -p /srv/{homeassistant,qbittorrent,sonarr,radarr,prowlarr,emby,downloads,portainer_data}

# Create matter-server storage directory in project folder
mkdir -p ./matter-storage

# Set proper ownership (replace 1000:1000 with your user:group if different)
sudo chown -R 1000:1000 /srv/
sudo chown -R 1000:1000 ./matter-storage

# Set proper permissions
sudo chmod -R 755 /srv/
sudo chmod -R 755 ./matter-storage
```

### 2. Setup External Media Storage (Optional)

If you want to mount an external drive for media storage:

#### Option A: Mount to /mnt/media (Recommended)
```bash
# Create mount point
sudo mkdir -p /mnt/media

# Find your external drive
lsblk

# Mount the drive (replace /dev/sdX1 with your actual device)
sudo mount /dev/sdX1 /mnt/media

# Set proper ownership
sudo chown -R 1000:1000 /mnt/media

# For permanent mounting, add to /etc/fstab
echo "/dev/sdX1 /mnt/media ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

#### Option B: Mount to custom location and bind mount
```bash
# If your external drive is mounted elsewhere (e.g., /media/username/drive)
# Create a bind mount to /mnt/media
sudo mkdir -p /mnt/media
sudo mount --bind /media/username/your-drive /mnt/media

# For permanent bind mount, add to /etc/fstab
echo "/media/username/your-drive /mnt/media none bind 0 0" | sudo tee -a /etc/fstab
```

### 3. Configure qBittorrent (Optional)

If you have an existing qBittorrent configuration:

```bash
# Copy your existing qBittorrent.conf to the expected location
sudo cp /path/to/your/qBittorrent.conf /srv/qbittorrent/config.conf
```

If you don't have a configuration file, the container will create a default one on first run.

## Starting the Services

### Method 1: Using the provided script (Recommended)
```bash
# Make the script executable
chmod +x compose.sh

# Run all services
./compose.sh
```

### Method 2: Manual startup
```bash
# Start Home Assistant stack
docker compose -p homeassistant -f ha.yml up -d

# Start Media Server stack
docker compose -p media-server -f mediaserver.yml up -d

# Start Portainer
docker compose -p manager -f portainer.yaml up -d
```

## Service Access

Once all containers are running, you can access the services at:

| Service | URL | Default Port |
|---------|-----|--------------|
| Home Assistant | http://your-ip:8123 | 8123 |
| qBittorrent | http://your-ip:8086 | 8086 |
| Sonarr | http://your-ip:8989 | 8989 |
| Radarr | http://your-ip:7878 | 7878 |
| Prowlarr | http://your-ip:9696 | 9696 |
| Emby | http://your-ip:8096 | 8096 |
| Portainer | http://your-ip:9000 | 9000 |

## Initial Configuration

### Home Assistant
1. Navigate to http://your-ip:8123
2. Follow the initial setup wizard
3. Create your admin account
4. Configure your location and units

### Media Server Stack
1. **qBittorrent**: Default login is `admin/adminadmin` - change immediately
2. **Prowlarr**: Configure indexers first
3. **Sonarr/Radarr**: 
   - Add Prowlarr as indexer source
   - Configure qBittorrent as download client
   - Set up media folders (/media for movies/TV shows)
4. **Emby**: Follow setup wizard and point to media folders

### Portainer
1. Navigate to http://your-ip:9000
2. Create admin password
3. Select "Docker" environment
4. Connect to local Docker socket

## Directory Structure

```
/srv/
├── homeassistant/          # Home Assistant config
├── qbittorrent/           # qBittorrent config
├── sonarr/                # Sonarr config
├── radarr/                # Radarr config
├── prowlarr/              # Prowlarr config
├── emby/                  # Emby config
├── downloads/             # Download directory
└── portainer_data/        # Portainer data

/mnt/
└── media/                 # Media storage (movies, TV shows)

./matter-storage/          # Matter server data (in project directory)
```

## Management Commands

### View running containers
```bash
docker ps
```

### View logs
```bash
# Home Assistant logs
docker compose -p homeassistant -f ha.yml logs -f

# Media server logs
docker compose -p media-server -f mediaserver.yml logs -f

# Portainer logs
docker compose -p manager -f portainer.yaml logs -f
```

### Stop services
```bash
# Stop all services
docker compose -p homeassistant -f ha.yml down
docker compose -p media-server -f mediaserver.yml down
docker compose -p manager -f portainer.yaml down
```

### Update containers
```bash
# Pull latest images
docker compose -p homeassistant -f ha.yml pull
docker compose -p media-server -f mediaserver.yml pull
docker compose -p manager -f portainer.yaml pull

# Restart with new images
./compose.sh
```

## Troubleshooting

### Permission Issues
```bash
# Fix ownership of all service directories
sudo chown -R 1000:1000 /srv/
sudo chown -R 1000:1000 ./matter-storage
```

### Network Issues
- All services use host networking for better performance and discovery
- Ensure no port conflicts with existing services
- Check firewall settings if services are not accessible

### Storage Issues
- Verify external drive is properly mounted: `df -h`
- Check available space: `du -sh /mnt/media`
- Ensure proper permissions on media directories

### Container Issues
- Check container status: `docker ps -a`
- View container logs: `docker logs <container_name>`
- Restart specific container: `docker restart <container_name>`

## Security Notes

- Change default passwords immediately after first login
- Consider using a reverse proxy with SSL certificates for external access
- Regularly update container images for security patches
- Backup configuration directories regularly

## Backup Strategy

Important directories to backup:
- `/srv/homeassistant/` - Home Assistant configuration
- `/srv/*/` - All service configurations
- `./matter-storage/` - Matter server data

```bash
# Example backup command
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /srv/ ./matter-storage/

