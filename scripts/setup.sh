#!/bin/bash

# --- 1. Colors for better readability ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting LAMP Server Auto-Setup...${NC}"

# --- 2. Update and Install Core Packages ---
echo -e "${GREEN}Installing Apache, MySQL, and PHP 8.3...${NC}"
sudo apt update
sudo apt install -y apache2 mysql-server php8.3 php8.3-mysql libapache2-mod-php php8.3-curl php8.3-gd php8.3-mbstring php8.3-xml php8.3-zip

# --- 3. Configure Apache Virtual Host ---
echo -e "${GREEN}Configuring Apache Virtual Host...${NC}"
# Copy our custom config from the repo to the system
sudo cp configs/apache-vhost.conf /etc/apache2/sites-available/lampapp.conf

# Enable the new site and rewrite module
sudo a2ensite lampapp.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite

# --- 4. Setup Web Directory & Permissions ---
echo -e "${GREEN}Setting up /var/www/lampapp and fixing permissions...${NC}"
sudo mkdir -p /var/www/lampapp/public
# Ensure the current user owns the folder, but Apache (www-data) can read it
sudo chown -R $USER:www-data /var/www/lampapp
sudo chmod -R 755 /var/www/lampapp

# --- 5. Import Database Schema ---
echo -e "${GREEN}Importing Database Schema...${NC}"
# Note: This assumes 'lampdb' exists. If not, the user must create it first.
if [ -f "configs/schema.sql" ]; then
    sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS lampdb;"
    sudo mysql -u root lampdb < configs/schema.sql
    echo "Database schema imported successfully."
else
    echo "Warning: configs/schema.sql not found. Skipping DB import."
fi

# --- 6. Final Security & Restart ---
echo -e "${GREEN}Restarting Services...${NC}"
sudo systemctl restart apache2
sudo systemctl restart mysql

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}SETUP COMPLETE!${NC}"
echo -e "Access your app at: http://$(hostname -I | awk '{print $1}')"
echo -e "${BLUE}==========================================${NC}"
