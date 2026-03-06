#!/bin/bash
set -e


# Определяем директорию скрипта
SELF=$(readlink /proc/$$/fd/255)
SELFDIR=$(dirname $SELF)

cd $SELFDIR

# Загрузка необходимых файлов, если их нет
REQUIRED="docker-compose.yml app.env rpc.env"
for REQ in $REQUIRED; do
    test -s $REQ || curl -s -L https://raw.githubusercontent.com/LTD-Beget/sprutio/master/$REQ -o $REQ
done

# Установка переменной окружения для совместимости API
export DOCKER_API_VERSION=1.45

# Увеличиваем таймаут для docker-compose
export COMPOSE_HTTP_TIMEOUT=300

# Проверка наличия современной версии docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose не найден. Пожалуйста, установите его:"
    echo "sudo apt-get install docker-compose"
    exit 1
fi

# Используем стандартную команду docker-compose
COMPOSE_CMD="docker compose -p sprutio"

# Запуск контейнеров
if [ $# -eq 0 ]; then
    exec ${COMPOSE_CMD} up -d
else
    exec ${COMPOSE_CMD} "$@"
fi

# EOF
