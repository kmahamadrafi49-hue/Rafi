#!/usr/bin/env bash
set -o errexit

# 1. Install composer dependencies
composer install --no-dev --optimize-autoloader

# 2. Automated Python patch for PHP 8.1 ReflectionFunction issue
python3 -c "
path = 'vendor/laravel/framework/src/Illuminate/Container/Container.php'
with open(path, 'r') as f:
    content = f.read()
import re
content = re.sub(r'protected function getClassForCallable\s*\([^)]*\)\s*\{.*?\}', '''    protected function getClassForCallable(\$callback)
    {
        return false;
    }''', content, flags=re.DOTALL)
with open(path, 'w') as f:
    f.write(content)
print('Render Build Patch Applied Successfully!')
"

# 3. Run database migrations automatically to create the 'settings' and other tables
php artisan migrate --force

# 4. Clear and cache Laravel configuration
php artisan config:clear
php artisan config:cache
php artisan route:clear
