#!/bin/bash
echo "--- Startar Proxy Installation (Med HTTPS) ---"

# 1. Installera Nginx
sudo apt-get update
sudo apt-get install -y nginx

# 2. Skapa ett självsignerat SSL-certifikat (Giltigt i 365 dagar)
# Vi använder -subj för att slippa svara på frågor interaktivt
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/C=SE/ST=Halland/L=Kungsbacka/O=DevOps/CN=AzureWebinar"

# 3. Konfigurera Nginx (Både Port 80 och 443)
sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    # Skicka alla som kommer via HTTP till HTTPS istället (Säkerhet!)
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    
    # Peka ut certifikaten vi skapade nyss
    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    location / {
        proxy_pass http://WebServer.internal.cloudapp.net:5001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF'

# 4. Starta om
sudo systemctl restart nginx
echo "--- Proxy Klar! ---"
