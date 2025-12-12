#!/bin/bash
echo "--- Startar Proxy Installation ---"

# 1. Installera Nginx
sudo apt-get update
sudo apt-get install -y nginx

# 2. Konfigurera (Hårdkodad för Azure Internal DNS)
sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    location / {
        proxy_pass http://WebServer.internal.cloudapp.net:5001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF'

# 3. Starta om
sudo systemctl restart nginx
echo "--- Proxy Klar! ---"
