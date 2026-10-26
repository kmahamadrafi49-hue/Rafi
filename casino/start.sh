#!/usr/bin/env bash
php artisan config:clear
php artisan cache:clear
php artisan migrate --force
chmod -R 777 storage bootstrap/cache
exec apache2-foreground
