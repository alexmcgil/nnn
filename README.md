# NixOS Configuration — desktop-amd

Модульная flake-based конфигурация NixOS для:
- **desktop-amd**: AMD Ryzen 9 9950X3D + NVIDIA RTX 3070, 64 GB DDR5
- **laptop-intel**: заглушка-шаблон для будущего ноутбука (Intel CPU + Intel iGPU)

---

## Структура

```
.
├── flake.nix
├── hosts/
│   ├── desktop-amd/          # AMD-десктоп
│   │   ├── default.nix       # imports всех модулей
│   │   ├── hardware.nix      # initrd, kernelModules
│   │   └── disko.nix         # разметка диска + fileSystems
│   └── laptop-intel/         # шаблон для ноутбука
├── modules/
│   ├── core.nix              # nix settings, gc, locale, sudo
│   ├── boot.nix              # systemd-boot, ядро
│   ├── network.nix           # NetworkManager, firewall
│   ├── audio.nix             # PipeWire + WirePlumber
│   ├── bluetooth.nix         # bluetooth + blueman
│   ├── fonts.nix
│   ├── security.nix          # отключение kwallet/gnome-keyring, KeePassXC
│   ├── hardware/
│   │   ├── amd-cpu.nix
│   │   ├── intel-cpu.nix
│   │   ├── nvidia.nix        # NVIDIA Wayland-friendly
│   │   └── intel-gpu.nix
│   ├── desktop/
│   │   ├── plasma.nix        # KDE Plasma 6 + SDDM Wayland
│   │   └── niri.nix          # niri + xdg-portals + quickshell
│   ├── apps/
│   │   ├── browsers.nix      # zen-browser, chromium
│   │   ├── messengers.nix    # telegram, discord, thunderbird
│   │   ├── dev.nix           # zed, idea, gcc, nodejs, rust, go…
│   │   ├── media.nix         # mpv, obs, gimp, kdenlive…
│   │   ├── productivity.nix  # libreoffice, keepassxc, dbeaver…
│   │   ├── steam.nix         # Steam + GameMode + gamescope
│   │   ├── gaming.nix        # lutris, heroic, wine, AAGL…
│   │   ├── docker.nix        # Docker + CDI для NVIDIA
│   │   ├── virt.nix          # libvirtd + virt-manager + QEMU
│   │   ├── waydroid.nix
│   │   ├── flatpak.nix
│   │   └── cli.nix           # bat, eza, fzf, yazi, zoxide…
│   └── services/
│       ├── ssh.nix
│       ├── syncthing.nix
│       ├── jellyfin.nix
│       ├── sunshine.nix
│       ├── fwupd.nix
│       ├── printing.nix      # закомментировано
│       └── openrgb.nix
└── users/
    └── alexmcgil.nix         # uid=1000, zsh, группы
```

---

## Предварительные замечания

**Диск /home НЕ форматируется.** Disko размечает только системный диск (`/dev/nvme1n1` = WD_BLACK SN850X 1TB, серийник `252020801021`).

Если по каким-то причинам `/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_252020801021` не найден в live ISO — уточнить путь командой:
```bash
ls -la /dev/disk/by-id/ | grep nvme
```
и обновить `hosts/desktop-amd/disko.nix` перед запуском.

---

## Пошаговая установка

### 1. Подготовить установочную флешку

Скачать NixOS minimal ISO (unstable/26.05):
```
https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
```
Записать на флешку (например `dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress`).

### 2. Загрузиться и перейти в root

```bash
sudo -i
```

### 3. Установить git

```bash
nix-shell -p git
```

### 4. Клонировать репозиторий

```bash
git clone <URL_ЭТОГО_РЕПОЗИТОРИЯ> /tmp/nixos
```

### 5. Создать файл с хэшем пароля (ОБЯЗАТЕЛЬНО)

Хэш хранится вне репозитория — репо публичный, хэш в git не кладём.

```bash
mkdir -p /mnt/etc/nixos/secrets
nix-shell -p mkpasswd --run 'mkpasswd -m sha-512' > /mnt/etc/nixos/secrets/alexmcgil.hash
chmod 600 /mnt/etc/nixos/secrets/alexmcgil.hash
cat /mnt/etc/nixos/secrets/alexmcgil.hash   # проверить, что файл не пустой
```

> Используй тот же пароль, что был на CachyOS — это позволит сохранить доступ к базам KeePassXC, синхронизированным через расширения браузеров.

> **Путь `/mnt/...`** — потому что disko монтирует систему в `/mnt`. После установки файл окажется в `/etc/nixos/secrets/alexmcgil.hash` на новой системе.

### 6. Проверить UID

```bash
id alexmcgil   # должно быть uid=1000(alexmcgil) gid=1000(users)
```

Если uid/gid отличаются — обновить `users/alexmcgil.nix` соответственно.

### 7. Подключить cachix для AAGL (Anime Game Launcher)

```bash
nix-shell -p cachix --run 'cachix use ezkea'
```

### 8. Запустить disko для разметки системного диска

> **ВНИМАНИЕ: disko форматирует только системный диск! /home НЕ затрагивается.**

```bash
nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko --flake '/tmp/nixos#desktop-amd'
```

### 9. Проверить монтирование /home (необязательно, для контроля)

```bash
mkdir -p /mnt/home
mount -o subvol=@home,compress=zstd:3,noatime \
  /dev/disk/by-uuid/370c05d9-1c5b-41b7-8b31-7953fe952a30 /mnt/home
ls /mnt/home   # должна быть папка alexmcgil/
```

### 10. Установка

```bash
nixos-install --flake '/tmp/nixos#desktop-amd' --no-root-passwd
```

### 11. Reboot и настройка репозитория

После перезагрузки залогиниться и скопировать конфигурацию:
```bash
cp -r /tmp/nixos ~/nixos
# или склонировать заново:
# git clone <URL> ~/nixos
cd ~/nixos
```

Ребилды системы:
```bash
sudo nixos-rebuild switch --flake '~/nixos#desktop-amd'
```

---

## Что сделать после первого логина

1. **KeePassXC** — открыть и импортировать базу данных из `/home/alexmcgil/...`
2. **SSH/GPG ключи** — они уже в `/home`, подгрузятся автоматически
3. **Steam** — залогиниться заново (machine-id изменился после переустановки)
4. **GE-Proton** — установить через `protonup-qt` (запустить из меню или терминала)
5. **Flathub** — добавить репозиторий если нужны Flatpak-приложения:
   ```bash
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```
6. **AAGL** — если нужен anime-game-launcher, запустить `anime-game-launcher` из меню
7. **noctalia-shell** — клонировать вручную если понадобится:
   ```bash
   git clone https://github.com/<noctalia-repo> ~/.config/quickshell/noctalia
   ```
   Либо дождаться пакета в nixpkgs и обновить `modules/desktop/niri.nix`.

---

## Подключение ноутбука (laptop-intel)

1. Скопировать `hosts/laptop-intel/` как основу
2. Заполнить `disko.nix` — заменить `REPLACE_WITH_SYSTEM_DISK` и `REPLACE_WITH_HOME_UUID` реальными значениями
3. Запустить `nixos-generate-config` на ноутбуке и скопировать нужные модули в `hardware.nix`
4. При необходимости раскомментировать закомментированные импорты в `default.nix`
5. Добавить в `flake.nix` если ещё не добавлено (уже добавлено в `nixosConfigurations.laptop-intel`)

---

## Полезные команды

```bash
# Проверка flake без сборки
nix flake check --no-build --impure

# Обновление inputs
nix flake update

# Ребилд с просмотром изменений
sudo nixos-rebuild switch --flake '.#desktop-amd'

# Откат к предыдущему поколению
sudo nixos-rebuild switch --rollback

# Список поколений
nix-env --list-generations --profile /nix/var/nix/profiles/system
```
