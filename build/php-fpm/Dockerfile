FROM php:7.4-fpm

RUN apt-get update && apt-get install -y   librabbitmq-dev \
		libjpeg-dev \
		libpng-dev \
		libzip-dev \
		libxml2-dev \
		libc-client-dev \
		libkrb5-dev \
		libldap2-dev \
		libzmq3-dev \
		zlib1g-dev \
		libonig-dev \
		libmcrypt-dev \
		libmemcached-dev \
		libhiredis-dev \
		libssl-dev \
		nghttp2 \
		git \
		cmake \
		nano \
		sudo \
		screen \
		unixodbc-dev \
		unzip \
		libpq-dev \
		gnupg2 \
        vim \
        mc \
		&& apt-get install -y --no-install-recommends curl \
		&& pecl install amqp \
		&& docker-php-ext-enable amqp \
		&& pecl install mcrypt-1.0.3

RUN pecl install -o -f redis \
		&&  rm -rf /tmp/pear \
		&&  docker-php-ext-enable redis

# Install php-zmq
RUN cd /usr; \
    curl -fSL https://github.com/zeromq/php-zmq/archive/e0db82c3286da81fa8945894dd10125a528299e4.tar.gz -o php-zmq.tar.gz; \
    tar -zxf php-zmq.tar.gz; \
    cd php-zmq*; \
    phpize && ./configure; \
    make; \
    make install; \
    cd .. && rm -rf php-zmq*

COPY php.ini /usr/local/etc/php/

RUN docker-php-ext-install mbstring; \
	docker-php-ext-enable mbstring; \
	docker-php-ext-install mysqli; \
	docker-php-ext-enable mysqli; \
	docker-php-ext-install sockets; \
	docker-php-ext-enable sockets; \
	docker-php-ext-install intl; \
	docker-php-ext-enable intl; \
	docker-php-ext-install bcmath; \
	docker-php-ext-enable bcmath; \
	docker-php-ext-enable mcrypt; \
	docker-php-ext-install pdo_mysql; \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd; \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install imap; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/; \
    docker-php-ext-install ldap; \
    docker-php-ext-install exif; \
    docker-php-ext-enable zmq; \
    docker-php-ext-install zip; \
    docker-php-ext-enable zip

WORKDIR /var/www/html
#RUN mkdir -p /var/www/sites/comc/runtime/cache && chmod -Rf 0777 /var/www/sites/comc/runtime

# установка и подготовка композера
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#RUN rm -rf /etc/localtime
#RUN ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime