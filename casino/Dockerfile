FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

# పాత index.php ని తొలగించి, రూట్ నుంచే లారావెల్ రన్ అయ్యేలా సరికొత్త index.php ని సృష్టిస్తుంది
RUN rm -f /var/www/html/index.php \
    && echo '<?php' > /var/www/html/index.php \
    && echo 'define(\'LARAVEL_START\', microtime(true));' >> /var/www/html/index.php \
    && echo 'if (file_exists($maintenance = __DIR__.\'/storage/framework/maintenance.php\')) {' >> /var/www/html/index.php \
    && echo '    require $maintenance;' >> /var/www/html/index.php \
    && echo '}' >> /var/www/html/index.php \
    && echo 'require __DIR__.\'/vendor/autoload.php\';' >> /var/www/html/index.php \
    && echo '$app = require_once __DIR__.\'/bootstrap/app.php\';' >> /var/www/html/index.php \
    && echo '$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);' >> /var/www/html/index.php \
    && echo '$response = $kernel->handle($request = Illuminate\Http\Request::capture());' >> /var/www/html/index.php \
    && echo '$response->send();' >> /var/www/html/index.php \
    && echo '$kernel->terminate($request, $response);' >> /var/www/html/index.php

RUN composer install --no-dev --optimize-autoloader --no-scripts

RUN a2enmod rewrite headers

RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf \
    && echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    SetEnvIf X-Forwarded-Proto "https" HTTPS-on' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    <Directory /var/www/html>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

RUN echo '#!/bin/bash' > /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \
    && echo 'php artisan cache:clear' >> /start.sh \
    && echo 'apache2-foreground' >> /start.sh \
    && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
