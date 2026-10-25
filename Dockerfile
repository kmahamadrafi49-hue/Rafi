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

# Run composer install inside casino folder where composer.json is located
RUN if [ -d "casino" ] && [ -f "casino/composer.json" ]; then \
        cd casino && composer install --no-dev --optimize-autoloader --no-scripts; \
    fi

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
