#!/bin/bash

# Ta emot databas-länken som ett argument när scriptet körs
DATABASE_URL="$1"

echo "--- Startar installationen från GitHub-script ---"

# 1. Installera paket
apt-get update
apt-get install -y python3-pip python3-venv nginx

# 2. Skapa mappar (Vi står redan i roten av repot när detta körs)
mkdir -p templates static

# 3. Flytta filer till rätt mappar
mv index.html templates/
mv *.css static/
mv *.js static/ 2>/dev/null || true
mv *.png static/ 2>/dev/null || true
mv *.jpg static/ 2>/dev/null || true

# 4. Fixa länkarna i HTML (sed)
sed -i 's|href="style.css"|href="/static/style.css"|g' templates/index.html
sed -i 's|src="script.js"|src="/static/script.js"|g' templates/index.html
sed -i 's|src="background-choklad.png"|src="/static/background-choklad.png"|g' templates/index.html
sed -i 's|action="#"|action="/"|g' templates/index.html

# 5. Skapa virtuell miljö och installera Flask
python3 -m venv venv
venv/bin/pip install flask gunicorn flask-sqlalchemy psycopg2-binary

# 6. Skapa Systemd Service-filen
# Notera att vi använder variabeln $DATABASE_URL här
cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target
[Service]
User=azureuser
WorkingDirectory=/home/azureuser/Webinar
Environment="PATH=/home/azureuser/venv/bin"
Environment="DATABASE_URL=$DATABASE_URL"
ExecStart=/home/azureuser/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# 7. Starta Flask-tjänsten
systemctl daemon-reload
systemctl enable flaskapp
systemctl start flaskapp

echo "--- Installation klar! ---"
