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

# Permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache

# Create a startup script to clear cache and start Apache dynamically using environment variables
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'cd /var/www/html/casino' >> /start.sh && \
    echo 'php artisan config:clear' >> /start.sh && \
    echo 'php artisan cache:clear' >> /start.sh && \
    echo 'apache2-foreground' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
