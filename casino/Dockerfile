FROM php:8.2-apache

RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libonig-dev

RUN docker-php-ext-install pdo pdo_mysql mysqli zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

# కాంపోజర్ డిపెండెన్సీస్ క్యాసినో ఫోల్డర్ లోపల ఇన్‌స్టాల్ అవ్వాలి
RUN cd casino && composer install --no-dev --optimize-autoloader --no-scripts

# స్టోరేజ్ మరియు పర్మిషన్స్ సెట్ చేయడం
RUN mkdir -p /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache \
    && chmod -R 777 /var/www/html/casino/storage /var/www/html/casino/bootstrap/cache

RUN a2enmod rewrite headers

# అపాచీ డాక్యుమెంట్ రూట్ నేరుగా casino/public కి పాయింట్ చేయాలి
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf \
    && echo '     ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     DocumentRoot /var/www/html/casino/public' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     SetEnvIf X-Forwarded-Proto "https" HTTPS-on' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     <Directory /var/www/html/casino/public>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '         Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf \
    && echo '         AllowOverride All' >> /etc/apache2/sites-available/000-default.conf \
    && echo '         Require all granted' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     </Directory>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf \
    && echo '     CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# స్టార్టప్ స్క్రిప్ట్ (క్యాసినో ఫోల్డర్లోకి వెళ్లి మైగ్రేషన్ మరియు క్యాచే క్లియర్ చేస్తుంది)
RUN echo '#!/bin/bash' > /start.sh \
    && echo 'cd /var/www/html/casino' >> /start.sh \
    && echo 'chown -R www-data:www-data storage bootstrap/cache' >> /start.sh \
    && echo 'chmod -R 777 storage bootstrap/cache' >> /start.sh \
    && echo 'php artisan config:clear' >> /start.sh \
    && echo 'php artisan cache:clear' >> /start.sh \
    && echo 'php artisan migrate --force' >> /start.sh \
    && echo 'apache2-foreground' >> /start.sh \
    && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
