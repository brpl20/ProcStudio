#!/usr/bin/env bash
set -eu

readonly ENV_FILE="${1}"
readonly TEMPLATE_PATH="${2}"
readonly OUT_PATH="${3}"

if [ -z "${ENV_FILE}" ] || [ -z "${TEMPLATE_PATH}" ] || [ -z "${OUT_PATH}" ]; then
  printf 'Usage: %s <ENV_FILE> <TEMPLATE_PATH> <OUT_PATH>\n' "$0" >&2
  exit 1
fi

if [ -f "${ENV_FILE}" ]; then
  set -a
  . "${ENV_FILE}"
  set +a
else
  echo -e "Falta o arquivo .env em '${ENV_DIR}'\n" >&2
  exit 127
fi

: "${REDIS_HOST:?}"
: "${REDIS_PORT:?}"

export REDIS_HOST REDIS_PORT

envsubst '$REDIS_HOST $REDIS_PORT' < "${TEMPLATE_PATH}" > "${OUT_PATH}"
exit 0
