#!/bin/bash

# PrestaShop Docker Development Environment Setup Script

set -e

echo "🚀 Setting up PrestaShop Docker development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p docker/mysql/init
mkdir -p uploads
mkdir -p img

# Create MySQL initialization script
print_status "Creating MySQL initialization script..."
cat > docker/mysql/init/01-create-database.sql << 'EOF'
-- Create PrestaShop database if it doesn't exist
CREATE DATABASE IF NOT EXISTS prestashop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to prestashop user
GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashop'@'%';
FLUSH PRIVILEGES;
EOF

# Create environment file for development
print_status "Creating environment configuration..."
cat > .env << 'EOF'
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
PS_DOMAIN=localhost:8080

# Development Settings
ENVIRONMENT=development
DEBUG=true
EOF

# Set proper permissions
print_status "Setting proper permissions..."
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
    chmod +x docker-setup.sh
    sudo chown -R $USER:$USER prestashop/ 2>/dev/null || true
    chmod -R 755 prestashop/ 2>/dev/null || true
fi

# Build and start containers
print_status "Building Docker containers (this may take a few minutes)..."
docker-compose build

print_status "Starting containers..."
docker-compose up -d

# Wait for MySQL to be ready
print_status "Waiting for MySQL to be ready..."
sleep 30

# Check if containers are running
print_status "Checking container status..."
if docker-compose ps | grep -q "Up"; then
    print_success "Containers are running!"
else
    print_error "Some containers failed to start. Check with 'docker-compose logs'"
    exit 1
fi

# Fix PrestaShop permissions automatically
print_status "Fixing PrestaShop permissions for installation..."

# Create necessary directories inside container
print_status "Creating required directories..."
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/genders 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/os 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/p 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/c 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/m 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/su 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/s 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/cms 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/img/scenes 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/upload 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/download 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/cache 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/cache/smarty/compile 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/config 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/cache 2>/dev/null || true
docker exec prestashop_app mkdir -p /var/www/html/prestashop/var/logs 2>/dev/null || true

# Set proper ownership and permissions
print_status "Setting proper ownership and permissions..."
docker exec prestashop_app chown -R www-data:www-data /var/www/html/prestashop 2>/dev/null || true
docker exec prestashop_app find /var/www/html/prestashop -type d -exec chmod 755 {} \; 2>/dev/null || true
docker exec prestashop_app find /var/www/html/prestashop -type f -exec chmod 644 {} \; 2>/dev/null || true

# Set writable permissions for installation directories
print_status "Setting writable permissions for installation..."
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/var 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/img 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/upload 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/download 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/cache 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/config 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/modules 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/themes 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/translations 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/mails 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/override 2>/dev/null || true
docker exec prestashop_app chmod -R 777 /var/www/html/prestashop/install 2>/dev/null || true

print_success "Permissions configured successfully!"

# Display access information
echo ""
echo "🎉 PrestaShop Docker environment is ready!"
echo ""
echo "📋 Access Information:"
echo "   🌐 Development Mode:"
echo "     PrestaShop:        http://localhost:8090"
echo "     phpMyAdmin:        http://localhost:8091"
echo "     Mailcatcher:       http://localhost:1090"
echo ""
echo "   🚀 Production Mode (with Traefik):"
echo "     PrestaShop:        https://dentrodellaberinto.com"
echo "     phpMyAdmin:        https://db.dentrodellaberinto.com"
echo "     Traefik Dashboard: https://traefik.dentrodellaberinto.com"
echo ""
echo "🔑 Default Credentials:"
echo "   Admin Email:     admin@prestashop.local"
echo "   Admin Password:  admin123"
echo "   Database:        prestashop/prestashop"
echo "   MySQL Root:      root/root"
echo ""
echo "🛠️  Useful Commands:"
echo "   Start:           docker-compose up -d"
echo "   Stop:            docker-compose down"
echo "   Logs:            docker-compose logs -f"
echo "   Rebuild:         docker-compose build --no-cache"
echo "   Shell Access:    docker exec -it prestashop_app bash"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost:8090 in your browser"
echo "   2. Follow the PrestaShop installation wizard"
echo "   3. Use the database settings from above"
echo ""

print_warning "Note: If this is your first time, you may need to run the PrestaShop installer."
print_warning "The admin directory name will be randomized for security. Check container logs to find it."

echo ""
print_status "🔧 Testing PHP Configuration:"
echo "   You can test PHP settings at: http://localhost:8090/test-php-config.php"
echo "   Remove this file before going to production!"

echo ""
print_status "🌐 Production Setup (Traefik):"
echo "   1. Copy .env.example to .env and configure your settings"
echo "   2. Set up Cloudflare DNS API token for Let's Encrypt"
echo "   3. Generate auth hashes with: htpasswd -nb admin password"
echo "   4. Point your domain DNS to this server"
echo "   5. Run: docker-compose up -d traefik"

print_success "Setup complete! Happy coding! 🚀"