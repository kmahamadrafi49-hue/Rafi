FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

RUN cat << 'EOF' > /var/www/html/index.php
<?php
define('LARAVEL_START', microtime(true));
if (file_exists($maintenance = __DIR__.'/storage/framework/maintenance.php')) {
    require $maintenance;
}
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);
$response->send();
$kernel->terminate($request, $response);
EOF

RUN cat << 'EOF' > /var/www/html/server.php
<?php
$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)
);
require_once __DIR__.'/index.php';
EOF

RUN composer install --no-dev --optimize-autoloader --no-scripts

RUN a2enmod rewrite headers

RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf \
    && echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DirectoryIndex server.php index.php' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    SetEnvIf X-Forwarded-Proto "https" HTTPS-on' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    <Directory /var/www/html>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Start script creation
RUN echo '#!/bin/bash' > /start.sh \
    && echo 'mkdir -p /var/www/html/storage/logs' >> /start.sh \
    && echo 'touch /var/www/html/storage/logs/laravel.log' >> /start.sh \
    && echo 'mkdir -p /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views /var/www/html/storage/framework/cache' >> /start.sh \
    && echo 'chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache' >> /start.sh \
    && echo 'chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache' >> /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \
    && echo 'php artisan cache:clear' >> /start.sh \
    && echo 'apache2-foreground' >> /start.sh

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
