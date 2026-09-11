#!/usr/bin/env bash
# Инициализация WireGuard-сервера на Raspberry Pi (Debian/Ubuntu/Raspberry Pi OS).
#
# Что делает:
#   - ставит wireguard и qrencode (если apt)
#   - генерит ключи сервера в /etc/wireguard
#   - создаёт /etc/wireguard/wg0.conf с правилами NAT
#   - включает net.ipv4.ip_forward
#   - запускает и добавляет в автозапуск wg-quick@wg0
#   - сохраняет публичный endpoint в /etc/wireguard/.endpoint для add-client
#
# Использование:
#   sudo WG_ENDPOINT=my.duckdns.org:51820 ./wg-init.sh
#
# Переменные окружения (все опциональны кроме WG_ENDPOINT):
#   WG_ENDPOINT             — публичный адрес:порт (например duckdns или белый IP роутера)
#   WG_PORT                 — UDP-порт сервера (по умолчанию 51820)
#   WG_SUBNET               — /24 подсеть VPN без последнего октета (по умолчанию 10.8.0)
#   WG_NIC                  — интерфейс выхода в инет (автоопределяется по default route)
#   WG_DIR                  — каталог конфига (по умолчанию /etc/wireguard)

set -euo pipefail

WG_DIR="${WG_DIR:-/etc/wireguard}"
WG_PORT="${WG_PORT:-51820}"
WG_SUBNET="${WG_SUBNET:-10.8.0}"
WG_ENDPOINT="${WG_ENDPOINT:-}"

if [[ $EUID -ne 0 ]]; then
  echo "Запусти под root: sudo $0" >&2
  exit 1
fi

if [[ -z "$WG_ENDPOINT" ]]; then
  echo "WG_ENDPOINT не задан. Пример: sudo WG_ENDPOINT=mydomain.duckdns.org:${WG_PORT} $0" >&2
  exit 1
fi

WG_NIC="${WG_NIC:-$(ip route | awk '/default/ {print $5; exit}')}"
if [[ -z "$WG_NIC" ]]; then
  echo "Не удалось определить сетевой интерфейс. Задай WG_NIC вручную." >&2
  exit 1
fi

echo "==> Используется интерфейс: $WG_NIC"
echo "==> VPN подсеть: ${WG_SUBNET}.0/24, порт: $WG_PORT"
echo "==> Endpoint для клиентов: $WG_ENDPOINT"

if command -v apt-get >/dev/null 2>&1; then
  echo "==> Установка пакетов через apt"
  apt-get update -qq
  apt-get install -y -qq wireguard qrencode iptables
elif command -v wg >/dev/null 2>&1; then
  echo "==> wireguard уже установлен, пропускаю установку"
else
  echo "Не нашёл apt и wireguard не установлен. Поставь wireguard и qrencode вручную и перезапусти." >&2
  exit 1
fi

mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"
cd "$WG_DIR"

if [[ -f wg0.conf ]]; then
  echo "==> $WG_DIR/wg0.conf уже существует. Прерываю, чтобы ничего не сломать."
  echo "    Если нужно переинициализировать — снеси конфиг сам и запусти заново."
  exit 1
fi

umask 077

if [[ ! -f server_private.key ]]; then
  echo "==> Генерация ключей сервера"
  wg genkey | tee server_private.key | wg pubkey >server_public.key
fi

SERVER_PRIV="$(cat server_private.key)"

cat >wg0.conf <<EOF
# Сгенерировано wg-init.sh
[Interface]
Address = ${WG_SUBNET}.1/24
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIV}
SaveConfig = false

PostUp   = iptables -A FORWARD -i %i -j ACCEPT
PostUp   = iptables -A FORWARD -o %i -j ACCEPT
PostUp   = iptables -t nat -A POSTROUTING -o ${WG_NIC} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o ${WG_NIC} -j MASQUERADE

# Клиенты добавляются ниже скриптом wg-add-client.sh
EOF

chmod 600 wg0.conf

echo "$WG_ENDPOINT" >"$WG_DIR/.endpoint"
chmod 600 "$WG_DIR/.endpoint"

echo "==> Включение net.ipv4.ip_forward"
cat >/etc/sysctl.d/99-wireguard.conf <<'EOF'
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/99-wireguard.conf >/dev/null

echo "==> Включение wg-quick@wg0 в автозапуск"
systemctl enable --now wg-quick@wg0

echo ""
echo "Готово."
echo "  Сервер слушает: 0.0.0.0:${WG_PORT}/udp"
echo "  Внутренний IP сервера: ${WG_SUBNET}.1"
echo "  Публичный ключ сервера:"
echo "    $(cat "$WG_DIR/server_public.key")"
echo ""
echo "Дальше:"
echo "  1) На роутере проброс UDP ${WG_PORT} -> IP этого Pi."
echo "  2) Добавь клиента: sudo ./wg-add-client.sh <имя>"
echo "  3) Проверь: sudo wg show"
