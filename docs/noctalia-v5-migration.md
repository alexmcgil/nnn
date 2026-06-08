# Миграция noctalia v4 → v5

> Статус: **отложено**. Сейчас запинены на `legacy-v4` (см. `flake.nix`, input `noctalia`).
> Этот файл — конспект находок на момент 2026-06-09, чтобы вернуться к переходу позже.

## Почему отложили

`routine: update flake.lock` (коммит `e24a96d`) утянул noctalia с v4 на **v5.0.0-alpha**,
и `nrsu` упал с:

```
error: The option `home-manager.users.alexmcgil.programs.noctalia-shell' does not exist.
```

v5 — это **переписанный с нуля** шелл (Quickshell/QML → C++/OpenGL ES), официально
в **early/alpha** («Expect breaking configuration and behavior changes»). Формат конфига
и схема полностью другие, поэтому механического переноса нашего ~270-строчного конфига нет.

Решение: запинить input на ветку `legacy-v4` (остаёмся на v4 + багфиксы, `nix flake update`
не прыгает на v5). Последний v4-релиз на момент записи — `v4.7.7`.

## Что меняется в v5 (суть)

| | v4 (сейчас) | v5 |
|---|---|---|
| HM-модуль | `programs.noctalia-shell` | `programs.noctalia` |
| NixOS-модуль | `services.noctalia-shell` | — |
| Бинарь | `noctalia-shell` | `noctalia` (mainProgram) |
| Формат конфига | JSON (`settings.json`, `colors.json`, `plugins.json`) | TOML (`config.toml`, можно дробить на несколько `*.toml`) |
| Цвета | `colors` (опция модуля) | `customPalettes.<name>` → `palettes/<name>.json` |
| Плагины | `plugins` (опция модуля, 15 шт.) | **Luau scripted widgets** — другая система |
| IPC | `noctalia-shell ipc call launcher toggle` | `noctalia msg panel-toggle launcher` |
| GUI-оверрайды | — | `~/.local/state/noctalia/settings.toml` (writable-слой, работает на NixOS) |

## Новый HM-модуль v5 (`programs.noctalia`)

Опции всего три значимые:

- `enable`
- `package` — есть `lib.mkDefault` в `homeModules.default` (явно ставить НЕ обязательно)
- `systemd.enable` + `systemd` (опц.)
- `settings` — attrset / TOML-строка / путь → пишется в `~/.config/noctalia/config.toml`
- `customPalettes.<name>` — attrset/JSON → `~/.config/noctalia/palettes/<name>.json`

Модуль больше **не** управляет баром/виджетами/плагинами через типизированные опции —
`settings` это просто свободный attrset, который сериализуется в TOML.

## Что переносится чисто (1:1)

### 1. Палитра Tokyo Night
Роли цветов в v5 **те же** (`mPrimary`, `mOnPrimary`, `mSecondary`, `mTertiary`, `mError`,
`mSurface`, `mOnSurface`, `mSurfaceVariant`, `mOnSurfaceVariant`, `mOutline`, `mShadow`,
`mHover`, `mOnHover`). Наш блок `colors` → `customPalettes."Tokyo Night"` практически копипастой.

Особенности v5-палитры:
- структура `{ dark = { ...роли... }; light = { ... }; }` (если `light` нет — `dark` для обоих)
- можно добавить объект `terminal` (background/foreground/cursor/normal/bright ANSI) — было бы
  улучшением (у нас сейчас терминальных цветов в палитре нет)
- папка переехала: v4 `colorschemes/` → v5 `palettes/`

```nix
programs.noctalia.customPalettes."Tokyo Night" = {
  dark = {
    mPrimary = "#7aa2f7"; mOnPrimary = "#16161e";
    mSecondary = "#bb9af7"; mOnSecondary = "#16161e";
    mTertiary = "#9ece6a"; mOnTertiary = "#16161e";
    mError = "#f7768e"; mOnError = "#16161e";
    mSurface = "#1a1b26"; mOnSurface = "#c0caf5";
    mSurfaceVariant = "#24283b"; mOnSurfaceVariant = "#9aa5ce";
    mOutline = "#353d57"; mShadow = "#15161e";
    mHover = "#9ece6a"; mOnHover = "#16161e";
  };
};
```

### 2. Выбор темы (`config.toml`)
```toml
[theme]
source = "custom"
custom_palette = "Tokyo Night"
mode = "dark"
```

### 3. Часть глобальных `[shell]`-настроек (ключи известны из доков)
Маппинг наших v4-настроек:

| v4 (`settings.general` и пр.) | v5 `[shell]` |
|---|---|
| `general.avatarImage` | `avatar_path = "~/Pictures/avatar.png"` |
| `general.passwordChars` | `password_style = "random"` (default/random) |
| `general.telemetryEnabled` | `telemetry_enabled` |
| `appLauncher.enableClipboardHistory` | `clipboard_enabled = true` |
| (шрифт) | `font_family` |
| `general.enableLockScreenMediaControls` | → `[lockscreen]`-секция |

Доп. полезные секции v5: `[shell.animation]`, `[shell.shadow]`, `[shell.panel]`
(`transparency_mode`, `borders`, `launcher_*`), `[shell.screenshot]`
(`directory`, `filename_pattern`), `[shell.mpris].blacklist`, `[osd]`, `[lockscreen]`
(`blurred_desktop`, `blur_intensity`, `wallpaper`), `[keybinds]`,
`[shell.session]` + `[[shell.session.actions]]`.

> ⚠️ В v5 `super`/`win`/`meta` в `[keybinds]` дают ошибку парсинга конфига — учитывать.

## Что НЕ переносится механически (делать через GUI → export)

- `bar.widgets` (left/center/right) — раскладка бара, в v5 полностью другая схема (snake_case)
- `dock`, `controlCenter.cards`, `desktopWidgets` / `monitorWidgets`
- **Плагины** (assistant-panel, clipper, mini-docker, arch-updater, slowbongo, ssh-sessions,
  syncthing-status, usb-drive-manager, screen-toolkit, privacy-indicator, network-manager-vpn,
  kaomoji-provider, mpvpaper, zed-provider …) → в v5 это Luau scripted widgets; часть под v5
  может ещё не существовать
- `templates.activeTemplates` (btop/cava/discord/gtk/qt/kcolorscheme/zed/kitty/niri/telegram/
  zenBrowser) → в v5 «app theming», другой механизм

### Рекомендованный путь для этих частей
Доки v5 сами советуют для дотфайлов:
1. поставить v5 с минимальным конфигом (палитра + тема + глобалки)
2. донастроить бар/виджеты/плагины в **GUI** (пишется в `~/.local/state/noctalia/settings.toml`)
3. `noctalia config export` (merged user config) → положить TOML в Nix
   (`noctalia config export full` — полный эффективный конфиг для инспекции)
   `noctalia config validate` — проверка синтаксиса/ключей

## Правки вне noctalia-конфига (niri)

В `users/alexmcgil-home.nix` при переходе на v5 поменять:

- `spawn-at-startup`: `{ command = [ "noctalia-shell" ]; }` → `[ "noctalia" ]`
  (или `[ "noctalia" "-d" ]` для daemon)
- бинд `Mod+Space`:
  `[ "noctalia-shell" "ipc" "call" "launcher" "toggle" ]`
  → `[ "noctalia" "msg" "panel-toggle" "launcher" ]`
- комментарии про `noctalia-shell` по тексту

IPC v5 (через `noctalia msg`): `panel-toggle launcher` / `panel-toggle control-center`,
`settings-toggle`, `volume-up/down/mute`, `brightness-up/down`, `wallpaper-set <monitor> <path>`,
плюс bar/dock/desktop-widgets/notifications/theme/lock. Полный список:
`docs.noctalia.dev/v5/ipc/shell-and-ui/`.

## Чек-лист перехода (когда v5 стабилизируется)

- [ ] `flake.nix`: вернуть input `noctalia` на `github:noctalia-dev/noctalia-shell` (main)
- [ ] `nix flake update noctalia`
- [ ] переименовать `programs.noctalia-shell` → `programs.noctalia`
- [ ] `colors` → `customPalettes."Tokyo Night"` (+ опц. `terminal`)
- [ ] `settings` → `config.toml`: `[theme]` + перенос глобалок `[shell]`
- [ ] niri: бинарь `noctalia` + IPC `msg panel-toggle launcher`
- [ ] `noctalia config validate`
- [ ] донастроить бар/плагины в GUI → `noctalia config export` → в Nix
- [ ] проверить layer-rule `^noctalia-overview` (namespace мог измениться в v5)

## Ссылки

- Конфиг (формат, load order, export/validate): https://docs.noctalia.dev/v5/configuration/
- Shell-настройки: https://docs.noctalia.dev/v5/configuration/shell/
- Палитра/цвета: https://docs.noctalia.dev/v5/theming/palette/
- IPC: https://docs.noctalia.dev/v5/ipc/shell-and-ui/
- Scripted widgets (Luau): https://docs.noctalia.dev/v5/bar/scripted-widgets/
</content>
</invoke>
