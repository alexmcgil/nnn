#!/usr/bin/env bash
# Добавить пира в хаб wgp2p.
#
# Два режима:
#
#   sudo /opt/wgp2p/add-peer.sh --name my-laptop
#       ключевая пара генерируется здесь, в peers/<имя>.conf ложится готовый
#       клиентский конфиг — удобно для телефонов и «обычных» линуксов.
#
#   sudo /opt/wgp2p/add-peer.sh --name desktop-amd --pubkey <публичный ключ>
#       приватный ключ клиента никогда не попадает на сервер. Предпочтительный
#       режим; обязателен для декларативных клиентов (NixOS), где ключ и так
#       лежит отдельным файлом.
#
# Опции:
#   --name <имя>     обязательно, [a-zA-Z0-9._-]
#   --pubkey <ключ>  публичный ключ клиента (режим без генерации приватного)
#   --ip <адрес>     задать адрес вручную; по умолчанию следующий свободный
#
# Изменения применяются через wg syncconf — соединения остальных пиров не рвутся.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=wgp2p.env
source "$BASE_DIR/wgp2p.env"

CONF="$BASE_DIR/${IFACE}.conf"
KEYS_DIR="$BASE_DIR/keys"
PEERS_DIR="$BASE_DIR/peers"

NAME=""
CLIENT_PUB=""
CLIENT_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)   NAME="${2:-}";       shift 2 ;;
    --pubkey) CLIENT_PUB="${2:-}"; shift 2 ;;
    --ip)     CLIENT_IP="${2:-}";  shift 2 ;;
    -h|--help) sed -n '2,25p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "Запусти под root: sudo $0 --name <имя>" >&2
  exit 1
fi

if [[ -z "$NAME" ]]; then
  echo "Не задано --name" >&2
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Недопустимое имя: разрешены [a-zA-Z0-9._-]" >&2
  exit 1
fi

if [[ ! -f "$CONF" ]]; then
  echo "Нет $CONF — сначала запусти install.sh" >&2
  exit 1
fi

install -d -m 700 "$PEERS_DIR"

CLIENT_CONF="$PEERS_DIR/${NAME}.conf"
if [[ -e "$CLIENT_CONF" ]]; then
  echo "Пир '$NAME' уже есть: $CLIENT_CONF" >&2
  echo "Удали его (см. раздел «Удаление пира» в README.md) или возьми другое имя." >&2
  exit 1
fi

if grep -qE "^# peer: ${NAME}\$" "$CONF"; then
  echo "В $CONF уже есть блок с именем '$NAME'" >&2
  exit 1
fi

if [[ -n "$CLIENT_PUB" ]] && grep -qF "$CLIENT_PUB" "$CONF"; then
  echo "Этот публичный ключ уже добавлен в $CONF" >&2
  exit 1
fi

# ---- Выбор адреса ------------------------------------------------------------
# Берём максимальный занятый последний октет + 1. Освободившиеся адреса
# сознательно не переиспользуем: так номер однозначно привязан к машине и не
# всплывает потом в чужих ssh-конфигах и логах.
if [[ -z "$CLIENT_IP" ]]; then
  ESCAPED_SUBNET="${SUBNET//./\\.}"
  LAST_OCTET="$(grep -oE "AllowedIPs *= *${ESCAPED_SUBNET}\.[0-9]+" "$CONF" \
    | awk -F. '{print $4+0}' | sort -n | tail -n1 || true)"
  NEXT_OCTET=$(( ${LAST_OCTET:-1} + 1 ))
  if (( NEXT_OCTET > 254 )); then
    echo "Свободных адресов в ${SUBNET}.0/24 не осталось" >&2
    exit 1
  fi
  CLIENT_IP="${SUBNET}.${NEXT_OCTET}"
fi

if grep -qE "AllowedIPs *= *${CLIENT_IP//./\\.}/32" "$CONF"; then
  echo "Адрес $CLIENT_IP уже занят" >&2
  exit 1
fi

# ---- Ключи ------------------------------------------------------------------
umask 077

SERVER_PUB="$(cat "$KEYS_DIR/server.pub")"
PRESHARED="$(wg genpsk)"

CLIENT_PRIV=""
if [[ -z "$CLIENT_PUB" ]]; then
  CLIENT_PRIV="$(wg genkey)"
  CLIENT_PUB="$(echo "$CLIENT_PRIV" | wg pubkey)"
  GEN_MODE="ключи сгенерированы на сервере"
else
  GEN_MODE="приватный ключ остался на клиенте"
fi

printf '%s\n' "$CLIENT_PUB" >"$PEERS_DIR/${NAME}.pub"
printf '%s\n' "$PRESHARED" >"$PEERS_DIR/${NAME}.psk"
chmod 600 "$PEERS_DIR/${NAME}.pub" "$PEERS_DIR/${NAME}.psk"

# ---- Блок [Peer] в конфиг хаба ----------------------------------------------
{
  echo ""
  echo "# peer: ${NAME}"
  echo "# added: $(date -u +%Y-%m-%dT%H:%M:%SZ) (${GEN_MODE})"
  echo "[Peer]"
  echo "PublicKey = ${CLIENT_PUB}"
  echo "PresharedKey = ${PRESHARED}"
  echo "AllowedIPs = ${CLIENT_IP}/32"
} >>"$CONF"

# ---- Клиентский конфиг ------------------------------------------------------
# AllowedIPs у клиента — только подсеть туннеля. Это принципиально: с 0.0.0.0/0
# wg-quick поставил бы fwmark + `ip rule not fwmark ... lookup <table>`, который
# по приоритету выше main и перебил бы split-tunnel маршруты VPN. Здесь же
# добавляется единственный маршрут на /24 — доступ не затрагивается.
{
  echo "# Клиент ${NAME} для хаба wgp2p (${ENDPOINT_HOST}:${WG_PORT})"
  echo "# Установка на обычном Linux:"
  echo "#   sudo install -m 600 ${NAME}.conf /etc/wireguard/${IFACE}.conf"
  echo "#   sudo systemctl enable --now wg-quick@${IFACE}"
  echo ""
  echo "[Interface]"
  if [[ -n "$CLIENT_PRIV" ]]; then
    echo "PrivateKey = ${CLIENT_PRIV}"
  else
    echo "PrivateKey = ВПИШИ_ПРИВАТНЫЙ_КЛЮЧ_ЭТОГО_КЛИЕНТА"
  fi
  echo "Address = ${CLIENT_IP}/32"
  echo "MTU = ${MTU}"
  echo "# DNS сознательно не задан: wg-quick с DNS= перепишет resolv.conf и"
  echo "# сломает DNS VPN. Этот туннель — только про IP-связность."
  echo ""
  echo "[Peer]"
  echo "PublicKey = ${SERVER_PUB}"
  echo "PresharedKey = ${PRESHARED}"
  echo "Endpoint = ${ENDPOINT_HOST}:${WG_PORT}"
  echo "AllowedIPs = ${SUBNET}.0/24"
  echo "# Обе машины за NAT, поэтому дырку в нём надо держать открытой с обеих"
  echo "# сторон, иначе входящие пакеты от хаба не дойдут до спящего клиента."
  echo "PersistentKeepalive = 25"
} >"$CLIENT_CONF"
chmod 600 "$CLIENT_CONF"

# ---- Применение без разрыва -------------------------------------------------
if systemctl is-active --quiet "wg-quick@${IFACE}"; then
  wg syncconf "$IFACE" <(wg-quick strip "$IFACE")
  APPLIED="применено на живом интерфейсе (wg syncconf)"
else
  APPLIED="интерфейс не запущен — применится при следующем старте"
fi

cat <<EOF

==> Пир '${NAME}' добавлен
    Адрес:      ${CLIENT_IP}/32
    Публичный:  ${CLIENT_PUB}
    Режим:      ${GEN_MODE}
    Конфиг:     ${CLIENT_CONF}
    Состояние:  ${APPLIED}

Забрать на клиента (одной командой, секрет не проходит через буфер обмена):
  ssh <этот сервер> 'cat ${CLIENT_CONF}' | sudo install -m 600 /dev/stdin /etc/wireguard/${IFACE}.conf
  sudo systemctl enable --now wg-quick@${IFACE}

Только preshared key (для декларативных клиентов вроде NixOS):
  ssh <этот сервер> 'cat ${PEERS_DIR}/${NAME}.psk'
EOF
