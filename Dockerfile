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

# Create a temporary sqlite database file so composer install scripts and package discovery pass successfully during build
RUN touch database.sqlite && \
    echo "APP_ENV=production" > .env && \
    echo "APP_DEBUG=true" >> .env && \
    echo "APP_KEY=base64:X7v6Q8m2K9s3L5p1R4w0N8x2Z6y1H3j5F7d9G2b4V1o=" >> .env && \
    echo "DB_CONNECTION=sqlite" >> .env && \
    echo "DB_DATABASE=/var/www/html/database.sqlite" >> .env && \
    echo "SESSION_DRIVER=file" >> .env && \
    echo "CACHE_DRIVER=file" >> .env

# Run composer install with scripts so Vanguard repository bindings are correctly generated
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set absolute permissions for storage and bootstrap cache
RUN mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache storage/logs && \
    chmod -R 777 storage bootstrap/cache database.sqlite && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

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

# Start Nginx and PHP-FPM with live PostgreSQL DATABASE_URL mapping at runtime
CMD php -r "file_put_contents('.env', 'APP_ENV=production\nAPP_DEBUG=true\nAPP_KEY=base64:X7v6Q8m2K9s3L5p1R4w0N8x2Z6y1H3j5F7d9G2b4V1o=\nDB_CONNECTION=pgsql\nDATABASE_URL=' . getenv('DATABASE_URL') . '\nSESSION_DRIVER=file\nCACHE_DRIVER=file\n');" && \
    chmod -R 777 storage bootstrap/cache && \
    php artisan config:clear && \
    php artisan cache:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    service nginx start && php-fpm
