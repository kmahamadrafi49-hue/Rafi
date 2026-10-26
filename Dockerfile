FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY casino/ /var/www/html/

RUN composer install --working-dir=/var/www/html --no-dev --optimize-autoloader --no-scripts

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache

RUN a2enmod rewrite headers

RUN echo '<VirtualHost *:80> \n\
    ServerAdmin webmaster@localhost \n\
    DocumentRoot /var/www/html/public \n\
    DirectoryIndex index.php index.html \n\
    <Directory /var/www/html/public> \n\
        Options Indexes FollowSymLinks \n\
        AllowOverride All \n\
        Require all granted \n\
    </Directory> \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log \n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined \n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

RUN echo '#!/bin/bash' > /start.sh \n\
    && echo 'php artisan config:clear' >> /start.sh \n\
    && echo 'php artisan cache:clear' >> /start.sh \n\
    && echo 'php artisan route:clear' >> /start.sh \n\
    && echo 'php artisan migrate --force || true' >> /start.sh \n\
    && echo 'apache2-foreground' >> /start.sh

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
