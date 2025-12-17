docker
gitbash
nodejs
python
pip3

🐳 Container Management
docker run -d --name mycontainer imagename → Run a container in detached mode

docker ps → List running containers

docker ps -a → List all containers (including stopped)

docker stop mycontainer → Stop a container

docker start mycontainer → Start a container

docker rm mycontainer → Remove a container

docker exec -it mycontainer bash → Open an interactive shell inside a container

📦 Image Management
docker images → List images

docker pull imagename:tag → Pull an image from registry

docker build -t myimage:tag . → Build an image from Dockerfile

docker rmi imagename → Remove an image

💾 Volume Management
docker volume ls → List volumes

docker volume inspect myvolume → Inspect a volume

docker volume rm myvolume → Remove a volume

🌐 Network Management
docker network ls → List networks

docker network inspect mynetwork → Inspect a network

🛠️ Utilities
docker logs -f odoo-docker-odoo-1

docker logs mycontainer → View container logs

docker cp mycontainer:/path/in/container /path/on/host → Copy from container to host

docker cp /path/on/host mycontainer:/path/in/container → Copy from host to container

docker system prune -a → Clean up unused containers, images, networks

🚀 Docker Compose
docker compose up -d → Start services in detached mode

docker compose down → Stop and remove services

docker compose build → Build/rebuild services

docker compose logs -f → Follow logs for all services

set wsl resource:
.wslconfig
[wsl2]
memory=6GB
processors=4

[ -d "oca/server-tools/.git" ] && echo "Exists" || echo "Does not exist"

[ -f "oca/server-tools/requirements.txt" ] && echo "Exists" || echo "Does not exist"

make data base?
docker compose run --rm web odoo -i base -d odoo_db --stop-after-init

docker restart odoo-docker-odoo-1

docker compose stop

docker compose start

docker compose build

docker compose build --progress=plain

docker compose build --no-cache --progress=plain

docker compose up -d

check addon path
docker exec -it odoo-docker-odoo-1 ls /mnt/oca-addons
docker exec -it odoo-docker-odoo-1 ls /mnt/oca-addons/account-financial-tools

go in docker container
docker compose exec odoo /bin/bash

check dependencies
pip3 show
pip3 list

FROM odoo:18.0

USER root

# Install system dependencies if needed (example for common OCA modules)
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# install dependencies from requirements.txt (master list)
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --break-system-packages --no-cache-dir -r /tmp/requirements.txt \
    || (echo "❌ Pip install failed for /tmp/requirements.txt" && exit 1)

USER odoo

FROM odoo:18.0

USER root

# Install system dependencies (apt packages)
RUN apt-get update && apt-get install -y python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Ensure venv is used by default
ENV PATH="/opt/venv/bin:$PATH"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Copy requirements and install with venv's pip
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    || (echo "❌ Pip install failed for /tmp/requirements.txt" && exit 1)

USER odoo

git clone -b 18.0 https://github.com/OCA/commission.git oca/commission

git clone -b 18.0 https://github.com/HeliconiaIO/stock-logistics-workflow/tree/refs/heads/18.0-mig-stock_account_show_automatic_valuation.git oca/stock-logistics-workflow-HeliconiaIO

git clone https://github.com/HeliconiaIO/stock-logistics-workflow/tree/refs/heads/18.0-mig-stock_account_show_automatic_valuation.git -b 18.0-mig-stock_account_show_automatic_valuation

git clone https://github.com/HeliconiaIO/stock-logistics-workflow.git -b 18.0-mig-stock_account_show_automatic_valuation

update modules list
docker compose exec odoo odoo -d <your-db-name> -u base --stop-after-init
docker compose exec odoo odoo -d odoo-db -u base --stop-after-init

install module
docker compose exec odoo odoo -d <your-db-name> -i <module-technical-name> --stop-after-init
docker compose exec odoo odoo -d odoo-db -i document_knowledge --stop-after-init

P2P, O2C, R2R, P2Pr
Q2C, H2R, A2R, F2D

configure multi company (multicompany, intercompany transactions?)
Branch No. 1 of Quang Phuong Co., Ltd.

COA configure
interim accounts
turn on reconciliation (bank suspense, etc.)
3387 account

configure accounting settings
configure journals
add outstanding accounts (odoo 18+)
configure payment method
configure payment mode

configure vat asset tax

enable inventory setting (varian, uom)

(need product code generator)
***configure product category
- make exclusive products for each company??
configure variant/ attribute

configure assets

make products
(config product sku?)

configure purchase setting
configure sale setting