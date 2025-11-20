FROM odoo:18.0

USER root

# Install system dependencies if needed (example for common OCA modules)
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy OCA modules and install their Python dependencies
COPY ./oca /mnt/oca-addons
RUN find /mnt/oca-addons -name 'requirements.txt' | while read req; do \
        echo "Installing from $req"; \
        pip3 install --break-system-packages --no-cache-dir -r "$req" || exit 1; \
    done

USER odoo