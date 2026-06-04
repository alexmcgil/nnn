# Прямой WiFi-стриминг на Quest 3 + шаринг WireGuard

Дата: 2026-06-04
Хост: `desktop-amd`

## Цель

Стримить VR с этого ПК на Quest 3 по **прямому WiFi-линку** (ПК как точка
доступа), минуя общий домашний роутер/локалку. Дополнительно — **шарить на шлем
интернет**, причём когда поднят WireGuard-профиль `bedroom`, весь интернет-трафик
шлема должен идти через VPN (full-tunnel), а когда выключен — напрямую.
Переключение автоматическое, без ручных действий.

## Контекст оборудования (проверено)

- WiFi: MediaTek **MT7922** (`wlp9s0`, драйвер `mt7921e`) — AP-mode поддерживает.
- Интернет ПК — по кабелю `eno1`. WiFi-модуль свободен и целиком уходит под AP.
- Сеть управляется **NetworkManager**; конфиг NixOS декларативный (flake).
- WG-профиль `bedroom` (UUID `675b3c59-5171-4b65-a73e-4b3ac8ac5f03`) —
  full-tunnel: `allowed-ips=0.0.0.0/0;::/0`, `never-default=no`. Управляется
  NM (не wg-quick). Сейчас выключен. Отдельно есть AmneziaVPN на `tun0`.

## Архитектура

```
Интернет ── eno1 (WAN) ──────────┐
                                 │   ПК desktop-amd: IP forward + NAT (masquerade)
WireGuard "bedroom" (full-tun) ──┤   default route: WG up → VPN, WG down → eno1
                                 │
Quest 3 ──WiFi 5GHz── wlp9s0 (AP, 10.42.0.1/24, dnsmasq DHCP/DNS)
```

Поток данных:

- Quest подключается к SSID ПК, получает адрес `10.42.0.x`, шлюз/DNS — `10.42.0.1`.
- **Стриминг (ALVR / WiVRn / SteamVR) идёт локально внутри `10.42.0.0/24`** —
  напрямую ПК↔шлем, не через VPN. Задержку стрима VPN не затрагивает.
- Обычный интернет-трафик шлема форвардится ПК и маскарадится по подсети-источнику.
  Маскарад NM в методе `shared` не привязан к out-интерфейсу, поэтому следует за
  текущим default route: WG up → через тоннель, WG down → через `eno1`.
  Никакого ручного policy-routing не нужно — full-tunnel WG сам ставит правила
  `not fwmark` / `suppress_prefixlength`, которые ловят и форвардящийся трафик.

## Компоненты (всё в новом модуле `modules/services/vr-streaming.nix`)

Модуль импортируется в `hosts/desktop-amd/default.nix`.

### 1. Точка доступа (NetworkManager hotspot, декларативно)

Через `networking.networkmanager.ensureProfiles.profiles.vr-hotspot` (keyfile):

```
[connection] id=vr-hotspot, type=wifi, interface-name=wlp9s0, autoconnect=true
[wifi]       mode=ap, ssid=<SSID>, band=a, channel=36
[wifi-security] key-mgmt=sae  (WPA3; fallback wpa-psk при проблемах со шлемом), psk=<inline>
[ipv4]       method=shared          # dnsmasq DHCP/DNS + NAT + forwarding
[ipv6]       method=disabled
```

- Диапазон 5 ГГц (`band=a`), канал 36 — без DFS-ожидания. 6 ГГц не используем
  (regdomain/AFC + неполный AP-mode в mt76 + нет селектора 6 ГГц в NM).
- **PSK — инлайн** в конфиге (решение пользователя: проще). Принимаем, что пароль
  попадёт в world-readable nix store; для приватного домашнего репо допустимо.
- **Автозапуск при загрузке** (`autoconnect=true`). Если NM не поднимает AP-профиль
  автоматически (известная особенность AP-режима) — подстраховка systemd-юнитом
  `nmcli connection up vr-hotspot` после `NetworkManager.service`.

### 2. Форвардинг и NAT

- Метод `shared` сам включает forwarding для подсети и ставит masquerade.
  Дополнительно зафиксировать `boot.kernel.sysctl."net.ipv4.ip_forward" = 1`.
- `networking.firewall.checkReversePath = "loose"` — уже стоит в `network.nix`
  (нужно для WG). Оставляем.
- **MSS clamp** для форвардящегося трафика (страховка от MTU-блэкхолов при выходе
  через WG, MTU 1422) — опциональное усиление, нацелено только на интернет шлема,
  на локальный стрим не влияет.

### 3. Firewall

- `networking.firewall.trustedInterfaces = [ "wlp9s0" ]` — прямой приватный линк
  ПК↔шлем открываем целиком (DHCP/DNS + порты ALVR/WiVRn/SteamVR), чтобы не
  перечислять порты вручную. Риск низкий: интерфейс не смотрит во внешнюю сеть.

### 4. VR-софт

- `services.wivrn.enable = true` — Monado-сервер WiVRn (нативный для Linux, сам
  открывает свои порты, тянет Monado).
- Пакеты: `alvr`, `monado` (CLI/утилиты), при необходимости `android-tools` (adb
  для установки клиента ALVR на Quest).
- SteamVR — через уже подключённый Steam (`modules/apps/steam.nix`).

## Что НЕ входит / ограничения

- ⚠️ **Virtual Desktop** — серверной части под Linux не существует (только Windows).
  На этом ПК не заведётся. Из набора реально работают **ALVR, WiVRn, Steam Link/SteamVR**.
- Одновременно активен только один **OpenXR-рантайм** (WiVRn / ALVR / SteamVR) —
  переключается под задачу. Это эксплуатационный нюанс, не часть инфраструктуры.
- PC-as-AP по джиттеру немного уступает выделенному WiFi-роутеру, но это и есть
  запрошенный прямой линк мимо общей локалки.
- Профиль `bedroom` остаётся императивным (NM keyfile с секретами) — не переносим
  в nix. Дизайн полагается на его текущий full-tunnel режим (проверено).

## Критерии готовности

1. После `nixos-rebuild switch` и загрузки SSID ПК виден, Quest подключается и
   получает адрес `10.42.0.x`.
2. С Quest пингуется `10.42.0.1` и есть выход в интернет.
3. WiVRn/ALVR со шлема находят ПК и запускают VR-стрим по локальному линку.
4. При выключенном `bedroom` внешний IP шлема = IP провайдера (через `eno1`).
5. При `nmcli con up bedroom` внешний IP шлема меняется на VPN-выход — **без**
   переподключения шлема и без ручных правил маршрутизации. При `down` — возврат.

## Открытые точки для плана реализации

- Точный синтаксис `ensureProfiles` keyfile в текущей версии nixpkgs (flake.lock).
- Где именно ставить MSS-clamp (nftables `extraForwardRules` vs `extraCommands`).
- Проверка, что NM реально автозапускает AP-профиль; иначе — systemd-подстраховка.
- Имя SSID и пароль.
