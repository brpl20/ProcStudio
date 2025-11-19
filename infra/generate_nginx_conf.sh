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
  echo -e "Falta o arquivo .env em '${ENV_FILE}'\n" >&2
  exit 127
fi

: "${FLASK_PORT_START:?}"
: "${FLASK_PORT_END:?}"
: "${PORT:?}"

UPSTREAM_SERVERS=""
p=${FLASK_PORT_START}
while [ "$p" -le "${FLASK_PORT_START}" ]; do
  UPSTREAM_SERVERS=$(printf '%sserver %s:%s;\n' "${UPSTREAM_SERVERS}" "${NGINX_LOCALHOST}" "${p}")
  p=$((p + 1))
done

CF4=""
CF6=""
if command -v curl >/dev/null 2>&1; then
  CF4=$(curl -fsSL https://www.cloudflare.com/ips-v4 || true )
  CF6=$(curl -fsSL https://www.cloudflare.com/ips-v6 || true )
elif command -v wget >/dev/null 2>&1; then
  CF4=$(wget -qO- https://www.cloudflare.com/ips-v4 || true )
  CF6=$(wget -qO- https://www.cloudflare.com/ips-v6 || true )
fi

CLOUDFLARE_IPS_FIREWALL=""
for ip in $(printf '%s\n%s\n' "${CF4}" "${CF6}" | awk 'NF'); do
  CLOUDFLARE_IPS_FIREWALL=$(printf '%sallow %s;\n' "${CLOUDFLARE_IPS_FIREWALL}" "${ip}")
done
CLOUDFLARE_IPS_FIREWALL=$(printf '%sallow 127.0.0.1;\n' "${CLOUDFLARE_IPS_FIREWALL}")

CLOUDFLARE_REAL_IP=""
for ip in $(printf '%s\n%s\n' "${CF4}" "${CF6}" | awk 'NF'); do
  CLOUDFLARE_REAL_IP=$(printf '%sset_real_ip_from %s;\n' "${CLOUDFLARE_REAL_IP}" "${ip}")
done
CLOUDFLARE_REAL_IP=$(printf '%sreal_ip_header CF-Connecting-IP;\nreal_ip_recursive on;\n' "${CLOUDFLARE_REAL_IP}")

export FLASK_PORT_START FLASK_PORT_END PORT UPSTREAM_SERVERS CLOUDFLARE_IPS_FIREWALL CLOUDFLARE_REAL_IP NGINX_LOCALHOST PUBLIC_MAX_UPLOAD_MB API_HOST FRONT_HOST

envsubst '$FLASK_PORT_START $FLASK_PORT_END $PORT $UPSTREAM_SERVERS $CLOUDFLARE_IPS_FIREWALL $CLOUDFLARE_REAL_IP $NGINX_LOCALHOST $PUBLIC_MAX_UPLOAD_MB $API_HOST $FRONT_HOST' < "${TEMPLATE_PATH}" > "${OUT_PATH}"
exit 0
