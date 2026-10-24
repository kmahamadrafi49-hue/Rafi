FROM php:8.2-apache

# Install system dependencies and composer
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    && docker-php-ext-install pdo pdo_mysql mysqli zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . /var/www/html/
WORKDIR /var/www/html/

# Run composer install inside casino folder
RUN if [ -d "casino" ] && [ -f "casino/composer.json" ]; then \
        cd casino && composer install --no-dev --optimize-autoloader --no-scripts; \
    fi

# Setup Laravel .env and permissions inside casino folder
RUN if [ -d "casino" ] && [ -f "casino/.env.example" ] && [ ! -f "casino/.env" ]; then \
        cp casino/.env.example casino/.env; \
    fi

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache

EXPOSE 80
