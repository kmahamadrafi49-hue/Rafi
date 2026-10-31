FROM php:8.2-fpm

# Install system dependencies and Nginx
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    nginx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Install PHP dependencies bypassing platform requirements to avoid version errors
RUN composer install --no-dev --scripts --optimize-autoloader --ignore-platform-reqs

# Set permissions for storage and bootstrap cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Nginx root to point to Laravel's public directory and use Render's PORT (10000)
RUN sed -i 's|root /var/www/html;|root /var/www/html/public;|g' /etc/nginx/sites-available/default
RUN sed -i 's|listen 80 default_server;|listen 10000 default_server;|g' /etc/nginx/sites-available/default
RUN sed -i 's|listen [::]:80 default_server;|listen [::]:10000 default_server;|g' /etc/nginx/sites-available/default

EXPOSE 10000

# Start Nginx and PHP-FPM together along with cache clearing
CMD php artisan config:clear && php artisan cache:clear && service nginx start && php-fpm
