-- Create PrestaShop database if it doesn't exist
CREATE DATABASE IF NOT EXISTS prestashop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to prestashop user
GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashop'@'%';
FLUSH PRIVILEGES;
