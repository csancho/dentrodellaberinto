# PrestaShop Docker Development Environment Setup Script (PowerShell)

param(
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Host.UI.RawUI.ForegroundColor = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host "🚀 Setting up PrestaShop Docker development environment..." -ForegroundColor Cyan

# Check if Docker is installed
Write-Status "Checking Docker installation..."
try {
    $dockerVersion = docker --version
    Write-Success "Docker found: $dockerVersion"
} catch {
    Write-Error "Docker is not installed or not in PATH. Please install Docker Desktop first."
    Write-Host "Download from: https://www.docker.com/products/docker-desktop"
    exit 1
}

# Check if Docker Compose is installed
Write-Status "Checking Docker Compose installation..."
try {
    $composeVersion = docker-compose --version
    Write-Success "Docker Compose found: $composeVersion"
} catch {
    Write-Error "Docker Compose is not installed or not in PATH."
    Write-Host "Please install Docker Desktop which includes Docker Compose."
    exit 1
}

# Check if Docker is running
Write-Status "Checking if Docker is running..."
try {
    docker info | Out-Null
    Write-Success "Docker is running"
} catch {
    Write-Error "Docker is not running. Please start Docker Desktop."
    exit 1
}

# Create necessary directories
Write-Status "Creating necessary directories..."
$directories = @(
    "docker\mysql\init",
    "uploads",
    "img"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Gray
    }
}

# Create MySQL initialization script
Write-Status "Creating MySQL initialization script..."
$mysqlInit = @"
-- Create PrestaShop database if it doesn't exist
CREATE DATABASE IF NOT EXISTS prestashop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to prestashop user
GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashop'@'%';
FLUSH PRIVILEGES;
"@

$mysqlInit | Out-File -FilePath "docker\mysql\init\01-create-database.sql" -Encoding UTF8

# Create environment file for development
Write-Status "Creating environment configuration..."
$envContent = @"
# Docker Environment Configuration
COMPOSE_PROJECT_NAME=prestashop-dev

# Database Configuration
DB_HOST=mysql
DB_NAME=prestashop
DB_USER=prestashop
DB_PASSWORD=prestashop
DB_ROOT_PASSWORD=root

# PrestaShop Configuration
PS_ADMIN_EMAIL=admin@prestashop.local
PS_ADMIN_PASSWORD=admin123
PS_DOMAIN=localhost:8090

# Development Settings
ENVIRONMENT=development
DEBUG=true
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

# Set proper permissions (Windows equivalent)
Write-Status "Setting proper permissions..."
# Windows doesn't need specific file permissions like Unix systems

# Build and start containers
Write-Status "Building Docker containers (this may take a few minutes)..."
try {
    docker-compose build
    Write-Success "Docker build completed successfully"
} catch {
    Write-Error "Docker build failed. Check the error messages above."
    exit 1
}

Write-Status "Starting containers..."
try {
    docker-compose up -d
    Write-Success "Containers started successfully"
} catch {
    Write-Error "Failed to start containers. Check the error messages above."
    exit 1
}

# Wait for MySQL to be ready
Write-Status "Waiting for MySQL to be ready..."
Start-Sleep -Seconds 30

# Check if containers are running
Write-Status "Checking container status..."
$runningContainers = docker-compose ps --filter "status=running" -q
if ($runningContainers) {
    Write-Success "Containers are running!"
} else {
    Write-Error "Some containers failed to start. Check with 'docker-compose logs'"
    Write-Host "You can check logs with: docker-compose logs -f"
    exit 1
}

# Fix PrestaShop permissions automatically
Write-Status "Fixing PrestaShop permissions for installation..."

# Create necessary directories inside container
Write-Status "Creating required directories..."
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/genders 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/os 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/p 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/c 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/m 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/su 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/s 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/cms 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/scenes 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/upload 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/download 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/cache 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/compile 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/config 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/cache 2>$null
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/logs 2>$null

# Set proper ownership and permissions
Write-Status "Setting proper ownership and permissions..."
docker exec prestashop_app chown -R www-data:www-data /var/www/html/prestashop 2>$null
docker exec prestashop_app find /var/www/html/prestashop -type d -exec chmod 755 {} `\; 2>$null
docker exec prestashop_app find /var/www/html/prestashop -type f -exec chmod 644 {} `\; 2>$null

# Set writable permissions for installation directories
Write-Status "Setting writable permissions for installation..."
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/var 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/img 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/upload 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/download 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/cache 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/config 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/modules 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/themes 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/translations 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/mails 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/override 2>$null
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/install 2>$null

Write-Success "Permissions configured successfully!"

# Display access information
Write-Host ""
Write-Host "🎉 PrestaShop Docker environment is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Access Information:" -ForegroundColor Cyan
Write-Host "   PrestaShop Frontend: http://localhost:8090" -ForegroundColor White
Write-Host "   PrestaShop Admin:    http://localhost:8090/admin (check container logs for exact URL)" -ForegroundColor White
Write-Host "   phpMyAdmin:          http://localhost:8091" -ForegroundColor White
Write-Host "   Mailcatcher:         http://localhost:1090" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Default Credentials:" -ForegroundColor Cyan
Write-Host "   Admin Email:     admin@prestashop.local" -ForegroundColor White
Write-Host "   Admin Password:  admin123" -ForegroundColor White
Write-Host "   Database:        prestashop/prestashop" -ForegroundColor White
Write-Host "   MySQL Root:      root/root" -ForegroundColor White
Write-Host ""
Write-Host "🛠️  Useful Commands:" -ForegroundColor Cyan
Write-Host "   Start:           docker-compose up -d" -ForegroundColor White
Write-Host "   Stop:            docker-compose down" -ForegroundColor White
Write-Host "   Logs:            docker-compose logs -f" -ForegroundColor White
Write-Host "   Rebuild:         docker-compose build --no-cache" -ForegroundColor White
Write-Host "   Shell Access:    docker exec -it prestashop_app bash" -ForegroundColor White
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open http://localhost:8090 in your browser" -ForegroundColor White
Write-Host "   2. Follow the PrestaShop installation wizard" -ForegroundColor White
Write-Host "   3. Use the database settings from above" -ForegroundColor White
Write-Host ""

Write-Host ""
Write-Status "🔧 Testing PHP Configuration:"
Write-Host "   You can test PHP settings at: http://localhost:8090/test-php-config.php"
Write-Host "   Remove this file before going to production!"

Write-Warning "Note: If this is your first time, you may need to run the PrestaShop installer."
Write-Warning "The admin directory name will be randomized for security. Check container logs to find it."

Write-Success "Setup complete! Happy coding! 🚀"

# Optional: Open browser automatically
$openBrowser = Read-Host "Would you like to open PrestaShop in your browser now? (y/N)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process "http://localhost:8090"
}