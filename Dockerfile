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
WORKDIR /var/www/html

# Run composer install in root if exists (with --no-scripts)
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader --no-scripts; fi

# Run composer install inside casino folder if exists (with --no-scripts)
RUN if [ -d "casino" ] && [ -f "casino/composer.json" ]; then \
    cd casino && composer install --no-dev --optimize-autoloader --no-scripts; \
    fi

# Set Apache DocumentRoot to casino folder if index.php is inside it, otherwise keep var/www/html
RUN sed -i 's!/var/www/html!/var/www/html/casino!g' /etc/apache2/sites-available/000-default.conf || true

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
