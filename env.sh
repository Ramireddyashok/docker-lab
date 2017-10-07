#!/bin/sh

DATE=`date +%Y%m%d`
ENV="development"         # (development / production)
REMOVE_CACHE="0"          # (0 = using cache, 1 = no-cache)
RECREATE_CONTAINER="0"    # (0 = using cache, 1 = force recreate container)

CONTAINER_PRODUCTION="base base-consul consul mariadb mongodb nginx nodejs postgresql redis ruby application"
CONTAINER_DEVELOPMENT="consul mongodb nodejs ruby"

build_env() {
  if [ "$ENV" = "development" ]
  then
    BUILD_ENV="$CONTAINER_DEVELOPMENT"
  else
    BUILD_ENV="$CONTAINER_PRODUCTION"
  fi
}

cache() {
  if [ "$REMOVE_CACHE" = "0" ]
  then
    CACHE=""
  else
    CACHE=" --no-cache"
  fi
}

recreate() {
  if [ "$RECREATE_CONTAINER" = "0" ]
  then
    RECREATE=""
  else
    RECREATE=" --force-recreate"
  fi
}

loop_build() {
  for CONTAINER in $BUILD_ENV
  do
    echo ""
    echo ">>> docker-compose build $CONTAINER"
    echo "-----------------------------------------------------------"
    docker-compose build $CONTAINER
  done
}

build_all() {
  docker-compose up $RECREATE $BUILD_ENV
}

main() {
  cache
  recreate
  build_env
  echo "-----------------------------------------------------------"
  echo "### docker-compose exec $CACHE $BUILD_ENV"
  echo "-----------------------------------------------------------"
  loop_build
  echo ""
  echo "-----------------------------------------------------------"
  echo "### docker-compose up $RECREATE $BUILD_ENV"
  echo "-----------------------------------------------------------"
  build_all
}

### START HERE ###
main