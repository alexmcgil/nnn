# Raspberry Pi 4 как WireGuard-мост к desktop-amd

**Дата:** 2026-05-26
**Статус:** утверждён, ожидается план реализации

## Цель

Сделать Raspberry Pi 4 шлюзом WireGuard в домашнюю локальную сеть. С внешнего клиента (ноут, телефон) через WG-туннель должен быть доступен `desktop-amd` так, как если бы клиент находился в домашней сети:

- Sunshine / Moonlight стрим к desktop-amd
- SSH к desktop-amd
- Dev-серверы desktop-amd на портах 3000 и 5173 (для удалённой разработки)
- При необходимости — любые другие хосты локалки

Pi выступает чистым L3-маршрутизатором WireGuard, никакого DNAT по конкретным портам.

## Контекст репозитория

Репо — публичный NixOS-flake с двумя хостами (`desktop-amd`, `laptop-intel`) и набором модулей в `modules/`. Sunshine, SSH и `wireguard-tools` уже сконфигурированы на desktop-amd. Секреты традиционно хранятся вне git в `/etc/nixos/secrets/`.

## Топология

```
                 интернет (белый IP)
                       │
                       │ UDP 51820
                       ▼
                 [домашний роутер]
              192.168.0.100, проброс
              51820/UDP → 192.168.0.110
                       │
       ┌───────────────┼────────────────┐
       │               │                │
       ▼               ▼                ▼
   pi-bridge      desktop-amd      прочие хосты
  192.168.0.110  192.168.0.107
   Wi-Fi (wlan0)  Sunshine, SSH,
   wg0 10.100.0.1 dev-серверы 3000/5173
```

VPN-подсеть: `10.100.0.0/24`.
- `10.100.0.1` — Pi
- `10.100.0.2` — ноут
- `10.100.0.3` — телефон
- `10.100.0.4` — резерв

Локальная сеть: `192.168.0.0/24`, шлюз `192.168.0.100`, DHCP раздаёт со `.101`.

## Архитектурное решение

Используем нативные NixOS-модули:

- `networking.wg-quick.interfaces.wg0` — поднимает WG-сервер
- `networking.nat` — IP forwarding и MASQUERADE из `wg0` в `wlan0`
- `networking.firewall` — открывает UDP 51820, `trustedInterfaces = [ "wg0" ]`

Альтернативы — raw `networking.wireguard` + ручной nftables и systemd-networkd — отклонены: первый дублирует функционал, второй создаёт разрыв с уже используемым в репо NetworkManager.

## Изменения в репо

### Новые файлы

```
hosts/pi-bridge/
  default.nix          — минимальный хост (без desktop-обвязки)
  hardware.nix         — nixos-hardware/raspberry-pi-4 + fileSystems
modules/services/
  wg-bridge.nix        — WG-сервер + NAT + IP forwarding
docs/superpowers/specs/
  2026-05-26-rpi-wg-bridge-design.md  — этот файл
```

### Правки существующих файлов

**`flake.nix`:**
- Добавить input `nixos-hardware` (`github:NixOS/nixos-hardware/master`)
- Переписать `mkHost`: базовый список модулей минимальный, тяжёлые desktop-модули (`disko`, `niri`, `aagl`, `zapret-discord-youtube`) идут через `extraModules`. Это нужно, чтобы Pi-bridge их не тянул.
- Добавить хост `pi-bridge` с `system = "aarch64-linux"` и `extraModules = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ]`

**`hosts/desktop-amd/default.nix`:**
- Добавить `boot.binfmt.emulatedSystems = [ "aarch64-linux" ]` — для cross-сборки sdImage прямо на x86_64 десктопе через qemu-user

**`modules/network.nix`:**
- Расширить `allowedTCPPorts` с `[ 25565 8188 ]` до `[ 25565 8188 3000 5173 ]` — открыть dev-порты в локалке. Это сознательное упрощение: порты светят по всей `192.168.0.0/24`. Если потребуется строже — биндить dev-серверы на конкретный IP/интерфейс, firewall не усложнять.

### Не трогаем

- `modules/network.nix` (в основном), `modules/services/ssh.nix`, `modules/services/sunshine.nix` — уже готовы для desktop-amd
- `users/alexmcgil.nix` — переиспользуем как есть, но в `hosts/pi-bridge/default.nix` глушим home-manager через `home-manager.users.alexmcgil = lib.mkForce { home.stateVersion = "25.11"; }`, чтобы не тащить 33 КБ desktop-конфига на headless Pi

## Детали модулей

### `modules/services/wg-bridge.nix`

```nix
{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/nixos/secrets/wg-pi-bridge.key";

    peers = [
      { publicKey = "<PEER_LAPTOP_PUBKEY>"; allowedIPs = [ "10.100.0.2/32" ]; }
      { publicKey = "<PEER_PHONE_PUBKEY>";  allowedIPs = [ "10.100.0.3/32" ]; }
      { publicKey = "<PEER_SPARE_PUBKEY>";  allowedIPs = [ "10.100.0.4/32" ]; }
    ];
  };

  networking.nat = {
    enable = true;
    enableIPv6 = false;
    externalInterface = "wlan0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    checkReversePath = "loose";
    trustedInterfaces = [ "wg0" ];
  };
}
```

`<PEER_*_PUBKEY>` подставляются плейн-текстом — публичные части можно коммитить.

### `hosts/pi-bridge/hardware.nix`

```nix
{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=512M" "mode=1777" ];
  };

  swapDevices = lib.mkForce [ ];
}
```

### `hosts/pi-bridge/default.nix`

```nix
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    ../../modules/core.nix
    ../../modules/services/ssh.nix
    ../../modules/services/wg-bridge.nix
    ../../users/alexmcgil.nix
  ];

  networking.hostName = "pi-bridge";

  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  users.users.alexmcgil.openssh.authorizedKeys.keys = [
    "<SSH_PUBLIC_KEY>"
  ];

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  home-manager.users.alexmcgil = lib.mkForce { home.stateVersion = "25.11"; };

  system.stateVersion = "25.11";
}
```

## Безопасность и секреты

- Приватный WG-ключ Pi — только на устройстве, `/etc/nixos/secrets/wg-pi-bridge.key`, `chmod 600`
- Приватные WG-ключи клиентов — только на клиентских устройствах
- Хэш пароля alexmcgil — на устройстве, `/etc/nixos/secrets/alexmcgil.hash`
- В git коммитятся только публичные ключи peer'ов и SSH publickey
- SSH: только ключи (PasswordAuthentication = false), root запрещён (см. `modules/services/ssh.nix`)
- `security.sudo.wheelNeedsPassword = false` на Pi — это компромисс ради удобства `nixos-rebuild --target-host`. Доступ к sudo гейтится только SSH-ключом, что приемлемо для headless-сервера в домашней сети

## Деплой

### Сборка sdImage

`boot.binfmt.emulatedSystems = [ "aarch64-linux" ]` на desktop-amd → можно собрать ARM на x86_64 через qemu-user. Картридер на десктопе не нужен.

```bash
nix build .#nixosConfigurations.pi-bridge.config.system.build.sdImage
```

### Прошивка SD

Сборка `result/sd-image/nixos-sd-image-*.img.zst` копируется `scp` на ноут с Arch (у него есть картридер). На ноуте:

```bash
zstd -dc /tmp/nixos-sd-image-*.img.zst | sudo dd of=/dev/mmcblk0 bs=4M status=progress conv=fsync
```

### Первый бут и доконфигурация

1. Pi загружается, временно подключается по ethernet или через HDMI+клавиатуру.
2. Поднимается Wi-Fi: `sudo nmcli device wifi connect "<SSID>" password "<PSK>"`.
3. Создаются секреты в `/etc/nixos/secrets/`: `wg-pi-bridge.key` и `alexmcgil.hash`.
4. На роутере — DHCP-reservation для MAC Pi на `192.168.0.110` и проброс `51820/UDP → 192.168.0.110:51820`.

### Последующие обновления

С desktop-amd:

```bash
nixos-rebuild switch --flake .#pi-bridge \
  --target-host alexmcgil@192.168.0.110 \
  --use-remote-sudo \
  --use-substitutes
```

## Клиентские конфиги WG

Шаблон ноута:

```ini
[Interface]
PrivateKey = <laptop.key>
Address = 10.100.0.2/32
DNS = 192.168.0.100

[Peer]
PublicKey = <pi.pub>
Endpoint = <белый_IP_или_DDNS>:51820
AllowedIPs = 10.100.0.0/24, 192.168.0.0/24
PersistentKeepalive = 25
```

`AllowedIPs` НЕ `0.0.0.0/0` — не заворачиваем весь интернет клиента через Pi на бытовой Wi-Fi.

## Критерии приёмки

С внешнего клиента, поднявшего туннель:

- `ping 10.100.0.1` — Pi отвечает
- `ping 192.168.0.107` — desktop-amd отвечает
- `ssh alexmcgil@192.168.0.107` — SSH работает
- Moonlight: «Add Computer» по IP `192.168.0.107` стримит экран
- `curl http://192.168.0.107:5173` доступен с клиента

## Вне области задачи

- IPv6 (выключен через `enableIPv6 = false`)
- DDNS на роутере — настраивается отдельно, конфиг NixOS этим не управляет
- Защита от brute-force/fail2ban — публично доступен только UDP 51820, который требует валидный ключ, ничего не отвечает по неверному. SSH наружу не светит — он живёт только в локалке/VPN.
- Мониторинг/метрики на Pi
