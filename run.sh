#!/bin/bash
set -e


# Определяем директорию скрипта
SELF=$(readlink /proc/$$/fd/255)
SELFDIR=$(dirname $SELF)

cd $SELFDIR

# Загрузка необходимых файлов, если их нет
REQUIRED="docker-compose.yml app.env rpc.env"
for REQ in $REQUIRED; do
    test -s $REQ || curl -s -L https://raw.githubusercontent.com/dzholik/fm/refs/heads/master/$REQ -o $REQ
done

# Установка переменной окружения для совместимости API
export DOCKER_API_VERSION=1.45

# Увеличиваем таймаут для docker-compose
export COMPOSE_HTTP_TIMEOUT=300

# Проверка наличия docker или docker-compose
# Сначала пытаемся использовать плагин `docker compose`, если он доступен.
# В противном случае падаем назад на классический `docker-compose`.
COMPOSE_CMD=""
if command -v docker &> /dev/null; then
    # проверяем, поддерживает ли текущая команда `docker compose`
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose -p sprutio"
    else
        # docker присутствует, но плагин compose отсутствует
        if command -v docker-compose &> /dev/null; then
            COMPOSE_CMD="docker-compose -p sprutio"
        fi
    fi
fi

# если до сих пор не удалось определить команду, пробуем найти только docker-compose
if [ -z "$COMPOSE_CMD" ] && command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose -p sprutio"
fi

if [ -z "$COMPOSE_CMD" ]; then
    echo "Neither 'docker compose' plugin nor 'docker-compose' binary found."
    echo "Please install docker-compose or upgrade Docker to a release with the compose plugin."
    exit 1
fi

# Запуск контейнеров
if [ $# -eq 0 ]; then
    exec ${COMPOSE_CMD} up -d
else
    exec ${COMPOSE_CMD} "$@"
fi

# EOF
