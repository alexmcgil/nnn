# Временные обходы

`WORKAROUND <ID>` в коде содержит причину, известную версию, ссылку на upstream (если она есть) и условие удаления. При новом обходе добавьте такой комментарий рядом с изменением и строку сюда. Если проблема привязана к версии, оберните результат в `lib.warnIf (lib.getVersion пакет != "проверенная-версия") "WORKAROUND <ID>: версия изменилась; проверьте обход" значение`. Для flake input сравнивайте его `rev`. Предупреждение означает повод проверить штатный пакет, а не доказательство, что обход можно удалить.

| ID | Назначение | Код |
| --- | --- | --- |
| AI-CODEX | Системные библиотеки для Rust-хука Codex | `modules/apps/ai.nix` |
| AI-TECTONIC | AWS-LC и zlib для Tectonic | `modules/apps/ai.nix` |
| AI-OPENCODE | Исправленный хэш node_modules OpenCode | `modules/apps/ai.nix` |
| DEV-FNM | zstd и pkg-config для сборки fnm | `modules/apps/dev.nix` |
| DEV-BUN | Поиск libstdc++ нативными модулями Bun | `modules/apps/dev.nix` |
| GAME-LUTRIS | Lutris из stable вместо unstable | `modules/apps/gaming.nix` |
| GAME-BOTTLES | Bottles из stable вместо unstable | `modules/apps/gaming.nix` |
| VIRT-CEPH | Отключение Ceph для сборки QEMU | `modules/apps/virt.nix` |
| NIRI-PACKAGE | Пакет niri из nixpkgs вместо niri-flake | `modules/desktop/niri.nix` |
| NIRI-FILECHOOSER | GTK portal для выбора файлов без GNOME Shell | `modules/desktop/niri.nix` |
| NIRI-QT | Qt Quick без KDE platform theme | `modules/desktop/niri.nix` |
| NIRI-PORTAL | GL для gnome-portal с NVIDIA | `modules/desktop/niri.nix` |
| VPN-BUFFER | Увеличение буфера маршрутов AmneziaVPN | `modules/network.nix` |
| VPN-PATH | Пути утилит для сервиса AmneziaVPN | `modules/network.nix` |
| VR-ALVR | zstd для сборки ALVR | `modules/services/vr-streaming.nix` |
| AIVPN-AWSLC | AWS-LC для Rust-хука AIVPN | `pkgs/aivpn/default.nix` |

После ручного обновления `flake.lock` проверьте предупреждения при evaluation, попробуйте штатный пакет без обхода и проверьте его работу. Если обход больше не нужен, удалите его комментарий и строку реестра вместе с кодом.

GitHub Actions на `push`, `pull_request` и вручную вычисляет `system.build.toplevel` для обоих хостов, затем выполняет `nix build --dry-run --no-link`. Предупреждения `lib.warnIf` остаются в логе. Проверка выявляет ошибки evaluation и недоступные зависимости на этапе планирования, но не компилирует пакеты, не запускает графические приложения и не проверяет работу на реальном железе. Успешный CI поэтому не гарантирует сборку или работу Wayland, Qt и VPN.
