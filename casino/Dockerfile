FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

RUN mkdir -p /var/www/html/public

RUN cat << 'EOF' > /var/www/html/public/index.php
<?php
define('LARAVEL_START', microtime(true));
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);
$response->send();
$kernel->terminate($request, $response);
EOF

RUN php << 'PHP'
<?php
$file = '/var/www/html/config/database.php';
if(file_exists($file)) {
    $content = file_get_contents($file);
    if(strpos($content, "'mysql'") !== false) {
        $content = str_replace("'mysql' => [", "'mysql1' => [", $content);
        file_put_contents($file, $content);
    }
}
PHP

RUN composer install --no-dev --optimize-autoloader --no-scripts

RUN a2enmod rewrite headers

RUN echo '<VirtualHost *:80> \n\
    ServerAdmin webmaster@localhost \n\
    DocumentRoot /var/www/html/public \n\
    DirectoryIndex index.php \n\
    <Directory /var/www/html/public> \n\
        Options Indexes FollowSymLinks \n\
        AllowOverride All \n\
        Require all granted \n\
    </Directory> \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log \n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined \n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

RUN echo '#!/bin/bash' > /start.sh \
    && echo 'mkdir -p /var/www/html/storage/logs' >> /start.sh \
    && echo 'touch /var/www/html/storage/logs/laravel.log' >> /start.sh \
    && echo 'mkdir -p /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views /var/www/html/storage/framework/cache' >> /start.sh \
    && echo 'chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache' >> /start.sh \
    && echo 'chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache' >> /start.sh \
    && echo 'php artisan cache:clear' >> /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \
    && echo 'php artisan migrate --force' >> /start.sh \
    && echo 'apache2-foreground' >> /start.sh

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
