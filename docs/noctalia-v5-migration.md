# Миграция Noctalia v4 → v5

> Статус: **завершено 2026-09-05**. Конфигурация переведена на стабильную
> Noctalia 5.0.1 из текущего nixpkgs.

## Почему миграция снова стала возможна

В июне 2026 года `main` у Noctalia указывал на несовместимую alpha-версию v5:
Quickshell/QML был переписан на C++/OpenGL ES, JSON-конфиг заменён на TOML, а
старые QML-плагины перестали загружаться. Поэтому input временно был закреплён
на `legacy-v4`.

К сентябрю v5 вышла в стабильный релиз, а используемый Home Manager получил
нативный модуль `programs.noctalia`. Отдельный flake-input больше не нужен:
пакет и модуль берутся из уже согласованного набора nixpkgs/Home Manager.

## Что изменено

| Область | v4 | v5 |
|---|---|---|
| Home Manager | `programs.noctalia-shell` | `programs.noctalia` |
| Бинарь | `noctalia-shell` | `noctalia` |
| Конфиг | JSON | TOML из Nix-attrset |
| Палитра | `colors` | `customPalettes."Tokyo Night"` |
| IPC | `ipc call launcher toggle` | `msg panel-toggle launcher` |
| Плагины | QML | Luau |
| Niri backdrop | `noctalia-overview*` | `noctalia-backdrop` |

Сохранены точные цвета Tokyo Night, тема GTK/Qt/KDE/Niri и приложений, обои с
авторотацией, lockscreen, weather, DDC/CI, dock, раскладка бара и desktop
widgets. Конфиг проверяется нативным `noctalia config validate` при сборке
Home Manager.

## Плагины

Прямо перенесены или заменены:

| v4 | v5 |
|---|---|
| `kaomoji-provider` | `noctalia/kaomoji` |
| `mini-docker` | `8bury/mini-docker` |
| `mpvpaper` | `noctalia/mpvpaper` |
| `privacy-indicator` | встроенный `privacy` |
| `screen-toolkit` | `alexander/screen-toolkit` |
| `slowbongo` | `noctalia/bongocat` |
| `ssh-sessions` | `cleboost/ssh-launcher` |
| `syncthing-status` | `rylos/syncthing` |
| `usb-drive-manager` | `aristides/udiskie` |
| `zed-provider` | `cleboost/zed-provider` |
| `arch-updater` | `avivbintangaringga/nix-monitor` |
| `clipper` | встроенный clipboard + `noctalia/notes` |
| translator из `assistant-panel` | `noctalia/translator` |

Не перенесены:

- `network-manager-vpn` — требует отдельной настройки под текущую VPN-схему;
- AI-часть `assistant-panel` — прямого совместимого аналога нет;
- отключённые `model-usage` и старый `video-wallpaper`.

Community-плагины обновляются самим Noctalia (`plugins.auto_update = "all"`).
Они исполняются без sandbox, поэтому список оставлен явным в декларативном
конфиге.

## Особенности проверки

Build-time валидатор не загружает runtime-каталог плагинов из
`~/.local/state/noctalia/plugins/`. Поэтому при первой сборке он предупреждает,
что Luau-типы виджетов и их `plugin_settings` пока неизвестны. Это ожидаемые
предупреждения; TOML и вся встроенная схема проходят проверку. После первого
запуска Noctalia материализует включённые плагины из official/community sources.

## После переключения системы

1. Выполнить `sudo nixos-rebuild switch --flake '.#desktop-amd'`.
2. Перезапустить сессию Niri или запустить `noctalia` вручную.
3. Проверить `noctalia plugin list` и при необходимости открыть
   Settings → Plugins для диагностики отдельного плагина.
4. Если значения из Nix неожиданно перекрыты GUI, проверить
   `~/.local/state/noctalia/settings.toml`: writable-слой загружается последним.

## Актуальные ссылки

- [Конфигурация](https://docs.noctalia.dev/noctalia/configuration/)
- [Палитры](https://docs.noctalia.dev/noctalia/theming/palette/)
- [IPC и бинды](https://docs.noctalia.dev/noctalia/ipc/)
- [Плагины](https://docs.noctalia.dev/noctalia/plugins/)
