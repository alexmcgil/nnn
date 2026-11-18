# Home Manager на CachyOS

Профиль `alexmcgil@cachyos` использует общий модуль `users/desktop.nix`:
Noctalia, палитру Tokyo Night, KDE widget-style, плагины, бинды и настройки niri.
Ядро, драйвер Intel, экран входа, niri, Noctalia и порталы остаются под управлением pacman.
Настройки пользователя, Fish, MIME, игровые приложения и системные службы NixOS
в этот профиль не импортируются.
`alexmcgil@cachyos` — имя профиля, а не hostname: имя машины `lenovo` не меняется.

## Мониторы и тачпад

Общие настройки niri находятся в `users/desktop.nix`, а мониторы, рабочие столы
и зависящие от них правила приложений — в `users/niri/desktop-amd.nix`
и `users/niri/laptop-intel.nix`. NixOS выбирает профиль по `networking.hostName`,
CachyOS явно использует `laptop-intel`, независимо от своего hostname `lenovo`.
На ноутбуке столы `1–7` открываются на `eDP-1`; Obsidian направляется на `2`,
Telegram на `3`, KeePassXC на `7`. Внешние экраны располагаются автоматически.

Для ноутбука включён `dwt` (отключение тачпада при печати), выбрана постоянная
скорость курсора. Перенос курсора к фокусу и фокус по движению мыши
наследуются из общего профиля.
Применение: `nrs`. niri перечитывает настройки без выхода из сессии.
Старые именованные столы `z/x/c` могут оставаться в текущей сессии;
после переноса окон их можно убрать через `niri msg action unset-workspace-name`
на каждом таком столе либо начать новую сессию.

18 ноября 2026 в журнале niri на Lenovo обнаружены повторные сообщения
`SYNA2BA6:00 06CB:CE2D Touchpad: kernel bug: Touch jump detected and discarded`.
Это скачки координат на уровне входных событий; настройки скорости их причину
не устраняют. Отсутствие новых сообщений не доказывает исправление: libinput
ограничивает частоту логирования. См. [диагностику libinput](https://wayland.freedesktop.org/libinput/doc/1.25.0/touchpad-jumping-cursors.html).

Если рывки сохраняются, сравните работу от батареи и с зарядкой, затем на другом
установленном ядре (например, LTS). Для записи только тачпада установите
`libinput-tools` через pacman и выполните `sudo libinput record /dev/input/event11 > touchpad.yml`,
воспроизведите рывок и остановите запись через Ctrl+C. Номер event11 относится
к текущей загрузке: перед записью уточните его через `libinput list-devices`.
Запись поможет отличить сбой координат от поведения композитора; сама по себе
она не определяет, виноваты драйвер, прошивка или аппаратная часть.

## Установка

Системные команды пользователь выполняет самостоятельно:

```bash
sudo pacman -S --needed nix
sudo pacman -S --needed noctalia
sudo systemctl enable --now nix-daemon.socket
```

При первой установке запустите `nix --extra-experimental-features nix-command
store info --store daemon`, чтобы демон инициализировал `/nix/store`.

Сборка и применение из корня репозитория:

```bash
nix --extra-experimental-features 'nix-command flakes' build \
  'path:.#homeConfigurations."alexmcgil@cachyos".activationPackage' \
  --out-link result-cachyos
HOME_MANAGER_BACKUP_EXT=hm-backup ./result-cachyos/activate
```

`path:.` включает новые, ещё не отслеживаемые Git файлы. При активации
существующие конфиги сохраняются с суффиксом `.hm-backup`; если такой backup уже
есть, сначала сохраните его отдельно. Не удаляйте старые JSON-настройки Noctalia v4:
v5 использует `~/.config/noctalia/config.toml`, поэтому они не мешают миграции.

Если активация просит запустить `non-nixos-gpu-setup`, выполните показанную
команду с sudo. Она подключает графические библиотеки Mesa из Nix через
`/run/opengl-driver` и сохраняет подключение после перезагрузки. NVIDIA не нужна.
См. [инструкцию Home Manager](https://nix-community.github.io/home-manager/usage/gpu-non-nixos.html).

После первой активации выйдите из сессии niri и войдите снова. Это обновит PATH
и запустит системную Noctalia. Перед выходом сохраните открытые документы.
Автозапуск и бинды используют `/usr/bin/noctalia`: её PAM проверяет пароль
пользователя CachyOS. Версия из Nix ожидает NixOS-помощник
`/run/wrappers/bin/unix_chkpwd` и не подходит для разблокировки этого хоста.
Home Manager управляет конфигом и проверяет его системной Noctalia перед
активацией. `Super+L` блокирует сессию; общий `Mod+L` переопределён на то же
действие, поскольку в обычной сессии niri Mod — это Super.
Если старая оболочка запускалась через пользовательский `noctalia.service`,
отключите её: `systemctl --user disable --now noctalia.service`.
Цвета niri задаются в Nix; шаблон Noctalia для niri отключён, чтобы он не пытался
изменять управляемый Home Manager файл `config.kdl`.

## Обновление и откат

В Fish привычные команды сохранены: `nrs` применяет профиль Home Manager,
`nrsu` обновляет inputs, коммитит только `flake.lock` и применяет профиль.
На NixOS те же функции по-прежнему вызывают `nixos-rebuild`.
Существующая история Fish остаётся на месте.

```bash
home-manager switch -b hm-backup --flake 'path:.#alexmcgil@cachyos'
home-manager generations
```

Для отката запустите `activate` из нужной предыдущей генерации, указанной
в выводе `home-manager generations`. Версии Nix-пакетов задаёт `flake.lock`;
`pacman -Syu` их не обновляет. Обновления системных Noctalia, niri и порталов всё ещё
могут влиять на совместимость рабочего стола.
