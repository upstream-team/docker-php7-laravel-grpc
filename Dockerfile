FROM hitalos/laravel:latest

ONBUILD ENV GITHUB_KEY               ""
ONBUILD ENV COMPOSER_ALLOW_SUPERUSER 1

# install protoc
RUN apk update && apk add protobuf

RUN pecl install grpc
RUN pecl install protobuf

# enable php extension
RUN docker-php-ext-enable grpc && \
    docker-php-ext-enable protobuf

# PHP protoc plugin
RUN mkdir -p /usr/src/php-protoc && \
    git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc /usr/src/php-protoc && \
    cd /usr/src/php-protoc && \
    git submodule update --init && \
    make grpc_php_plugin

# install vendor
RUN mkdir -p /root/.composer
RUN echo "{\"github-oauth\": {\"github.com\": \"${GITHUB_KEY}\"}}" > /root/.composer/auth.json
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN php /usr/bin/composer config -g github-oauth.github.com ${GITHUB_KEY}

ONBUILD COPY . /var/www
ONBUILD RUN php /usr/bin/composer install
