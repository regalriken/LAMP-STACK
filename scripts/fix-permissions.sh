#!/bin/bash

# Define the web root
WEB_ROOT="/var/www/lampapp"

echo "Setting ownership to $USER and group to www-data..."
sudo chown -R $USER:www-data "$WEB_ROOT"

echo "Setting directory permissions to 755..."
find "$WEB_ROOT" -type d -exec chmod 755 {} \;

echo "Setting file permissions to 644..."
find "$WEB_ROOT" -type f -exec chmod 644 {} \;

echo "Permissions have been reset."
