FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

RUN composer install --no-dev --optimize-autoloader --no-scripts

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache

RUN a2enmod rewrite headers

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -s 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -s 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo '#!/bin/bash' > /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \n\
    && echo 'php artisan cache:clear' >> /start.sh \n\
    && echo 'php artisan route:clear' >> /start.sh \n\
    && echo 'php artisan migrate --force || true' >> /start.sh \n\
    && echo 'apache2-foreground' >> /start.sh

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
