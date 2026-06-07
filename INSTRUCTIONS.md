# Задача: создать модульный репозиторий конфигурации NixOS

Создай в текущей директории flake-based репозиторий NixOS. Все файлы должны быть рабочими и проходить `nix flake check` без ошибок (учитывая, что некоторые `unfree` пакеты потребуют `--impure` или `NIXPKGS_ALLOW_UNFREE=1`).

## Контекст пользователя

- **Имя пользователя:** alexmcgil
- **UID/GID:** 1000/1000 (это критично — на /home лежат файлы с этим UID, перенесённые с CachyOS)
- **Hostname текущего ПК:** desktop-amd
- **Железо текущего ПК:** AMD Ryzen 9 9950X3D, NVIDIA RTX 3070, 64 GB DDR5, ASUS ROG STRIX B650E-F GAMING WIFI
- **Будущий ПК:** Intel CPU + Intel iGPU (структура должна позволять легко добавить host `laptop-intel`)
- **Системный диск:** `/dev/nvme1n1` (WD_BLACK SN850X 1TB, серийник 252020801021) — будет размечен disko с нуля
- **Диск с /home:** `/dev/nvme0n1` (WD_BLACK SN850X 2TB, UUID `370c05d9-1c5b-41b7-8b31-7953fe952a30`, btrfs, subvol `@home`) — НЕ ТРОГАТЬ, импортировать как existing fileSystems
- **SATA SSD под медиа:** UUID `d6ecfcd5-2703-41bf-9301-10c403b6fb0c`, ext4, монтировать в `/mnt/media`
- **HDD:** пока не монтировать
- **DE:** основной — niri + noctalia-shell, запасной — KDE Plasma 6 (SDDM)
- **Часовой пояс:** Europe/Moscow, локаль `ru_RU.UTF-8`, раскладка консоли `us`
- **Файловая система:** btrfs с subvolumes (`@`, `@nix`, `@log`, `@snapshots`), compression `zstd:3`, опции `noatime,ssd,discard=async`
- **Bootloader:** systemd-boot, ESP 1 GB на /boot
- **Ядро:** `pkgs.linuxPackages_latest`
- **stateVersion:** `26.05` (можно подключить unstable репозиторий)
- **Менеджер паролей:** ТОЛЬКО KeePassXC. KWallet и GNOME Keyring должны быть выключены/исключены (включая автоподнятие как PAM-модуля и автостарт в KDE).

## Структура репозитория

```
.
├── flake.nix
├── flake.lock                     (создаст nix flake update)
├── README.md                      (как пользоваться, install steps)
├── .gitignore                     (result, *.qcow2, *.img)
├── hosts/
│   ├── desktop-amd/
│   │   ├── default.nix
│   │   ├── hardware.nix
│   │   └── disko.nix
│   └── laptop-intel/              (заглушка-шаблон, можно скопировать из desktop-amd)
│       ├── default.nix
│       ├── hardware.nix
│       └── disko.nix
├── modules/
│   ├── core.nix                   (nix settings, gc, locale, time, sudo, базовые CLI)
│   ├── boot.nix                   (systemd-boot, kernel, plymouth опционально)
│   ├── network.nix                (NetworkManager + плагины VPN, firewall NixOS)
│   ├── audio.nix                  (pipewire+wireplumber+alsa+pulse, rtkit)
│   ├── bluetooth.nix              (hardware.bluetooth + blueman)
│   ├── fonts.nix
│   ├── security.nix               (отключить gnome-keyring + KWallet полностью; PAM без kwallet)
│   ├── hardware/
│   │   ├── amd-cpu.nix
│   │   ├── intel-cpu.nix
│   │   ├── nvidia.nix             (драйвер + nvidia-container-toolkit + Wayland env)
│   │   └── intel-gpu.nix
│   ├── desktop/
│   │   ├── plasma.nix             (KDE Plasma 6 + SDDM Wayland, исключить kwallet/elisa/khelpcenter)
│   │   └── niri.nix               (niri + greetd опционально, либо запуск через SDDM-сессию; portals)
│   ├── apps/
│   │   ├── browsers.nix           (zen-browser, chromium)
│   │   ├── messengers.nix         (tdesktop, discord, teams-for-linux, thunderbird)
│   │   ├── dev.nix                (zed-editor, jetbrains.idea-ultimate, obsidian, gcc, clang, cmake, meson, ninja, pkg-config, nodejs_22, jdk21, gradle, python313, rustup, go, direnv, nix-direnv)
│   │   ├── media.nix              (mpv, vlc, obs-studio, audacity, gimp3, krita, kdenlive, feishin, haruna, qbittorrent)
│   │   ├── productivity.nix       (libreoffice-fresh, keepassxc, mongodb-compass, postman, dbeaver-bin)
│   │   ├── steam.nix              (programs.steam + gamescope + gamemode + mangohud + protonup-qt)
│   │   ├── gaming.nix             (lutris, heroic, prismlauncher, winetricks, protontricks, umu-launcher, wineWowPackages.stagingFull, aagl)
│   │   ├── docker.nix             (virtualisation.docker + storageDriver btrfs + autoPrune; докинуть nvidia-container-toolkit)
│   │   ├── virt.nix               (libvirtd + virt-manager + qemu_full + edk2-ovmf)
│   │   ├── waydroid.nix           (virtualisation.waydroid.enable)
│   │   ├── flatpak.nix            (services.flatpak.enable)
│   │   └── cli.nix                (bat, eza, fd, ripgrep, ripgrep-all, fzf, zoxide, jq, go-yq, btop, glances, duf, ncdu, tealdeer, sd, tree, unzip, p7zip, unrar, rsync, rclone, tmux, micro, vim, yazi, fastfetch, inxi, parallel, pv, imagemagick, lsof, plocate, nmap, iperf3, tcpdump, socat, netcat-openbsd, bind, nvme-cli, smartmontools, pciutils, usbutils, dmidecode, hwinfo, ddcutil, brightnessctl, playerctl, wl-clipboard, cliphist, wtype, ydotool, wlr-randr, grim, slurp, swappy, fuzzel, mako, waybar, cava, matugen, quickshell)
│   └── services/
│       ├── ssh.nix                (services.openssh.enable, без password-auth для root)
│       ├── syncthing.nix          (per-user, user=alexmcgil, configDir в /home)
│       ├── jellyfin.nix           (services.jellyfin.enable, openFirewall=true)
│       ├── sunshine.nix           (services.sunshine.enable + capSysAdmin/openFirewall)
│       ├── fwupd.nix
│       ├── printing.nix           (CUPS, по умолчанию disabled — закомментировано)
│       └── openrgb.nix            (services.hardware.openrgb.enable)
└── users/
    └── alexmcgil.nix                 (users.users.alexmcgil с uid=1000, group="users", hashedPassword placeholder, extraGroups: wheel, networkmanager, video, audio, input, render, docker, libvirt, plugdev, kvm)
```

## flake.nix — inputs

```nix
inputs = {
  nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

  home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  disko        = { url = "github:nix-community/disko";        inputs.nixpkgs.follows = "nixpkgs"; };
  niri         = { url = "github:sodiboo/niri-flake";         inputs.nixpkgs.follows = "nixpkgs"; };
  zen-browser  = { url = "github:0xc000022070/zen-browser-flake"; inputs.nixpkgs.follows = "nixpkgs"; };
  aagl         = { url = "github:ezKEa/aagl-gtk-on-nix";      inputs.nixpkgs.follows = "nixpkgs"; };
};
```

`nixosConfigurations.desktop-amd` собирается через хелпер `mkHost`, импортирующий disko, niri, home-manager, aagl и host-папку. Передавай `specialArgs = { inherit inputs; }`.

## hosts/desktop-amd/disko.nix — точные требования

- `disk.system.device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_252020801021"` (если такого by-id нет — fallback на `/dev/nvme1n1`, прописать оба варианта в README).
- GPT, partitions:
  - `ESP` 1 GiB, type `EF00`, vfat, mount `/boot`, options `umask=0077`.
  - `root` 100%, btrfs label `nixos`, subvolumes:
    - `@` → `/`
    - `@nix` → `/nix`
    - `@log` → `/var/log`
    - `@snapshots` → `/.snapshots`
  - Все mountOptions: `["compress=zstd:3" "noatime" "ssd" "discard=async"]` плюс `subvol=...`.
- Дополнительно вне disko, через `fileSystems`:
  - `/home` → UUID `370c05d9-1c5b-41b7-8b31-7953fe952a30`, btrfs, options `subvol=@home,compress=zstd:3,noatime,ssd,discard=async`.
  - `/mnt/media` → UUID `d6ecfcd5-2703-41bf-9301-10c403b6fb0c`, ext4, options `defaults,nofail`.
  - `/tmp` → tmpfs 16G.

## modules/security.nix — отключение конкурентов KeePassXC

```nix
{ lib, pkgs, config, ... }:
{
  # Никакого GNOME Keyring
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  programs.seahorse.enable = lib.mkForce false;

  # KWallet выключаем как хранилище и PAM-интеграцию
  security.pam.services.login.enableKwallet  = false;
  security.pam.services.sddm.enableKwallet   = false;
  security.pam.services.greetd.enableKwallet = false;

  # KeePassXC + интеграция с браузерами
  environment.systemPackages = with pkgs; [ keepassxc ];

  # Polkit
  security.polkit.enable = true;
}
```

В `modules/desktop/plasma.nix` исключи KWallet из Plasma:
```nix
environment.plasma6.excludePackages = with pkgs.kdePackages; [
  kwallet kwallet-pam kwalletmanager
  elisa khelpcenter
];
```

## modules/hardware/nvidia.nix — Wayland-friendly

- `services.xserver.videoDrivers = ["nvidia"]`
- `hardware.graphics.enable = true; hardware.graphics.enable32Bit = true;`
- `hardware.nvidia` с `modesetting.enable = true`, `open = false`, `nvidiaSettings = true`, `powerManagement.enable = true`, `package = config.boot.kernelPackages.nvidiaPackages.stable`.
- `boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];`
- `environment.sessionVariables`:
  ```
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  NVD_BACKEND = "direct";
  ```
- `hardware.nvidia-container-toolkit.enable = true;`

## modules/desktop/niri.nix — детали

- Импорт модуля из `inputs.niri.nixosModules.niri`, включить `programs.niri.enable = true`.
- xdg-portals: `xdg.portal.enable = true; xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];`
- Пакеты для сессии: `waybar fuzzel mako wl-clipboard cliphist xwayland-satellite quickshell qt6.qtwayland`
- Комментарий в файле, что noctalia-shell на момент написания может отсутствовать в nixpkgs — оставить TODO с инструкцией клонировать в `~/.config/quickshell/noctalia` либо подключить отдельный flake-input при появлении.

## modules/apps/gaming.nix

- `programs.steam.enable = true; programs.steam.gamescopeSession.enable = true; programs.steam.remotePlay.openFirewall = true;`
- `programs.gamemode.enable = true;`
- `hardware.steam-hardware.enable = true;`
- Импортировать AAGL: `inputs.aagl.nixosModules.default;` и `programs.anime-game-launcher.enable = true;` (плюс соответствующие cachix-инструкции в README).
- Пакеты: `lutris heroic prismlauncher mangohud goverlay protontricks protonup-qt winetricks wineWowPackages.stagingFull umu-launcher`.

## modules/apps/docker.nix

```nix
virtualisation.docker = {
  enable        = true;
  storageDriver = "btrfs";
  autoPrune.enable = true;
  daemon.settings = { features = { cdi = true; }; };  # для NVIDIA через CDI
};
environment.systemPackages = with pkgs; [ docker-compose lazydocker ];
```

## modules/services/sunshine.nix

```nix
services.sunshine = {
  enable = true;
  autoStart = false;
  capSysAdmin = true;
  openFirewall = true;
};
```

## modules/services/jellyfin.nix

```nix
services.jellyfin = {
  enable = true;
  openFirewall = true;
  user = "jellyfin";
};
```

## users/alexmcgil.nix

```nix
{ pkgs, ... }:
{
  users.mutableUsers = false;
  users.users.alexmcgil = {
    isNormalUser = true;
    uid    = 1000;
    group  = "users";
    home   = "/home/alexmcgil";
    shell  = pkgs.zsh;
    extraGroups = [
      "wheel" "networkmanager" "video" "audio" "input"
      "render" "docker" "libvirtd" "plugdev" "kvm"
    ];
    # ВАЖНО: сгенерируй командой:
    #   mkpasswd -m sha-512
    # и подставь сюда. Желательно тот же пароль, что был на CachyOS,
    # чтобы расшифровались сохранённые keepass-БД браузерных дополнений.
    hashedPassword = "REPLACE_WITH_OUTPUT_OF_mkpasswd";
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = true;
}
```

## modules/core.nix — обязательно

- `nix.settings.experimental-features = ["nix-command" "flakes"];`
- `nix.settings.auto-optimise-store = true;`
- `nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };`
- `nixpkgs.config.allowUnfree = true;`
- `time.timeZone = "Europe/Moscow";`
- `i18n.defaultLocale = "ru_RU.UTF-8";`
- `i18n.extraLocaleSettings` дополнительный для русских форматов даты/чисел.
- Базовые CLI: `git curl wget htop btop tree file unzip ripgrep fd jq nvme-cli btrfs-progs smartmontools`.

## modules/network.nix

- `networking.networkmanager.enable = true;`
- Плагины: `networkmanager-openvpn`, `networkmanager-openconnect`.
- `networking.firewall.enable = true;`
- `services.openssh.enable = true;`

## hosts/desktop-amd/default.nix — список impotrs

```nix
imports = [
  ./hardware.nix
  ./disko.nix

  ../../modules/core.nix
  ../../modules/boot.nix
  ../../modules/network.nix
  ../../modules/audio.nix
  ../../modules/bluetooth.nix
  ../../modules/fonts.nix
  ../../modules/security.nix

  ../../modules/desktop/plasma.nix
  ../../modules/desktop/niri.nix

  ../../modules/apps/cli.nix
  ../../modules/apps/browsers.nix
  ../../modules/apps/messengers.nix
  ../../modules/apps/dev.nix
  ../../modules/apps/media.nix
  ../../modules/apps/productivity.nix
  ../../modules/apps/steam.nix
  ../../modules/apps/gaming.nix
  ../../modules/apps/docker.nix
  ../../modules/apps/virt.nix
  ../../modules/apps/waydroid.nix
  ../../modules/apps/flatpak.nix

  ../../modules/services/ssh.nix
  ../../modules/services/syncthing.nix
  ../../modules/services/jellyfin.nix
  ../../modules/services/sunshine.nix
  ../../modules/services/fwupd.nix
  ../../modules/services/openrgb.nix

  ../../users/alexmcgil.nix
];

system.stateVersion = "26.05";
```

## hosts/laptop-intel/* — заглушка

Создай идентичную структуру, но в hardware.nix импортируй `intel-cpu.nix` + `intel-gpu.nix` (вместо amd+nvidia), в disko.nix оставь TODO-комментарии «заполнить device/UUID при установке», в default.nix отключи модули `gaming.nix`, `sunshine.nix`, `jellyfin.nix`, `waydroid.nix` (закомментируй их в imports — пользователь сам решит). В flake.nix зарегистрируй `nixosConfigurations.laptop-intel`.

## modules/fonts.nix

```nix
fonts.packages = with pkgs; [
  noto-fonts noto-fonts-emoji noto-fonts-cjk-sans
  dejavu_fonts liberation_ttf
  fira-code fira-sans inter open-sans
  jetbrains-mono cantarell-fonts
  twitter-color-emoji
  nerd-fonts.jetbrains-mono
  nerd-fonts.fantasque-sans-mono
  nerd-fonts.hack
  nerd-fonts.meslo-lg
  nerd-fonts.symbols-only
  material-symbols
  wqy-zenhei
  adwaita-fonts
];
fonts.fontconfig.defaultFonts = {
  serif     = [ "Noto Serif" ];
  sansSerif = [ "Inter" "Noto Sans" ];
  monospace = [ "JetBrains Mono" "JetBrainsMono Nerd Font" ];
};
```

## README.md

В README напиши **по-русски**, пошаговый сценарий установки:

1. Подготовить флешку с NixOS minimal ISO (26.05 unstable, ссылка).
2. Загрузиться, перейти в root: `sudo -i`.
3. Включить flakes: `nix-env -iA nixos.git`, либо `nix-shell -p git`.
4. Склонировать этот репозиторий в `/tmp/nixos`.
5. ВАЖНО: сгенерировать `hashedPassword`:
   ```
   nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
   ```
   и вставить в `users/alexmcgil.nix`.
6. ВАЖНО: проверить, что текущий `id alexmcgil` на CachyOS = `1000:1000` (если другое — обновить uid/group в `users/alexmcgil.nix`).
7. Cachix для AAGL:
   ```
   nix-shell -p cachix --run 'cachix use ezkea'
   ```
8. Запустить disko (только для системного диска):
   ```
   nix --experimental-features 'nix-command flakes' \
     run github:nix-community/disko -- \
     --mode disko --flake '/tmp/nixos#desktop-amd'
   ```
9. Подмонтировать /home для проверки:
   ```
   mkdir -p /mnt/home
   mount -o subvol=@home,compress=zstd:3,noatime \
     /dev/disk/by-uuid/370c05d9-1c5b-41b7-8b31-7953fe952a30 /mnt/home
   ls /mnt/home    # должна быть папка alexmcgil/
   ```
10. Установка:
    ```
    nixos-install --flake '/tmp/nixos#desktop-amd' --no-root-passwd
    ```
11. Reboot, копировать репо в `~/nixos`, инициализировать git, делать ребилды:
    ```
    sudo nixos-rebuild switch --flake '~/nixos#desktop-amd'
    ```

В README отдельный раздел «Что сделать после первого логина»:
- Открыть KeePassXC, импортировать БД.
- Импортировать SSH/GPG ключи (они уже в /home).
- В Steam залогиниться (machine-id поменялся).
- Установить GE-Proton через protonup-qt.
- Если нужен AAGL — открыть `anime-game-launcher`.
- Клонировать noctalia-shell в `~/.config/quickshell/noctalia` если оно понадобится.

## .gitignore

```
result
result-*
*.qcow2
*.img
.direnv/
```

## Чек-лист самопроверки агента

После генерации файлов выполни:

1. `nix flake check --no-build --impure` (если нет mkpasswd — заглушка пройдёт)
2. `nix fmt` если есть formatter, либо `nixpkgs-fmt .`
3. Убедиться, что во всех модулях правильный сигнатура `{ config, lib, pkgs, inputs, ... }:` где это нужно.
4. Проверить, что `inputs` пробрасывается через `specialArgs` в flake.nix.
5. Все `imports` пути относительные и правильные.
6. Никаких ссылок на `<nixpkgs>` (только flake-style).
7. UUID и device-paths именно те, что указаны в контексте.
8. KeePassXC присутствует ровно один раз, kwallet/seahorse/gnome-keyring явно отключены.

## Важные предостережения

- Не добавляй `home-manager` user-конфиг (`home.nix`) — пользователь его опишет позже отдельно. Просто подключи модуль home-manager к NixOS, чтобы было готово.
- Не пиши `disko` для диска `nvme0n1` (там /home — ничего не должно его форматировать).
- Не включай Plasma и niri одновременно как «autologin» — оставить выбор сессии в SDDM.
- `kernelPackages = pkgs.linuxPackages_latest;` — НЕ `linuxPackages_cachyos` или подобного.
- Не импортируй `proton-cachyos` — пользователь будет ставить GE-Proton через protonup-qt.

В конце генерации выведи дерево `tree -L 3` репозитория и текст команды для установки.
