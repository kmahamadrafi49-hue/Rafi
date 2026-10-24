FROM php:8.2-apache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Copy project files
COPY . /var/www/html/
WORKDIR /var/www/html

# Run composer install if composer.json exists in root or casino folder
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; fi
RUN if [ -f "casino/composer.json" ]; then cd casino && composer install --no-dev --optimize-autoloader; cd ..; fi

# Set permissions
RUN chown -R www-data:www-data /var/www/html
