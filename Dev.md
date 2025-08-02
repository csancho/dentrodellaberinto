The Docker configuration I created includes volume mounts that sync your local files
   with the container in real-time. This means you can edit files locally and see changes immediately.

  📁 File Synchronization Setup

  Volume Mounts in docker-compose.yml:

  volumes:
    - ./prestashop:/var/www/html/prestashop
    - ./uploads:/var/www/html/prestashop/upload
    - ./img:/var/www/html/prestashop/img

  What This Means:

  - Local prestashop/ folder ↔ Container /var/www/html/prestashop
  - Local uploads/ folder ↔ Container upload directory
  - Local img/ folder ↔ Container image directory

  🛠️ Development Workflow

  1. Edit Files Locally

  Use any editor (VS Code, PHPStorm, etc.) to modify files in:
  - prestashop/ - Main application code
  - prestashop/themes/ - Frontend themes
  - prestashop/modules/ - Custom modules
  - prestashop/classes/ - Core classes

  2. Changes Reflect Immediately

  - PHP files - Changes appear instantly (no restart needed)
  - Smarty templates - Immediate updates
  - CSS/JS - May need cache clearing or asset rebuild

  3. Asset Building

  For theme development, run asset builds inside the container:
  # Access container shell
  docker exec -it prestashop_app bash

  # Inside container
  make assets          # Build all assets
  make front-classic   # Build specific theme
  make admin-default   # Build admin theme

  4. Cache Management

  Clear PrestaShop cache when needed:
  # Inside container
  ./bin/console cache:clear
  # Or manually delete cache folders
  rm -rf var/cache/*

  💡 Development Tips

  File Permissions

  The container sets proper permissions, but if you encounter issues:
  # On Linux/Mac, ensure your user owns the files
  sudo chown -R $USER:$USER prestashop/

  Live Editing Examples

  - Module development: Edit prestashop/modules/yourmodule/
  - Theme customization: Edit prestashop/themes/classic/
  - Core modifications: Edit prestashop/classes/ or prestashop/src/

  Database Access

  - Direct connection: localhost:5433 (from host)
  - pgAdmin UI: http://localhost:8091
  - Inside container: Use postgres:5432 as host