############################################################################################################################################
# build-lib.sh
# Библиотека содержащая функции для *-dev.sh, ci/ci-*.sh
############################################################################################################################################

# Прервать выполнение скрипта
# $1 - код выхода. Если код не равен 0, то выводится код и сообщение в stderr
# $2 - сообщение. Если сообщение есть, то оно будет выведено в stderr
term(){
  local code=$1
  local msg="$2"
  if [ $code != 0 ] ; then
    echo "ERRCODE: $code"
    [ -n "$msg" ] && echo "$msg" >&2
    exit 1
  fi
}

# Скопировать файлы параметров и подставить параметры, перед сборкой образа
copy_yii_configs() {
  local ret=0
  echo "Start copy config files";
  if [ ! -f "$CONFIG_PARAMS_FILE" ] ; then
    cp "$CONFIG_PARAMS_FILE.example" "$CONFIG_PARAMS_FILE"
    ret=$?
    [ $ret != 0 ] && return $ret
    echo "$CONFIG_PARAMS_FILE copied"
  fi

  if [ ! -f "$CONFIG_RMQ_FILE" ] ; then
    cp "$CONFIG_RMQ_FILE.example" "$CONFIG_RMQ_FILE"
    ret=$?
    [ $ret != 0 ] && return $ret
    echo "$CONFIG_RMQ_FILE copied"
  fi

  if [ ! -f "$CONFIG_DB_PARAMS_FILE" ] ; then
    cp "$CONFIG_DB_PARAMS_FILE.example" "$CONFIG_DB_PARAMS_FILE"
    ret=$?
    [ $ret != 0 ] && return $ret
    sed -i "s/{DB_APP_NAME}/${DB_APP_NAME}/" "$CONFIG_DB_PARAMS_FILE"
    sed -i "s/{DB_APP_USER_NAME}/${DB_APP_USER_NAME}/" "$CONFIG_DB_PARAMS_FILE"
    sed -i "s/{DB_APP_USER_PASSWORD}/${DB_APP_USER_PASSWORD}/" "$CONFIG_DB_PARAMS_FILE"
    echo "Parameters substitution in $CONFIG_DB_PARAMS_FILE done"
  fi
  return $ret
}

# Проверить, передан ли аргумент $1 в списке аргументов
# $1 - строка аргументов, разделенных пробелом
arg_exists(){
  local arglist="$1"
  shift
  while test $# -gt 0
  do
    local arg=$1
    for check_arg in $arglist; do
      if [ "$arg" = "$check_arg" ] ; then
        return 0
      fi
    done
    shift
  done
  return 1
}


# Запущены ли контейнеры comc_db и comc_fpm.
# Если какой-то контейнер не запущен, вернуть 1
containers_are_running(){
  db_cont=$(docker ps -f 'name=comc_db' --format '{{.Names}}')
  fpm_cont=$(docker ps -f 'name=comc_fpm' --format '{{.Names}}')
  if [ "$db_cont" != 'comc_db' ] || [ "$fpm_cont" != 'comc_fpm' ] ; then
    return 1
  fi
  return 0
}

# Применить миграции
apply_migrations(){
  docker exec comc_fpm sh -c '/var/www/sites/comc/yii migrate --interactive=0'
}

# Запуск миграций
# $1 - true - миграции к tempdb
migrate_db()
{
  local ret=0
  local tempdb=$1
  echo "Creating DB by applying migrations..."
  containers_are_running
  if [ $? != 0 ] ; then
    # если контейнеры не запущены, надо их создать
    if [ $tempdb ] ; then
      echo 'Starting service db on tempdb volume...'
    fi
    docker-compose up -d
    ret=$?
    [ $ret != 0 ] && return $ret
    # ждем, когда сервисы поднимутся
    sleep 10
  fi
  # запуск миграций
  apply_migrations
  ret=$?
  return $ret
  # docker-compose stop #down
}

# Построить образы.
# $1 - использовать кэш - true
build_images()
{
  local nocache=$1
  if [ $nocache ]; then
    echo "Building with no cache..."
    docker-compose build --no-cache
  else
    echo "Building with cache..."
    docker-compose build
  fi
  return $?
}

# Смонтирован ли том
is_volume_mounted(){
  local vol_name=$1
  volume_mounts_tempdb=$(docker inspect --format '{{range .Mounts}}{{.Name}}{{end}}' newcarmoney_db)
  [ "$volume_mounts_tempdb" = "$vol_name" ] && return 0
  return 1
}

# Скопировать файлы
# $1 - временная папка откуда копировать
# $2 - файл
copy_files(){
  local ret=0
  local tmp_dir_path=$1
  local src_files=$2
  echo "tmp_dir_path=$tmp_dir_path"
  mkdir -p $tmp_dir_path
  cp $src_files $tmp_dir_path
  ret=$?
  if [ $ret != 0 ] ; then
    echo "Copy of file $src_files failed" >&2
    return $ret
  fi
  echo "File $src_files copied"
  return 0
}

# Скопировать файлы package.json и package-lock.json
copy_npm_package_files(){
  copy_files $NUXT_TMP_PATH './project/front/package.json'
  [ $? != 0 ] && return 1
  copy_files $NUXT_TMP_PATH './project/front/package-lock.json'
  [ $? != 0 ] && return 1
  return 0
}

# Создать том tmpfs докера
# $1 - Название тома
create_docker_temp_volume(){
  local vol_name=$1
  docker volume create -o type=tmpfs -o device=tmpfs $vol_name
}

# Удалить контейнер докер
# $1 - название контейнера
rm_container(){
  local cont=$(docker ps -qaf "name=$1")
  if [ -n "$cont" ] ; then
    echo "Removing container $1..."
    docker rm -f $cont
  fi
}

# Удалить том по имени
# $1 - название тома
rm_volume(){
  local vol=$(docker volume ls -qf "name=$1")
  if [ -n "$vol" ] ; then
    echo "Removing volume $1..."
    docker volume rm $vol
  fi
}

# Удалить сеть
# $1 - имя сети
rm_network(){
  local network=$1
  local network_id=$(docker network ls -qf name=$network)
  echo "Found network $network with ID $network_id"
  if [ -n "$network_id" ] ; then
    echo "Removing network $network..."
    docker network rm $network_id
  fi
}


# Существует ли образ докер
# $1 - название образа
docker_image_exists(){
    local name="$1"
    echo $name
    shift
    docker images --format '{{.Repository}}'|grep -qi "$name"
    return $1
}

# Удалить образ докера, если он существует
# $1 - название образа
rm_docker_image(){
  local name="$1"
  docker_image_exists "$name" && docker rmi "$name"
}