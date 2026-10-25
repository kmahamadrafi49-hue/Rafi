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

# Set working directory to casino
WORKDIR /var/www/html/casino

# Run composer install
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Configure Apache VirtualHost properly
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/casino/public\n\
    DirectoryIndex index.php index.html\n\
    <Directory /var/www/html/casino/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Fix Laravel redirect loop by adding RewriteBase to .htaccess
RUN if [ -f "/var/www/html/casino/public/.htaccess" ]; then \
        sed -i '/RewriteEngine On/a RewriteBase /' /var/www/html/casino/public/.htaccess; \
    fi

# Create a startup script to fix permissions and clear cache dynamically at runtime
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'chown -R www-data:www-data /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache' >> /start.sh && \
    echo 'chmod -R 775 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache' >> /start.sh && \
    echo 'cd /var/www/html/casino' >> /start.sh && \
    echo 'php artisan config:clear' >> /start.sh && \
    echo 'php artisan cache:clear' >> /start.sh && \
    echo 'apache2-foreground' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
