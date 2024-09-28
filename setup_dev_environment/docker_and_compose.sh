# Install Docker and docker-compose 
sudo apt install -y docker docker.io docker-compose

# Add permission
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Reboot needed"
