# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

Модульная flake-based конфигурация NixOS для двух машин: `desktop-amd` (AMD Ryzen 9950X3D + NVIDIA RTX 3070, рабочая) и `laptop-intel` (заглушка-шаблон, большинство импортов закомментированы).

## Команды

```fish
# Применить текущую конфигурацию (Fish-функция; hostname определяет сама)
nrs

# Обновить inputs, закоммитить только flake.lock и применить конфигурацию
nrsu

# Проверка flake без сборки. --impure нужен, т.к. конфиг ссылается на
# secrets/alexmcgil.hash вне git
nix flake check --no-build --impure

sudo nixos-rebuild switch --rollback
```

`nrs` и `nrsu` определены в `users/rebuild-commands.nix` для Fish: на NixOS они вызывают `nixos-rebuild`, на CachyOS — `home-manager switch`. Для обычного применения предлагай `nrs`, для ручного обновления и применения — `nrsu`, вместо отдельных `nix flake update` и `nixos-rebuild switch`. `nrsu` также коммитит `flake.lock` до применения конфигурации.

**sudo не запускать через Bash-tool** — команды с `sudo` (в том числе `nrs`/`nrsu` на NixOS) отдавать пользователю в чат, чтобы он выполнил сам (в этой сессии — через `! <cmd>`).

## Обновления и временные workaround

- `flake.lock` обновляет пользователь вручную через `nrsu`. Не запускай обновление сам без прямого запроса и не создавай автоматические PR.
- После обновления смотри результат `.github/workflows/nix-check.yml` отдельно для `desktop-amd` и `laptop-intel`: workflow делает evaluation и `nix build --dry-run --no-link`, без сборки системы. При локальной проверке используй те же команды из workflow.
- Проверяй предупреждения `WORKAROUND` в логах и реестр `docs/workarounds.md`. Новое временное исправление отмечай рядом с кодом уникальным ID, причиной, версией и ссылкой upstream (если известны), условием удаления; добавляй ID в реестр. Если обход зависит от конкретной версии пакета или ревизии input, добавляй `lib.warnIf` с предложением пересмотреть исправление при её изменении.
- Предупреждение или успешный CI не доказывают, что workaround можно удалить. Сначала проверь штатный пакет без него, при необходимости сборку и работу приложения на целевой машине. Удаляй код, комментарий и строку реестра вместе; не меняй системное поведение только ради очистки.

## Архитектура

- **`flake.nix`** — `mkHost` собирает каждый хост. Через `specialArgs` во все модули пробрасываются:
  - `inputs` — все flake-инпуты (используются как `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}` или `inputs.<name>.nixosModules.*`).
  - `pkgs-stable` — nixpkgs 26.05 с `allowUnfree`. Применяется точечно там, где unstable ломает пакет (сейчас `lutris`, `bottles` в `modules/apps/gaming.nix`). Модуль, которому он нужен, объявляет `pkgs-stable` в сигнатуре.
  - Общие nixosModules (disko, home-manager, niri, aagl, zapret) подключаются в `mkHost`, поэтому в самих модулях их импортировать не надо.
- **`hosts/<host>/default.nix`** — единственная точка, перечисляющая `imports` модулей + задаёт `networking.hostName` и `system.stateVersion`. `hardware.nix` (initrd/kernelModules) и `disko.nix` (разметка + fileSystems) — специфика железа.
- **`modules/`** — по категориям: корневые (`core`, `boot`, `network`, `audio`, …), `hardware/`, `desktop/`, `apps/`, `services/`. Один модуль = одна тема, включается/выключается строкой в host `default.nix`.
- **`users/alexmcgil.nix`** — системный пользователь (`mutableUsers = false`, uid 1000, shell fish) + подключает home-manager. **`users/alexmcgil-home.nix`** — весь home-manager конфиг (noctalia, plasma-manager, niri settings, git). `users/fish.nix` импортируется оттуда.

## Ключевые соглашения и подводные камни

- **Комментарии и коммиты — на русском.** Модули густо документированы: почему выбран тот или иной вариант, какие грабли обходятся. При изменениях сохраняй этот стиль и обновляй комментарий, если меняешь обоснование.
- **Секрет пароля вне git.** `users/alexmcgil.nix` читает `hashedPasswordFile = "/etc/nixos/secrets/alexmcgil.hash"`. Репозиторий публичный — хэши/секреты в git не класть.
- **KDE/Qt темизация разделена** (`alexmcgil-home.nix`): `plasma-manager` управляет ТОЛЬКО иконками и widget-style; цвета (Tokyo Night) задаёт noctalia через templates qt/gtk/kcolorscheme. `overrideConfig` у plasma **не включать** — иначе конфликт за `[Colors:*]`.
- **Noctalia уже переведён на v5.** История миграции: `docs/noctalia-v5-migration.md`. Не восстанавливай старый pin `legacy-v4` без отдельной причины.
- **niri + NVIDIA + Wayland** тонко настроены в `modules/desktop/niri.nix` (portal-бэкенды, `GSK_RENDERER=gl` для gnome-portal, отсутствие `QT_QPA_PLATFORMTHEME=kde` чтобы не ронять quickshell). Правки env/portal там сверять с существующими комментариями.
- Cachix-кэши объявлены дважды: в `flake.nix` → `nixConfig` (для `nix build`/установки) и в `modules/core.nix` → `nix.settings.substituters` (для системы). При добавлении кэша обновлять оба места.
- Планы и спеки Superpowers лежат в `docs/superpowers/{plans,specs}/`.
