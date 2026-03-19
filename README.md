# 🔦 LAMP Stack Server — VMware Edition

A complete, production-style LAMP (Linux, Apache, MySQL, PHP) server built inside a VMware virtual machine — configured, secured, and documented from scratch.

> **Stack:** Ubuntu 22.04 LTS · Apache 2.4 · MySQL 8.0 · PHP 8.1  
> **Platform:** VMware Workstation Pro / Player on Windows or macOS

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Stack & Environment](#stack--environment)
- [Project Structure](#project-structure)
- [Setup Overview](#setup-overview)
- [Phase Guide](#phase-guide)
- [Security Measures](#security-measures)
- [Screenshots](#screenshots)
- [What I Learned](#what-i-learned)

---

## About the Project

This project demonstrates how to build and manage a fully functional LAMP web server inside a VMware virtual machine. It covers everything from VM creation and OS installation through to deploying a PHP application that reads from a MySQL database, applying security hardening, setting up automated backups, and pushing the whole thing to GitHub.

The goal was to simulate a real-world Linux server environment and get hands-on experience with system administration, web server configuration, and basic DevOps practices.

---

## Stack & Environment

| Component     | Version / Details                          |
|---------------|--------------------------------------------|
| Host OS       | Windows 10/11 or macOS                     |
| Hypervisor    | VMware Workstation Pro 17 / Player (free)  |
| Guest OS      | Ubuntu Server 22.04 LTS                    |
| Web Server    | Apache 2.4                                 |
| Database      | MySQL 8.0                                  |
| Language      | PHP 8.1                                    |
| Firewall      | UFW (Uncomplicated Firewall)               |
| Intrusion Det.| Fail2Ban                                   |
| SSL (optional)| Let's Encrypt (Certbot)                    |

---

## Project Structure

```
lamp-server-setup/
├── configs/
│   ├── apache-vhost.conf       # Apache virtual host configuration
│   └── security.conf           # Apache security headers config
├── scripts/
│   └── backup_db.sh            # Automated MySQL backup script (runs via cron)
├── screenshots/                # All 16 checkpoint screenshots
│   ├── 01-ssh-login.png
│   ├── 02-ufw-status.png
│   ├── 03-apache-status.png
│   └── ...
└── README.md
```

---

## Setup Overview

The project follows a 12-phase build process:

| Phase | What Happens |
|-------|-------------|
| 0 | Prerequisites — download VMware, Ubuntu ISO, tools |
| 1 | Create the Ubuntu VM in VMware (2 GB RAM, 2 vCPUs, NAT) |
| 2 | Install Ubuntu Server 22.04, enable SSH |
| 3 | SSH from host, update packages, configure UFW firewall |
| 4 | Install & configure Apache web server |
| 5 | Install MySQL, run security hardening, create app database & user |
| 6 | Install PHP 8.1 and required extensions |
| 7 | Configure Apache virtual host for the application |
| 8 | Deploy a PHP app that connects to MySQL and displays data |
| 9 | Security hardening — hide versions, disable directory listing, Fail2Ban, HTTP headers |
| 10 | Monitoring — Apache logs, htop, automated MySQL backups with cron |
| 11 | Take 16 checkpoint screenshots for documentation |
| 12 | Push everything to GitHub, pin repo to profile |

---

## Phase Guide

### Phase 1 — VM Creation
- Created a VMware VM with 2 GB RAM, 2 vCPUs, 20 GB disk, NAT networking
- Installed Ubuntu Server 22.04 LTS using the built-in installer

### Phase 2 — Ubuntu Installation
- Configured server hostname: `lamp-server`
- Enabled OpenSSH during install for remote access
- Noted the VM's IP address (`ip a`) for SSH access from the host

### Phase 3 — SSH & System Setup
```bash
ssh lampuser@192.168.x.x
sudo apt update && sudo apt upgrade -y
sudo ufw allow OpenSSH && sudo ufw enable
```

### Phase 4 — Apache
```bash
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo ufw allow 'Apache Full'
```
Apache default page verified in the browser at the VM's IP.

### Phase 5 — MySQL
```bash
sudo apt install mysql-server -y
sudo mysql_secure_installation    # hardening: removed anon users, disabled remote root
```
Created application database and user:
```sql
CREATE DATABASE lampdb;
CREATE USER 'lampuser'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON lampdb.* TO 'lampuser'@'localhost';
```

### Phase 6 — PHP
```bash
sudo apt install php libapache2-mod-php php-mysql php-cli \
     php-curl php-gd php-mbstring php-xml php-zip -y
```
Confirmed PHP 8.1 with `php -v` and verified the `phpinfo()` page (then deleted it immediately).

### Phase 7 — Virtual Host
Configured `/etc/apache2/sites-available/lampapp.conf` with:
- `Options -Indexes` to disable directory listing
- `AllowOverride All` for `.htaccess` support
- Separate access and error log files

```bash
sudo a2ensite lampapp.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite
sudo apache2ctl configtest   # must return: Syntax OK
```

### Phase 8 — PHP Application
Deployed `index.php` to `/var/www/lampapp/public/` — a PHP app that:
- Connects to MySQL using PDO
- Displays connection status
- Queries and renders a `users` table in a styled HTML page

### Phase 9 — Security Hardening
- **Hidden server version:** `ServerTokens Prod` + `ServerSignature Off`
- **Directory listing disabled:** `Options -Indexes` in Apache config
- **Fail2Ban:** installed and SSH jail activated
- **HTTP Security Headers:** `X-Frame-Options`, `X-XSS-Protection`, `X-Content-Type-Options`, `Referrer-Policy`

```bash
curl -I http://192.168.x.x
# Server: Apache  ← no version number exposed
```

### Phase 10 — Monitoring & Backups
Live log monitoring:
```bash
sudo tail -f /var/log/apache2/lampapp_access.log
```

Automated daily backup via cron (`scripts/backup_db.sh`):
```bash
# Runs at 2:00 AM, keeps 7 days of backups
0 2 * * * /home/lampuser/backup_db.sh >> /var/log/mysql_backup.log 2>&1
```

---

## Security Measures

| Measure | Implementation |
|---------|---------------|
| Firewall | UFW — only SSH and Apache Full allowed |
| SSH hardening | Key-based preferred; Fail2Ban blocks brute-force attempts |
| MySQL | `mysql_secure_installation` run; no remote root login; app user limited to one DB |
| Apache | Version hidden, directory listing disabled, security headers enabled |
| PHP | `info.php` deleted after use; PDO with parameterised queries in app |
| Backups | Daily `mysqldump` to `/var/backups/mysql/`, 7-day retention |

---

## Screenshots

All 16 checkpoint screenshots are in the `screenshots/` folder:

| # | File | What It Shows |
|---|------|--------------|
| 01 | `01-ssh-login.png` | SSH login from host terminal |
| 02 | `02-ufw-status.png` | UFW with OpenSSH + Apache Full allowed |
| 03 | `03-apache-status.png` | systemctl status apache2 — active (running) |
| 04 | `04-apache-browser.png` | Apache default page or app in browser |
| 05 | `05-mysql-status.png` | systemctl status mysql — active (running) |
| 06 | `06-mysql-databases.png` | SHOW DATABASES — lampdb listed |
| 07 | `07-mysql-users-table.png` | SELECT * FROM users — 3 rows |
| 08 | `08-php-version.png` | php -v — PHP 8.1.x |
| 09 | `09-lamp-app-browser.png` | Full LAMP app — Connected + user table |
| 10 | `10-curl-headers.png` | curl -I — Server: Apache, security headers |
| 11 | `11-403-forbidden.png` | 403 Forbidden on directory URL |
| 12 | `12-fail2ban-status.png` | fail2ban-client status sshd — active |
| 13 | `13-access-log-tail.png` | Live tail of Apache access log |
| 14 | `14-htop.png` | htop — apache2 + mysqld processes |
| 15 | `15-backup-file.png` | ls -lh /var/backups/mysql/ — .sql backup |
| 16 | `16-crontab.png` | crontab -l — 2 AM backup job |

---

## What I Learned

- How to create and configure a Linux VM in VMware from scratch
- Installing and configuring all four components of a LAMP stack
- Apache virtual host configuration and `mod_rewrite`
- MySQL user/privilege management and security hardening
- Connecting PHP to MySQL using PDO with error handling
- UFW firewall rules and Fail2Ban intrusion prevention
- Apache security hardening (hiding version info, HTTP headers)
- Writing and scheduling Bash backup scripts with cron
- Reading and interpreting Apache access and error logs
- Organizing and documenting a sysadmin project for GitHub

---

*Built on Ubuntu 22.04 · Apache 2.4 · MySQL 8.0 · PHP 8.1 · VMware*
