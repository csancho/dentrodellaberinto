#!/bin/bash

# PrestaShop Permissions Fix Script

echo "🔧 Fixing PrestaShop permissions..."

# Create necessary directories
echo "Creating required directories..."
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/genders
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/os
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/p
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/c
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/m
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/su
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/s
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/cms
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/scenes
docker exec prestashop_app mkdir -p /var/www/html/prestashop/upload
docker exec prestashop_app mkdir -p /var/www/html/prestashop/download
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/cache
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/compile
docker exec prestashop_app mkdir -p /var/www/html/prestashop/config
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/cache
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/logs

# Set ownership
echo "Setting ownership to www-data..."
docker exec prestashop_app chown -R www-data:www-data /var/www/html/prestashop

# Set permissions
echo "Setting directory permissions..."
docker exec prestashop_app find /var/www/html/prestashop -type d -exec chmod 755 {} \;

echo "Setting file permissions..."
docker exec prestashop_app find /var/www/html/prestashop -type f -exec chmod 644 {} \;

# Set writable permissions for installation
echo "Setting writable permissions for installation directories..."
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/var
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/img
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/upload
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/download
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/cache
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/config
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/modules
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/themes
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/translations
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/mails
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/override

# Special permissions for install directory
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/install

echo "✅ Permissions fixed successfully!"
echo ""
echo "Now you can retry the PrestaShop installation:"
echo "   1. Go to http://localhost:8090"
echo "   2. Follow the installation wizard"
echo "   3. Use database settings: mysql:3306, prestashop/prestashop"
echo ""
echo "If you still have issues, you can also try:"
echo "   docker-compose restart prestashop"