#!/usr/bin/env bash
php artisan migrate --force
exec apache2-foreground
