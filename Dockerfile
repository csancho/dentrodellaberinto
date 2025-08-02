FROM php:8.1-apache

# Install system dependencies including latest ICU
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libxslt-dev \
    default-mysql-client \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions with proper intl configuration
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        gd \
        zip \
        intl \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        xml \
        xsl \
        opcache \
        bcmath \
        soap \
    && docker-php-ext-enable pdo_mysql mysqli intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite headers

# Set PHP configuration for PrestaShop
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_vars = 10000'; \
    echo 'date.timezone = UTC'; \
    echo 'short_open_tag = Off'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.max_accelerated_files = 4000'; \
    echo 'opcache.revalidate_freq = 60'; \
    } > /usr/local/etc/php/conf.d/prestashop.ini

# Configure Apache for PrestaShop
RUN { \
    echo '<VirtualHost *:80>'; \
    echo '    DocumentRoot /var/www/html/prestashop'; \
    echo '    <Directory /var/www/html/prestashop>'; \
    echo '        AllowOverride All'; \
    echo '        Require all granted'; \
    echo '    </Directory>'; \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log'; \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
    echo '</VirtualHost>'; \
    } > /etc/apache2/sites-available/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Create and set permissions for all necessary directories
RUN mkdir -p /var/www/html/prestashop/var/cache \
    && mkdir -p /var/www/html/prestashop/var/logs \
    && mkdir -p /var/www/html/prestashop/img/genders \
    && mkdir -p /var/www/html/prestashop/img/os \
    && mkdir -p /var/www/html/prestashop/img/p \
    && mkdir -p /var/www/html/prestashop/img/c \
    && mkdir -p /var/www/html/prestashop/img/m \
    && mkdir -p /var/www/html/prestashop/img/su \
    && mkdir -p /var/www/html/prestashop/img/s \
    && mkdir -p /var/www/html/prestashop/img/cms \
    && mkdir -p /var/www/html/prestashop/img/scenes \
    && mkdir -p /var/www/html/prestashop/upload \
    && mkdir -p /var/www/html/prestashop/download \
    && mkdir -p /var/www/html/prestashop/mails \
    && mkdir -p /var/www/html/prestashop/modules \
    && mkdir -p /var/www/html/prestashop/themes \
    && mkdir -p /var/www/html/prestashop/translations \
    && mkdir -p /var/www/html/prestashop/override \
    && mkdir -p /var/www/html/prestashop/cache/smarty/cache \
    && mkdir -p /var/www/html/prestashop/cache/smarty/compile \
    && mkdir -p /var/www/html/prestashop/config \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod -R 777 /var/www/html/prestashop/var \
    && chmod -R 777 /var/www/html/prestashop/img \
    && chmod -R 777 /var/www/html/prestashop/upload \
    && chmod -R 777 /var/www/html/prestashop/download \
    && chmod -R 777 /var/www/html/prestashop/cache \
    && chmod -R 777 /var/www/html/prestashop/config \
    && chmod -R 777 /var/www/html/prestashop/modules \
    && chmod -R 777 /var/www/html/prestashop/themes \
    && chmod -R 777 /var/www/html/prestashop/translations \
    && chmod -R 777 /var/www/html/prestashop/mails \
    && chmod -R 777 /var/www/html/prestashop/override

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]