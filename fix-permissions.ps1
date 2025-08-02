# PrestaShop Permissions Fix Script (PowerShell)

Write-Host "🔧 Fixing PrestaShop permissions..." -ForegroundColor Cyan

# Create necessary directories
Write-Host "Creating required directories..." -ForegroundColor Blue
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
Write-Host "Setting ownership to www-data..." -ForegroundColor Blue
docker exec prestashop_app chown -R www-data:www-data /var/www/html/prestashop

# Set permissions
Write-Host "Setting directory permissions..." -ForegroundColor Blue
docker exec prestashop_app find /var/www/html/prestashop -type d -exec chmod 755 {} `\;

Write-Host "Setting file permissions..." -ForegroundColor Blue
docker exec prestashop_app find /var/www/html/prestashop -type f -exec chmod 644 {} `\;

# Set writable permissions for installation
Write-Host "Setting writable permissions for installation directories..." -ForegroundColor Blue
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

Write-Host "✅ Permissions fixed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Now you can retry the PrestaShop installation:" -ForegroundColor Cyan
Write-Host "   1. Go to http://localhost:8090" -ForegroundColor White
Write-Host "   2. Follow the installation wizard" -ForegroundColor White
Write-Host "   3. Use database settings: mysql:3306, prestashop/prestashop" -ForegroundColor White
Write-Host ""
Write-Host "If you still have issues, you can also try:" -ForegroundColor Yellow
Write-Host "   docker-compose restart prestashop" -ForegroundColor White