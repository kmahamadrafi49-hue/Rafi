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

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Change Apache DocumentRoot to point directly to casino/public folder
RUN sed -i 's!/var/www/html!/var/www/html/casino/public!g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's!/var/www/!/var/www/html/casino/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache

EXPOSE 80
