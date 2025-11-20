#!/bin/bash
# OCA Module Installation Script (Optimal and Robust Version)

# --- Configuration (Adjust if necessary) ---
OCA_VERSION="18.0"
OCA_DIR="../oca"
# Use the Docker Compose SERVICE NAMES for reliability
DB_NAME="odoo_db"                  # Adjust to your actual Odoo DB name
ODOO_SERVICE_NAME="odoo"           # Service name from docker-compose.yml

# Define OCA repositories to use (ADD MORE HERE)
declare -A OCA_REPOS=(
    ["server-tools"]="https://github.com/OCA/account-financial-tools"
)

# Host temporary directory for consolidated requirements
HOST_TEMP_DIR="$OCA_DIR/temp_reqs"
HOST_REQ_FILE="$HOST_TEMP_DIR/all_requirements.txt"


# --- 1. Clone or Update Repositories ---
echo "--- 1. CLONING AND UPDATING REPOSITORIES ---"
mkdir -p "$OCA_DIR" # Ensure the base directory exists

for repo_name in "${!OCA_REPOS[@]}"; do
    repo_url="${OCA_REPOS[$repo_name]}"
    repo_path="$OCA_DIR/$repo_name"
    
    if [ -d "$repo_path/.git" ]; then
        echo "Updating $repo_name..."
        # Use subshell to safely manage directory changes (fixing the 'cd -' issue)
        ( 
            cd "$repo_path" || exit 1 # Exit subshell on CD failure
            git fetch origin
            git checkout "$OCA_VERSION" 
            git pull origin "$OCA_VERSION"
        )
    else
        echo "Cloning $repo_name..."
        git clone -b "$OCA_VERSION" "$repo_url" "$repo_path"
    fi
done


# --- 2. Install Python Dependencies (Consolidated Method) ---
echo "--- 2. INSTALLING PYTHON DEPENDENCIES ---"
mkdir -p "$HOST_TEMP_DIR"
rm -f "$HOST_REQ_FILE" # Clean up previous file

# Concatenate all requirements.txt files into one master file on the host
for repo_name in "${!OCA_REPOS[@]}"; do
    repo_path="$OCA_DIR/$repo_name"
    if [ -f "$repo_path/requirements.txt" ]; then
        echo "Adding requirements from $repo_name"
        cat "$repo_path/requirements.txt" >> "$HOST_REQ_FILE"
    fi
done

# Check if there are any requirements to install
if [ -f "$HOST_REQ_FILE" ] && [ -s "$HOST_REQ_FILE" ]; then
    echo "Installing required packages inside the Odoo container..."
    
    # 2a. Copy the consolidated requirements file into the running container
    docker cp "$HOST_REQ_FILE" "$ODOO_SERVICE_NAME":/tmp/all_requirements.txt
    
    # 2b. Execute pip install inside the container in a single, efficient command
    # Using 'docker compose exec' is generally cleaner than 'docker exec' alone
    docker compose exec -T "$ODOO_SERVICE_NAME" pip3 install -r /tmp/all_requirements.txt
else
    echo "No custom requirements.txt files found or they were empty."
fi

# Clean up host temporary directory
rm -rf "$HOST_TEMP_DIR"

echo "OCA modules installation completed!"
