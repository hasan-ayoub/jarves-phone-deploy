#!/bin/bash
set -e
APP=/var/www/app
cd $APP
DB_TYPE=${DB_TYPE:-sqlite}
CONSOLE="php app/console --env=dev"

# Cloud hosts (Render/Railway/Fly) give a $PORT
if [ -n "$PORT" ]; then
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf
fi

if [ "$DB_TYPE" = "mysql" ]; then
  DRIVER=mysql; DSN="mysql:host=${DB_HOST};dbname=${DB_NAME}"; MARK=$APP/data/.installed
else
  DRIVER=sqlite; DSN="sqlite:$APP/data/jarves.sq3"; MARK=$APP/data/.installed
  DB_HOST=localhost; DB_NAME=jarves; DB_USER=; DB_PASSWORD=
fi

cp docker/../app/config/parameters.yml app/config/parameters.yml.run 2>/dev/null || true
sed -i "s|__DB_DRIVER__|${DRIVER}|g; s|__DB_DSN__|${DSN}|; s|__DB_HOST__|${DB_HOST}|g; s|__DB_NAME__|${DB_NAME}|; s|__DB_USER__|${DB_USER}|; s|__DB_PASS__|${DB_PASSWORD}|" app/config/parameters.yml

mkdir -p data app/cache app/logs web/bundles
chown -R www-data:www-data data app/cache app/logs web
rm -rf app/cache/*

if [ ! -f "$MARK" ]; then
  echo ">>> First run: creating database + demo data"
  [ "$DRIVER" = "sqlite" ] && touch data/jarves.sq3 && chmod 666 data/jarves.sq3
  $CONSOLE propel:model:build
  $CONSOLE propel:migration:diff
  $CONSOLE propel:migration:up
  $CONSOLE jarves:install:demo "${SITE_HOST:-localhost}" "${SITE_PATH:-/}"
  $CONSOLE assets:install web
  chown -R www-data:www-data data app/cache app/logs web
  touch "$MARK"
  echo ">>> Done"
fi

exec "$@"
