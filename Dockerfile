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