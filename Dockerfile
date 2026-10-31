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

# Remove default nginx site config to prevent conflicts
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Install PHP dependencies bypassing platform requirements
RUN composer install --no-dev --no-scripts --optimize-autoloader --ignore-platform-reqs

# Set permissions for storage, bootstrap cache, and public
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public

# Copy custom Nginx configuration directly to conf.d
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 10000

# Start Nginx and PHP-FPM together
CMD php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan config:cache && php artisan route:cache && php artisan view:cache && php-fpm -D && nginx -g "daemon off;"




