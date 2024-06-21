#!/bin/bash

# Обновление системы
sudo apt update
sudo apt upgrade -y

# Установка необходимых пакетов
sudo apt install -y git python3 python3-pip nginx

# Клонирование репозитория с бекендом
git clone https://github.com/metnerium/yrdietapp.git
cd yrdietapp

# Создание виртуального окружения и установка зависимостей
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Настройка Nginx
sudo tee /etc/nginx/sites-available/fastapi <<EOL
server {
    listen 80;
    server_name your_domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Создание сервиса для автозапуска FastAPI
sudo tee /etc/systemd/system/fastapi.service <<EOL
[Unit]
Description=FastAPI application
After=network.target

[Service]
User=user
WorkingDirectory=/home/user/yrdietapp
ExecStart=/home/user/yrdietapp/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl start fastapi

echo "Deployment completed successfully!"
