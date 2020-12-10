#!/bin/sh
############################################################################################################################################
# build-dev.sh
# Строит образы Docker для разработки: ./build/build-dev.sh [-b] [-d] [-m] [-n] [-h] [--download]
############################################################################################################################################

WORKDIR="$(basename $(pwd))"
if [ "$WORKDIR" != "build" ] ; then
  . ./build/.env-devel
  . ./build/build-lib.sh
fi

echo "Building images..."

# Показать справку для build-dev.sh
show_help()
{
    echo "Использование: ./build-dev.sh [КЛЮЧ]"
    echo "Строит проект docker"
    echo "--help,     -h Показать эту справку"
    echo "--build,    -b Запустить построение образов"
    echo "--init,     -i Инициализировать конфиги"
    echo "--dry-run,  -d Просмотр конфигурации docker-compose для отладки"
    echo "--migrate,  -m Применить миграции"
    echo "--no-cache, -n При построении образов Docker не использовать кэш"
}

if [ "$#" -eq 0 ] ; then
  show_help
  exit 1
fi

for var in "$@"
do
  case "$var" in
  --build|-b)
    build=true
    ;;
  --no-cache|-n|--nocache)
    nocache=true
    ;;
  --migrate|-m)
    migrate=true
    ;;
  --init|-i)
    init=true
    ;;
  --dry-run|-d|--dryrun)
    dryrun=true
    ;;
  --download)
    download=true
    ;;
  --help|-h|-\?)
    show_help
    exit 0
    ;;
  *)
    echo "Invalid param: $var" >&2
    show_help
    exit 1
    ;;
  esac
done

if [ $dryrun ] ; then
  echo "Dry run."
  docker-compose config
  exit 0
fi

if [ $init ] ; then
# скопировать конфиги YII для инициализации
  copy_yii_configs
  term $?
fi

if [ $build ] ; then
  build_images $nocache
  term $?
  [ $migrate ] && migrate_db
  docker-compose stop
fi