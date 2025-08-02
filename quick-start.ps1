# PrestaShop Quick Start Script - All-in-One Setup (PowerShell)

$ErrorActionPreference = "Stop"

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

Write-Host "🚀 PrestaShop Quick Start - Complete Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if containers are already running
$runningContainers = docker-compose ps --filter "status=running" -q 2>$null
if ($runningContainers) {
    Write-Warning "Containers are already running. Stopping them first..."
    docker-compose down
}

# Run the main setup
Write-Status "Running complete setup..."
try {
    .\docker-setup.ps1
} catch {
    Write-Error "Setup failed: $($_.Exception.Message)"
    exit 1
}

# Wait a moment for everything to stabilize
Write-Status "Waiting for services to stabilize..."
Start-Sleep -Seconds 10

# Verify PrestaShop is accessible
Write-Status "Verifying PrestaShop accessibility..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 10 -UseBasicParsing
    Write-Success "PrestaShop is accessible!"
} catch {
    Write-Warning "PrestaShop might still be starting up..."
}

# Final success message
Write-Host ""
Write-Host "🎉 PrestaShop Quick Start Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Your PrestaShop is ready at:" -ForegroundColor Cyan
Write-Host "   🌐 Frontend: http://localhost:8090" -ForegroundColor White
Write-Host "   🔧 Admin: http://localhost:8090/admin (check logs for exact URL)" -ForegroundColor White
Write-Host "   🗄️ Database: http://localhost:8091 (phpMyAdmin)" -ForegroundColor White
Write-Host "   📧 Mail: http://localhost:1090 (Mailcatcher)" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Database Connection:" -ForegroundColor Cyan
Write-Host "   Host: mysql" -ForegroundColor White
Write-Host "   Database: prestashop" -ForegroundColor White
Write-Host "   Username: prestashop" -ForegroundColor White
Write-Host "   Password: prestashop" -ForegroundColor White
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open http://localhost:8090 in your browser" -ForegroundColor White
Write-Host "   2. Follow the PrestaShop installation wizard" -ForegroundColor White
Write-Host "   3. Use the database settings above" -ForegroundColor White
Write-Host "   4. Complete the installation" -ForegroundColor White
Write-Host ""
Write-Success "Happy coding! 🎯"

# Optional: Open browser automatically
$openBrowser = Read-Host "Would you like to open PrestaShop in your browser now? (y/N)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process "http://localhost:8090"
}