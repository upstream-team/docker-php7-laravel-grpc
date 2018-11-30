#!/usr/bin/env bash
php artisan migrate
php artisan db:seed
php artisan passport:install --force
php artisan storage:link
nginx &
php-fpm
