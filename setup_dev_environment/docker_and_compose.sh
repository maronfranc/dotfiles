# Install Docker and docker-compose
curl -fsSL https://get.docker.com | sudo sh

# Add permission
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Reboot needed"

# If `docker-compose up` container pull is not working downgrade to `pip3 install requests==2.31.0`
# SEE: https://stackoverflow.com/questions/64952238/docker-errors-dockerexception-error-while-fetching-server-api-version
