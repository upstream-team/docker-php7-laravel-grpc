#!/usr/bin/env bash
composer install
php artisan migrate
php artisan db:seed
php artisan passport:keys --force
php artisan storage:link
nginx &
php-fpm
