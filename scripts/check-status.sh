#!/bin/bash

echo "--- Service Status ---"
systemctl is-active --quiet apache2 && echo "✅ Apache is running" || echo "❌ Apache is DOWN"
systemctl is-active --quiet mysql && echo "✅ MySQL is running" || echo "❌ MySQL is DOWN"
systemctl is-active --quiet fail2ban && echo "✅ Fail2Ban is running" || echo "❌ Fail2Ban is DOWN"

echo -e "\n--- Firewall Status ---"
sudo ufw status | grep -E "OpenSSH|Apache Full"

echo -e "\n--- Disk Usage ---"
df -h / | grep /
