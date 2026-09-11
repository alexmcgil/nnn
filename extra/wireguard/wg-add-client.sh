#!/usr/bin/env bash
# Добавление нового WireGuard-клиента.
#
# Что делает:
#   - генерит пару ключей клиента и preshared key
#   - выбирает следующий свободный IP в подсети сервера
#   - добавляет [Peer] секцию в /etc/wireguard/wg0.conf
#   - применяет изменения на лету через wg syncconf (без рестарта тоннеля)
#   - кладёт готовый клиентский конфиг в /etc/wireguard/clients/<имя>.conf
#   - печатает QR-код для импорта в мобильное приложение
#
# Использование:
#   sudo ./wg-add-client.sh <имя>
#
# Переменные окружения:
#   WG_CLIENT_ALLOWED_IPS — что роутить через VPN на клиенте
#                          (по умолчанию автоопределение локалки сервера + VPN подсеть;
#                          для full tunnel задай "0.0.0.0/0, ::/0")
#   WG_CLIENT_DNS         — DNS для клиента (по умолчанию пусто, не пишется)
#   WG_DIR                — каталог конфига (по умолчанию /etc/wireguard)

set -euo pipefail

WG_DIR="${WG_DIR:-/etc/wireguard}"
WG_IFACE="wg0"

if [[ $EUID -ne 0 ]]; then
  echo "Запусти под root: sudo $0 <имя>" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Использование: sudo $0 <имя_клиента>" >&2
  exit 1
fi

NAME="$1"
if [[ ! "$NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Недопустимое имя клиента: разрешены [a-zA-Z0-9._-]" >&2
  exit 1
fi

if [[ ! -f "$WG_DIR/wg0.conf" ]]; then
  echo "Сначала запусти wg-init.sh — нет $WG_DIR/wg0.conf" >&2
  exit 1
fi

if [[ ! -f "$WG_DIR/.endpoint" ]]; then
  echo "Нет $WG_DIR/.endpoint. Создай файл с публичным endpoint вида host:port" >&2
  exit 1
fi

ENDPOINT="$(cat "$WG_DIR/.endpoint")"
SERVER_PUB="$(cat "$WG_DIR/server_public.key")"

SERVER_CIDR="$(awk -F'[ =/]+' '/^Address/ {print $2"/"$3; exit}' "$WG_DIR/wg0.conf")"
SERVER_IP="${SERVER_CIDR%/*}"
SUBNET_PREFIX="${SERVER_IP%.*}"

# Выбираем следующий свободный IP (.2, .3, ...)
USED_LAST_OCTET="$(grep -oE 'AllowedIPs *= *'"${SUBNET_PREFIX//./\\.}"'\.[0-9]+' "$WG_DIR/wg0.conf" \
  | awk -F. '{print $4+0}' | sort -n | tail -n1 || true)"
SERVER_OCTET="${SERVER_IP##*.}"
NEXT_OCTET="$(( ${USED_LAST_OCTET:-$SERVER_OCTET} + 1 ))"

if (( NEXT_OCTET > 254 )); then
  echo "Свободных адресов в ${SUBNET_PREFIX}.0/24 не осталось" >&2
  exit 1
fi

CLIENT_IP="${SUBNET_PREFIX}.${NEXT_OCTET}"

CLIENTS_DIR="$WG_DIR/clients"
mkdir -p "$CLIENTS_DIR"
chmod 700 "$CLIENTS_DIR"

CLIENT_CONF="$CLIENTS_DIR/${NAME}.conf"
if [[ -f "$CLIENT_CONF" ]]; then
  echo "Клиент с именем '$NAME' уже существует: $CLIENT_CONF" >&2
  exit 1
fi

# Автоопределение AllowedIPs клиента: VPN подсеть + локалка сервера
DEFAULT_ALLOWED="${SUBNET_PREFIX}.0/24"
LAN_CIDR="$(ip -o -4 route show scope link 2>/dev/null \
  | awk -v vpn="$SUBNET_PREFIX" '$1 !~ "^"vpn {print $1; exit}')"
if [[ -n "$LAN_CIDR" ]]; then
  DEFAULT_ALLOWED="${LAN_CIDR}, ${SUBNET_PREFIX}.0/24"
fi
ALLOWED_IPS="${WG_CLIENT_ALLOWED_IPS:-$DEFAULT_ALLOWED}"
CLIENT_DNS="${WG_CLIENT_DNS:-}"

umask 077

CLIENT_PRIV="$(wg genkey)"
CLIENT_PUB="$(echo "$CLIENT_PRIV" | wg pubkey)"
PRESHARED="$(wg genpsk)"

# Дописываем peer в wg0.conf
{
  echo ""
  echo "# Client: ${NAME} (added $(date -u +%Y-%m-%dT%H:%M:%SZ))"
  echo "[Peer]"
  echo "PublicKey = ${CLIENT_PUB}"
  echo "PresharedKey = ${PRESHARED}"
  echo "AllowedIPs = ${CLIENT_IP}/32"
} >>"$WG_DIR/wg0.conf"

# Генерация клиентского конфига
{
  echo "[Interface]"
  echo "PrivateKey = ${CLIENT_PRIV}"
  echo "Address = ${CLIENT_IP}/32"
  [[ -n "$CLIENT_DNS" ]] && echo "DNS = ${CLIENT_DNS}"
  echo ""
  echo "[Peer]"
  echo "PublicKey = ${SERVER_PUB}"
  echo "PresharedKey = ${PRESHARED}"
  echo "Endpoint = ${ENDPOINT}"
  echo "AllowedIPs = ${ALLOWED_IPS}"
  echo "PersistentKeepalive = 25"
} >"$CLIENT_CONF"

chmod 600 "$CLIENT_CONF"

# Применяем без рестарта (соединения других клиентов не оборвутся)
wg syncconf "$WG_IFACE" <(wg-quick strip "$WG_IFACE")

echo "==> Клиент '$NAME' добавлен"
echo "    Внутренний IP:  ${CLIENT_IP}/32"
echo "    AllowedIPs:     ${ALLOWED_IPS}"
echo "    Конфиг:         ${CLIENT_CONF}"
echo ""

if command -v qrencode >/dev/null 2>&1; then
  echo "==> QR для импорта в мобильное приложение WireGuard:"
  qrencode -t ansiutf8 <"$CLIENT_CONF"
else
  echo "(qrencode не установлен — поставь, чтобы видеть QR здесь: apt install qrencode)"
fi

echo ""
echo "Скопировать конфиг себе:"
echo "  scp pi@<ip>:${CLIENT_CONF} ."
