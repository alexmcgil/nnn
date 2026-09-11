#!/usr/bin/env bash
# Установка хаба wgp2p — отдельного WireGuard-интерфейса, через который
# собственные машины видят друг друга по внутренним IP, оставаясь при этом
# подключёнными к VPN через openconnect.
#
# Использование:
#   sudo /opt/wgp2p/install.sh
#
# Скрипт идемпотентен: повторный запуск не перегенерирует ключи, не теряет
# добавленных пиров и не рвёт установленные соединения (применяет конфиг
# через wg syncconf, если интерфейс уже поднят).
#
# Подробности, диагностика и порядок переноса на другой сервер — в README.md
# рядом с этим файлом.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=wgp2p.env
source "$BASE_DIR/wgp2p.env"

CONF="$BASE_DIR/${IFACE}.conf"
KEYS_DIR="$BASE_DIR/keys"
PEERS_DIR="$BASE_DIR/peers"
ETC_CONF="/etc/wireguard/${IFACE}.conf"

if [[ $EUID -ne 0 ]]; then
  echo "Запусти под root: sudo $0" >&2
  exit 1
fi

# ---- 1. Инструменты userspace -------------------------------------------------
# Нужны только wg и wg-quick. Сам WireGuard встроен в ядро с 5.6, поэтому
# --no-install-recommends обязателен: у пакета wireguard-tools в Recommends
# стоит wireguard-modules, который на Ubuntu разворачивается в
# linux-modules-extra-<ядро> и тянет за собой метапакет ядра, linux-firmware и
# microcode — десятки мегабайт, перегенерацию initramfs/grub и флаг
# «reboot required» на сервере, которому всё это не нужно.
if command -v wg >/dev/null 2>&1 && command -v wg-quick >/dev/null 2>&1; then
  echo "==> wireguard-tools уже установлен"
elif command -v apt-get >/dev/null 2>&1; then
  echo "==> Установка wireguard-tools через apt"
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends wireguard-tools iptables
elif command -v pacman >/dev/null 2>&1; then
  echo "==> Установка wireguard-tools через pacman"
  pacman -Sy --noconfirm --needed wireguard-tools iptables
elif command -v dnf >/dev/null 2>&1; then
  echo "==> Установка wireguard-tools через dnf"
  dnf install -y --setopt=install_weak_deps=False wireguard-tools iptables
elif command -v apk >/dev/null 2>&1; then
  echo "==> Установка wireguard-tools через apk"
  apk add --no-cache wireguard-tools iptables
else
  echo "Не нашёл поддерживаемый пакетный менеджер. Поставь wireguard-tools вручную." >&2
  exit 1
fi

# ---- 2. Поддержка WireGuard в ядре -------------------------------------------
# Проверяем не наличием модуля (он может быть вкомпилен), а попыткой создать
# интерфейс — это единственная надёжная проверка на любом хосте, включая VPS
# с урезанными ядрами и OpenVZ/LXC.
modprobe wireguard 2>/dev/null || true
if ! ip link add dev wgp2pprobe type wireguard 2>/dev/null; then
  echo "Ядро не умеет WireGuard: не удалось создать тестовый интерфейс." >&2
  echo "Варианты:" >&2
  echo "  - доустановить модуль: apt install linux-modules-extra-\$(uname -r)" >&2
  echo "    (или dkms-пакет wireguard для ядер старше 5.6)" >&2
  echo "  - на OpenVZ/LXC модуль недоступен в принципе — нужен userspace-вариант" >&2
  echo "    (boringtun или wireguard-go)" >&2
  exit 1
fi
ip link del wgp2pprobe

# ---- 3. Каталоги и ключи сервера ---------------------------------------------
install -d -m 700 "$KEYS_DIR" "$PEERS_DIR"
chmod 700 "$BASE_DIR"
umask 077

if [[ ! -f "$KEYS_DIR/server.key" ]]; then
  echo "==> Генерация ключей хаба"
  wg genkey >"$KEYS_DIR/server.key"
  wg pubkey <"$KEYS_DIR/server.key" >"$KEYS_DIR/server.pub"
fi
chmod 600 "$KEYS_DIR/server.key"
chmod 600 "$KEYS_DIR/server.pub"

# ---- 4. Конфиг интерфейса ----------------------------------------------------
# Создаётся только если отсутствует: иначе перезапись потеряла бы блоки [Peer],
# добавленные add-peer.sh.
if [[ -f "$CONF" ]]; then
  echo "==> $CONF уже существует, оставляю как есть (пиры сохранены)"
else
  echo "==> Создание $CONF"
  cat >"$CONF" <<EOF
# Сгенерировано install.sh — хаб wgp2p.
# Правь через add-peer.sh; параметры интерфейса — в wgp2p.env + переустановка.

[Interface]
Address = ${SERVER_IP}/24
ListenPort = ${WG_PORT}
MTU = ${MTU}
PrivateKey = $(cat "$KEYS_DIR/server.key")
# SaveConfig обязательно false: с true wg-quick перезаписал бы этот файл при
# остановке и стёр комментарии, PostUp/PostDown и структуру пиров.
SaveConfig = false

# Пиры этого интерфейса ходят друг к другу через хаб, то есть трафик проходит
# цепочку FORWARD. Без явного ACCEPT он режется, когда FORWARD policy = DROP
# (docker выставляет её при перезапуске демона). Вставляем первым правилом,
# чтобы не зависеть от порядка чужих цепочек.
PostUp = iptables -I FORWARD 1 -i %i -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -o %i -j ACCEPT

# На хосте с INPUT policy = ACCEPT это правило избыточно, но нужно при переносе
# на сервер, где по умолчанию DROP (ufw, облачные образы с firewalld).
PostUp = iptables -I INPUT 1 -p udp --dport ${WG_PORT} -j ACCEPT
PostDown = iptables -D INPUT -p udp --dport ${WG_PORT} -j ACCEPT

# NAT/MASQUERADE сознательно не настраивается: этот туннель не даёт выход в
# интернет, у клиентов в AllowedIPs только ${SUBNET}.0/24. Меньше прав —
# меньше способов случайно отправить весь трафик через сервер.

# ---- Пиры ниже добавляет add-peer.sh ----
EOF
fi
chmod 600 "$CONF"

# ---- 5. Форвардинг между пирами ----------------------------------------------
echo "==> Включение net.ipv4.ip_forward"
cat >/etc/sysctl.d/99-wgp2p.conf <<'EOF'
# Нужен, чтобы хаб wgp2p мог передавать пакеты между своими пирами.
net.ipv4.ip_forward = 1
EOF
sysctl -q -p /etc/sysctl.d/99-wgp2p.conf

# ---- 6. Связка с wg-quick ----------------------------------------------------
# wg-quick@<IFACE> читает строго /etc/wireguard/<IFACE>.conf, поэтому там
# симлинк, а состояние целиком живёт в одном каталоге — его достаточно
# скопировать на новый сервер.
install -d -m 700 /etc/wireguard
if [[ -e "$ETC_CONF" && ! -L "$ETC_CONF" ]]; then
  echo "$ETC_CONF существует и это не симлинк — убери его вручную и запусти снова." >&2
  exit 1
fi
ln -sfn "$CONF" "$ETC_CONF"

systemctl enable "wg-quick@${IFACE}" >/dev/null 2>&1 || true
if systemctl is-active --quiet "wg-quick@${IFACE}"; then
  wg syncconf "$IFACE" <(wg-quick strip "$IFACE")
  echo "==> Интерфейс уже поднят: конфиг применён без разрыва соединений"
else
  systemctl start "wg-quick@${IFACE}"
  echo "==> Интерфейс поднят"
fi

# ---- 7. Итог -----------------------------------------------------------------
cat <<EOF

Готово.
  Интерфейс:        ${IFACE} (${SERVER_IP}/24), UDP ${WG_PORT}
  Endpoint клиентов: ${ENDPOINT_HOST}:${WG_PORT}
  Публичный ключ:    $(cat "$KEYS_DIR/server.pub")

Дальше:
  добавить пира с генерацией ключей здесь:
    sudo ${BASE_DIR}/add-peer.sh --name my-laptop
  добавить пира, чей приватный ключ остаётся на клиенте (предпочтительно):
    sudo ${BASE_DIR}/add-peer.sh --name my-laptop --pubkey <публичный ключ клиента>
  посмотреть состояние:
    wg show ${IFACE}
EOF
