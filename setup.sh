#!/bin/bash
DATABASE_URL="$1"

echo "--- Startar Pro Installation ---"

# 1. Installera paket
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv nginx git

# 2. Gå till mappen (Där GitHub redan lagt koden)
cd /home/azureuser/Webinar

# 3. Setup Python & Flask (NU hamnar venv inuti /home/azureuser/Webinar/venv)
python3 -m venv venv
./venv/bin/pip install flask gunicorn flask-sqlalchemy psycopg2-binary

# 4. Skapa tjänstfilen (Pekar nu rätt!)
sudo bash -c "cat <<SERVICE > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target
[Service]
User=azureuser
WorkingDirectory=/home/azureuser/Webinar
Environment=\"PATH=/home/azureuser/Webinar/venv/bin\"
Environment=\"DATABASE_URL=$DATABASE_URL\"
ExecStart=/home/azureuser/Webinar/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
Restart=always
[Install]
WantedBy=multi-user.target
SERVICE"

# 5. Starta Flask
sudo systemctl daemon-reload
sudo systemctl enable flaskapp
sudo systemctl start flaskapp

echo "--- Installation Klar! ---"
