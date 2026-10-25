FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . /var/www/html/

WORKDIR /var/www/html/casino

RUN composer install --no-dev --optimize-autoloader --no-scripts

RUN a2enmod rewrite headers

RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf \
    && echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DocumentRoot /var/www/html/casino/public' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    SetEnvIf X-Forwarded-Proto "https" HTTPS-on' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    <Directory /var/www/html/casino/public>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

RUN echo '#!/bin/bash' > /start.sh \
    && echo 'chown -R www-data:www-data /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache' >> /start.sh \
    && echo 'chmod -R 775 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache' >> /start.sh \
    && echo 'cd /var/www/html/casino' >> /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \
    && echo 'php artisan cache:clear' >> /start.sh \
    && echo 'apache2-foreground' >> /start.sh \
    && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
