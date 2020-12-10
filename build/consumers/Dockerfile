FROM php:7.4

RUN mkdir -p /usr/share/man/man1
RUN mkdir -p /.cache/dconf
RUN chmod -R 0777 /.cache
RUN mkdir -p /.config
RUN chmod -R 0777 /.config
RUN apt update && apt install -y systemd
RUN apt-get update && apt-get install -y librabbitmq-dev \
		 libonig-dev \
		 libzip-dev \
         libmcrypt-dev \
         libpng-dev\
         libmemcached-dev \
         libhiredis-dev \
         libssl-dev \
         nghttp2 \
         git \
         cmake \
         nano \
         cron \
         sudo \
#         screen \
         libxml2-dev \
         unixodbc-dev \
         libreoffice --no-install-recommends \
         unzip \
         iputils-ping \
        && apt-get install -y libpq-dev \
        && apt-get install -y gnupg2 \
#        && apt-get install -y vim \
#        && docker-php-ext-install -j$(nproc) mcrypt \
        && pecl install amqp \
        && pecl install memcached \
        && docker-php-ext-enable amqp \
        && docker-php-ext-enable memcached

RUN pecl install -o -f redis \
		&&  rm -rf /tmp/pear \
		&&  docker-php-ext-enable redis

COPY php.ini /usr/local/etc/php/
COPY locale /etc/default/locale

RUN docker-php-ext-install mbstring && docker-php-ext-enable mbstring
RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
# RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
# RUN docker-php-ext-install pgsql && docker-php-ext-enable pgsql
# RUN docker-php-ext-install pdo_pgsql && docker-php-ext-enable pdo_pgsql
RUN docker-php-ext-install gd && docker-php-ext-enable gd
RUN docker-php-ext-install sockets && docker-php-ext-enable sockets
RUN docker-php-ext-install intl && docker-php-ext-enable intl
RUN docker-php-ext-install bcmath && docker-php-ext-enable bcmath
RUN docker-php-ext-install calendar && docker-php-ext-enable calendar

WORKDIR /app/comc
COPY ./start-consumers.sh /app/start-consumers.sh

RUN mkdir -p /app/comc/runtime/cache && chmod -Rf 0777 /app/comc/runtime
RUN mkdir -p /app/comc/gen && chmod -Rf 0777 /app/comc/gen
# установка и подготовка композера
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV container=docker
COPY container.target /etc/systemd/system/container.target
RUN ln -sf /etc/systemd/system/container.target /etc/systemd/system/default.target

COPY cron/* /cron/
COPY cron/root /var/spool/cron/crontabs/
RUN chmod 0600 /var/spool/cron/crontabs/root

COPY ./tmp/rmq.php ../
COPY ./tmp/rmq_credentials.php ../
COPY consumer-guard.service.template /app/consumer-guard.service.template
COPY get-consumer-services.php /app/get-consumer-services.php
RUN cd .. && php get-consumer-services.php > /etc/systemd/system/consumer-guard.service

RUN ln -sf /etc/systemd/system/consumer-guard.service /etc/systemd/system/multi-user.target.wants/consumer-guard.service

COPY comc-consumer@.service /etc/systemd/system/comc-consumer@.service
RUN ln -sf /etc/systemd/system/comc-consumer@.service /etc/systemd/system/multi-user.target.wants/comc-consumer@.service
COPY start-countdowns.sh /app/start-countdowns.sh
COPY comc-countdown.service /etc/systemd/system/comc-countdown.service
RUN ln -sf /etc/systemd/system/comc-countdown.service /etc/systemd/system/multi-user.target.wants/comc-countdown.service


RUN rm -rf /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

#RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
#USER docker
ENTRYPOINT ["/sbin/init"]
CMD ["--log-level=info"]
STOPSIGNAL SIGRTMIN+3