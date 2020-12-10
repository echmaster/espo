#!/bin/sh
############################################################################################################################################
# start.sh
# Запускает docker-compose: ./build/start.sh [-b] [-m]
############################################################################################################################################

. ./build/.env-devel
. ./build/build-lib.sh

echo "Starting dev containers..."
echo "Running directory:" && pwd
mkdir "./build/consumers/tmp"
cp ./project/config/rmq.php ./build/consumers/tmp/
cp ./project/config/rmq_credentials.php ./build/consumers/tmp/


# создание образов
arg_exists '--build -b' "$@"
[ $? = 0 ] && build=true
if [ $build ] ; then
  # построить
  ./build/build-dev.sh --build
fi

# миграции
arg_exists '--migrate -m' "$@"
[ $? = 0 ] && migrate=true
if [ $migrate ] ; then
  # применить
  migrate_db
fi

# запустить
arg_exists '--force-recreate' "$@"
[ $? = 0 ] && force_recreate=true
if [ $force_recreate ] ; then
  docker-compose up -d --force-recreate
else
  docker-compose up -d
fi
docker exec -i comc_consumers sh -c 'cd /cron/ && ./start-services.sh'
docker exec -i comc_consumers sh -c 'composer install'

#for i in $(docker ps|grep newcarmoney|awk '{print $1}'); do
#  docker logs $i;
#done