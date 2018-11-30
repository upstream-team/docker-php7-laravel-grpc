FROM php:7-fpm

WORKDIR /var/www
EXPOSE 443

RUN apt-get update && apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
        libldb-dev \
        unzip \
        curl \
        mysql-client \
        zip \
        libjpeg-dev \
        libgif-dev \
        apt-utils \
        zlib1g-dev \
        && docker-php-ext-install -j$(nproc) pdo_mysql mysqli \
        && docker-php-ext-install zip \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
        && docker-php-ext-install -j$(nproc) gd

# install protobuf
RUN cd /tmp && curl -OL https://github.com/google/protobuf/releases/download/v3.2.0/protoc-3.2.0-linux-x86_64.zip \
            && unzip protoc-3.2.0-linux-x86_64.zip -d protoc3 \
            && mv protoc3/bin/* /usr/local/bin/ \
            && mv protoc3/include/* /usr/local/include/

RUN pecl install grpc
RUN pecl install protobuf

# enable php extension
RUN docker-php-ext-enable grpc && \
    docker-php-ext-enable protobuf

# install nginx
RUN apt update -y && apt install -y nginx
COPY ./nginx.vhost.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /run/nginx

# copy crt
RUN mkdir /crt
COPY ./nginx.crt /crt/nginx.crt
COPY ./nginx.key /crt/nginx.key

# PHP protoc plugin
# ONLY FOR DEV
#RUN mkdir -p /tmp/php-protoc && \
#    git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc /tmp/php-protoc && \
#    cd /tmp/php-protoc && \
#    git submodule update --init && \
#    make grpc_php_plugin && \
#    mkdir /opt && \
#    mv /tmp/php-protoc/bins/opt/* /opt && \
#    rm -Rf /tmp/php-protoc

COPY . /var/www

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
