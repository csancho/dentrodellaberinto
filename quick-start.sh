#!/bin/bash

# PrestaShop Quick Start Script - All-in-One Setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo "🚀 PrestaShop Quick Start - Complete Setup"
echo "=========================================="

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    print_warning "Containers are already running. Stopping them first..."
    docker-compose down
fi

# Run the main setup
print_status "Running complete setup..."
./docker-setup.sh

# Wait a moment for everything to stabilize
print_status "Waiting for services to stabilize..."
sleep 10

# Verify PrestaShop is accessible
print_status "Verifying PrestaShop accessibility..."
if curl -s http://localhost:8090 >/dev/null; then
    print_success "PrestaShop is accessible!"
else
    print_warning "PrestaShop might still be starting up..."
fi

# Final success message
echo ""
echo "🎉 PrestaShop Quick Start Complete!"
echo "=================================="
echo ""
echo "📋 Your PrestaShop is ready at:"
echo "   🌐 Frontend: http://localhost:8090"
echo "   🔧 Admin: http://localhost:8090/admin (check logs for exact URL)"
echo "   🗄️ Database: http://localhost:8091 (phpMyAdmin)"
echo "   📧 Mail: http://localhost:1090 (Mailcatcher)"
echo ""
echo "🔑 Database Connection:"
echo "   Host: mysql"
echo "   Database: prestashop"
echo "   Username: prestashop" 
echo "   Password: prestashop"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost:8090 in your browser"
echo "   2. Follow the PrestaShop installation wizard"
echo "   3. Use the database settings above"
echo "   4. Complete the installation"
echo ""
print_success "Happy coding! 🎯"