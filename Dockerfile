FROM php:8.4-fpm


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
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set permissions for storage and bootstrap cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Overwrite Nginx default site configuration directly to point to public folder and port 10000
RUN echo "server { \
    listen 10000; \
    root /var/www/html/public; \
    index index.php index.html index.htm; \
    server_name _; \
    location / { \
        try_files \$uri \$uri/ /index.php?\$query_string; \
    } \
    location ~ \.php\$ { \
        include fastcgi_params; \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name; \
    } \
}" > /etc/nginx/sites-available/default

EXPOSE 10000

# Start Nginx and PHP-FPM together with .env creation and cache clearing
CMD php -r "if (!file_exists('.env')) copy('.env.example', '.env');" && \
    php artisan key:generate --force && \
    php artisan config:clear && \
    php artisan cache:clear && \
    service nginx start && php-fpm
