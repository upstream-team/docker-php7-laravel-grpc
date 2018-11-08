FROM hitalos/laravel:latest

ONBUILD ENV GITHUB_KEY               ""
ONBUILD ENV COMPOSER_ALLOW_SUPERUSER 1

RUN pecl install grpc
RUN pecl install protobuf

# install protoc
RUN mkdir -p /tmp/protoc && \
    curl -L https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip > /tmp/protoc/protoc.zip && \
    cd /tmp/protoc && \
    unzip protoc.zip && \
    cp /tmp/protoc/bin/protoc /usr/local/bin && \
    cd /tmp && \
    rm -r /tmp/protoc && \
    docker-php-ext-enable grpc && \
    docker-php-ext-enable protobuf

# PHP protoc plugin
RUN mkdir -p /tmp/php-protoc && \
    git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc /tmp/php-protoc && \
    cd /tmp/php-protoc && \
    git submodule update --init && \
    make grpc_php_plugin

# install vendor
RUN mkdir -p /root/.composer
RUN echo "{\"github-oauth\": {\"github.com\": \"${GITHUB_KEY}\"}}" > /root/.composer/auth.json
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN php /usr/bin/composer config -g github-oauth.github.com ${GITHUB_KEY}

ONBUILD COPY . /var/www
ONBUILD RUN php /usr/bin/composer install
