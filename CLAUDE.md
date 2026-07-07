# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Модульная flake-based конфигурация NixOS для двух машин: `desktop-amd` (AMD Ryzen 9950X3D + NVIDIA RTX 3070, рабочая) и `laptop-intel` (заглушка-шаблон, большинство импортов закомментированы).

## Команды

```bash
# Ребилд системы (host обязателен — hostname не выводится автоматически)
sudo nixos-rebuild switch --flake '.#desktop-amd'

# Проверка flake без сборки. --impure нужен, т.к. конфиг ссылается на
# secrets/alexmcgil.hash вне git
nix flake check --no-build --impure

nix flake update              # обновить все inputs
sudo nixos-rebuild switch --rollback
```

**sudo не запускать через Bash-tool** — команды с `sudo` (rebuild и пр.) отдавать пользователю в чат, чтобы он выполнил сам (в этой сессии — через `! <cmd>`).

## Архитектура

- **`flake.nix`** — `mkHost` собирает каждый хост. Через `specialArgs` во все модули пробрасываются:
  - `inputs` — все flake-инпуты (используются как `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}` или `inputs.<name>.nixosModules.*`).
  - `pkgs-stable` — nixpkgs 25.05 с `allowUnfree`. Применяется точечно там, где unstable ломает пакет (сейчас `lutris`, `bottles` в `modules/apps/gaming.nix`). Модуль, которому он нужен, объявляет `pkgs-stable` в сигнатуре.
  - Общие nixosModules (disko, home-manager, niri, aagl, zapret) подключаются в `mkHost`, поэтому в самих модулях их импортировать не надо.
- **`hosts/<host>/default.nix`** — единственная точка, перечисляющая `imports` модулей + задаёт `networking.hostName` и `system.stateVersion`. `hardware.nix` (initrd/kernelModules) и `disko.nix` (разметка + fileSystems) — специфика железа.
- **`modules/`** — по категориям: корневые (`core`, `boot`, `network`, `audio`, …), `hardware/`, `desktop/`, `apps/`, `services/`. Один модуль = одна тема, включается/выключается строкой в host `default.nix`.
- **`users/alexmcgil.nix`** — системный пользователь (`mutableUsers = false`, uid 1000, shell fish) + подключает home-manager. **`users/alexmcgil-home.nix`** — весь home-manager конфиг (noctalia-shell, plasma-manager, niri settings, git, peon-ping). `users/fish.nix` импортируется оттуда.

## Ключевые соглашения и подводные камни

- **Комментарии и коммиты — на русском.** Модули густо документированы: почему выбран тот или иной вариант, какие грабли обходятся. При изменениях сохраняй этот стиль и обновляй комментарий, если меняешь обоснование.
- **Секрет пароля вне git.** `users/alexmcgil.nix` читает `hashedPasswordFile = "/etc/nixos/secrets/alexmcgil.hash"`. Репозиторий публичный — хэши/секреты в git не класть.
- **KDE/Qt темизация разделена** (`alexmcgil-home.nix`): `plasma-manager` управляет ТОЛЬКО иконками и widget-style; цвета (Tokyo Night) задаёт noctalia через templates qt/gtk/kcolorscheme. `overrideConfig` у plasma **не включать** — иначе конфликт за `[Colors:*]`.
- **noctalia запинен на ветку `legacy-v4`** (см. комментарий в `flake.nix`). `main`/v5 — несовместимый переписанный alpha (TOML, другой модуль, Luau-плагины). План миграции: `docs/noctalia-v5-migration.md`. Не переводить на v5 без сверки с этим планом.
- **niri + NVIDIA + Wayland** тонко настроены в `modules/desktop/niri.nix` (portal-бэкенды, `GSK_RENDERER=gl` для gnome-portal, отсутствие `QT_QPA_PLATFORMTHEME=kde` чтобы не ронять quickshell). Правки env/portal там сверять с существующими комментариями.
- Cachix-кэши объявлены дважды: в `flake.nix` → `nixConfig` (для `nix build`/установки) и в `modules/core.nix` → `nix.settings.substituters` (для системы). При добавлении кэша обновлять оба места.
- Планы и спеки Superpowers лежат в `docs/superpowers/{plans,specs}/`.
