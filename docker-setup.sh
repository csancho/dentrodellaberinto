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
mkdir -p docker/postgres/init
mkdir -p uploads
mkdir -p img

# Create PostgreSQL initialization script
print_status "Creating PostgreSQL initialization script..."
cat > docker/postgres/init/01-create-extensions.sql << 'EOF'
-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Set timezone
SET timezone = 'UTC';
EOF

# Create environment file for development
print_status "Creating environment configuration..."
cat > .env << 'EOF'
# Docker Environment Configuration
COMPOSE_PROJECT_NAME=prestashop-dev

# Database Configuration
DB_HOST=postgres
DB_NAME=prestashop
DB_USER=prestashop
DB_PASSWORD=prestashop

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

# Wait for PostgreSQL to be ready
print_status "Waiting for PostgreSQL to be ready..."
sleep 30

# Check if containers are running
print_status "Checking container status..."
if docker-compose ps | grep -q "Up"; then
    print_success "Containers are running!"
else
    print_error "Some containers failed to start. Check with 'docker-compose logs'"
    exit 1
fi

# Display access information
echo ""
echo "🎉 PrestaShop Docker environment is ready!"
echo ""
echo "📋 Access Information:"
echo "   PrestaShop Frontend: http://localhost:8090"
echo "   PrestaShop Admin:    http://localhost:8090/admin (check container logs for exact URL)"
echo "   pgAdmin:             http://localhost:8091"
echo "   Mailcatcher:         http://localhost:1090"
echo ""
echo "🔑 Default Credentials:"
echo "   Admin Email:     admin@prestashop.local"
echo "   Admin Password:  admin123"
echo "   Database:        prestashop/prestashop"
echo "   pgAdmin:         admin@prestashop.local/admin123"
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

print_success "Setup complete! Happy coding! 🚀"