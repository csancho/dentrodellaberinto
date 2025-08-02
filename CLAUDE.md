# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a PrestaShop 9.x e-commerce platform installation. PrestaShop is an open-source e-commerce solution built with PHP, using Symfony framework components and Smarty templating engine.

## Development Commands

### Build and Asset Management
- `make install` - Complete installation: PHP dependencies and static assets
- `make composer` - Install PHP dependencies via Composer
- `make assets` - Rebuild all static assets (runs npm install-clean as needed)
- `./tools/assets/build.sh` - Manual asset building script

### Asset Building (Theme-specific)
- `make front-core` - Build core theme assets
- `make front-classic` - Build classic theme assets
- `make front-hummingbird` - Build hummingbird theme assets
- `make admin-default` - Build admin default theme assets
- `make admin-new-theme` - Build admin new theme assets
- `make admin` - Build all admin theme assets
- `make front` - Build all front theme assets

### Code Quality and Linting
- `make cs-fixer` - Run PHP CS Fixer for code style
- `make phpstan` - Run PHPStan static analysis
- `make scss-fixer` - Run SCSS formatting for all themes
- `make es-linter` - Run ES linting for all themes

### Console Commands
- `./bin/console cache:clear` - Clear application cache
- `./bin/console cache:clear --no-warmup` - Clear cache without warmup

## Architecture Overview

### Core Structure
- **`prestashop/`** - Main application directory
- **`prestashop/src/`** - Modern PSR-4 organized source code
  - `Core/` - Core business logic and interfaces  
  - `Adapter/` - Legacy system adapters
  - `PrestaShopBundle/` - Symfony bundle integration
- **`prestashop/classes/`** - Legacy ObjectModel classes and core components
- **`prestashop/controllers/`** - MVC controllers for admin and front
- **`prestashop/themes/`** - Frontend theme files and assets
- **`prestashop/modules/`** - Extension modules

### Key Application Components
- **AppKernel** (`app/AppKernel.php`) - Symfony application kernel
- **ObjectModel** (`classes/ObjectModel.php`) - Base class for all data models
- **Configuration** (`config/config.inc.php`) - Main configuration bootstrap
- **Context** - Global application state management
- **Hook System** - Event-driven architecture for extensibility

### Database Layer
- Uses Doctrine ORM for modern components
- Legacy database layer via `classes/db/Db.php`
- Entity definitions in `src/PrestaShopBundle/Entity/`

### Frontend Architecture
- **Smarty** templating engine for themes
- **JavaScript** built with Webpack
- **SCSS/CSS** for styling
- Theme assets built to optimize performance

### Module System
- Modular architecture for extending functionality
- Hooks provide integration points
- Payment, shipping, and feature modules

### API Layer
- Admin API functionality via `admin-api/`
- API Platform integration for modern REST APIs
- Legacy webservice in `webservice/`

## Development Workflow

### Docker Development Environment (Recommended)

This project includes a complete Docker setup for local development:

#### Quick Start
1. **Prerequisites**: Install Docker and Docker Compose
2. **Setup**: Run `./docker-setup.sh` to initialize the environment
3. **Access**: Open http://localhost:8090 for PrestaShop

#### Docker Services
- **PrestaShop App**: http://localhost:8090 (PHP 8.1 + Apache)
- **PostgreSQL Database**: localhost:5433 (prestashop/prestashop)
- **pgAdmin**: http://localhost:8091 (database management)
- **Mailcatcher**: http://localhost:1090 (email testing)
- **Redis**: localhost:6380 (caching)

#### Docker Commands
- `docker-compose up -d` - Start all services
- `docker-compose down` - Stop all services
- `docker-compose logs -f prestashop` - View application logs
- `docker exec -it prestashop_app bash` - Access application shell
- `docker-compose build --no-cache` - Rebuild containers

#### File Synchronization
- Local files in `prestashop/` are mounted into the container
- Changes to PHP/theme files are immediately reflected
- Use `make assets` inside container for theme builds
- Database data persists in Docker volumes

### Manual Installation (Alternative)
1. Install PHP 8.1+ and PostgreSQL 12+
2. Run `make install` to set up dependencies and assets
3. Configure database in `config/settings.inc.php` (auto-generated during install)
4. Access admin panel at `/admin/` (directory name varies for security)

### Working with Themes
- Frontend themes in `themes/` directory
- Admin themes in `admin-dev/themes/` and `admin/themes/`
- Use `make front-*` and `make admin-*` commands to build theme assets
- Asset source files typically in `_dev/` subdirectories

### Module Development
- Create modules in `modules/` directory
- Follow PrestaShop module conventions
- Use hooks for integration points
- Test module functionality after installation

### Code Standards
- PHP CS Fixer configured for PSR-12 compliance
- PHPStan for static analysis
- SCSS linting for consistent styling
- ESLint for JavaScript code quality

## Testing
- PHPUnit tests can be run from project root
- Check for test configuration in `phpunit.xml` or similar
- Integration tests may require database setup

## Important Notes
- Always clear cache after configuration changes
- Use proper PrestaShop APIs rather than direct database access
- Follow PrestaShop coding standards and conventions
- Be careful with multi-shop configurations if enabled
- Override classes should be placed in `override/` directory