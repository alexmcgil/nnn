# Open Design (https://github.com/nexu-io/open-design) — локальный дизайн-инструмент,
# который использует твой code-agent CLI (claude) как движок.
#
# Здесь НЕ фоновый сервис, а обёртка-команда `open-design` для запуска по
# требованию: поднимает демон (`od`, API на :7457) и статический веб-сервер
# (caddy на :5174), открывает браузер и держит оба процесса в foreground.
# Ctrl+C гасит и демон, и caddy — в фоне ничего не остаётся.
#
# Почему caddy, а не `od --serve-web`: в Nix-пакете демона статика
# apps/web/out не собирается (отдельный пакет `web`), поэтому демон сам
# отдать SPA не может. caddy отдаёт пакет `web` и reverse-proxy'ит
# /api,/artifacts,/frames на демон — та же схема, что в апстрим-модуле.
#
# claude подцепляется автоматически: команда запускается из твоего шелла и
# наследует PATH (claude-code лежит в /run/current-system/sw/bin), поэтому
# демон находит агента при сканировании PATH. Проблемы systemd с урезанным
# PATH («no agents detected») здесь не возникает.
{ pkgs, inputs, ... }:

let
  odPackages = inputs.open-design.packages.${pkgs.stdenv.hostPlatform.system};
  od = odPackages.daemon;
  web = odPackages.web;

  apiPort = 7457;
  webPort = 5174;

  # SSE-safe reverse proxy: flush_interval -1 стримит чанки сразу, без gzip
  # на /api (иначе браузер словит ERR_INCOMPLETE_CHUNKED_ENCODING), щедрые
  # таймауты под долгие стримы. Скопировано из nix/home-manager.nix апстрима.
  caddyfile = pkgs.writeText "open-design.Caddyfile" ''
    {
      auto_https off
      admin off
      persist_config off
    }

    http://127.0.0.1:${toString webPort} {
      handle /api/* {
        reverse_proxy 127.0.0.1:${toString apiPort} {
          flush_interval -1
          transport http {
            read_timeout 86400s
            write_timeout 86400s
          }
        }
      }
      handle /artifacts/* {
        reverse_proxy 127.0.0.1:${toString apiPort}
      }
      handle /frames/* {
        reverse_proxy 127.0.0.1:${toString apiPort}
      }
      handle {
        root * ${web}
        try_files {path} {path}/ /index.html
        file_server
        encode gzip
      }
    }
  '';

  open-design = pkgs.writeShellApplication {
    name = "open-design";
    runtimeInputs = [ pkgs.caddy pkgs.xdg-utils ];
    text = ''
      # Данные демона (SQLite, проекты, артефакты) — в $HOME, не в nix-store.
      export OD_DATA_DIR="''${OD_DATA_DIR:-$HOME/.od}"
      # Разрешаем демону принимать запросы SPA, отдаваемого caddy на webPort
      # (иначе same-origin gate ответит 403 на PUT/POST).
      export OD_WEB_PORT="${toString webPort}"
      # Гарантируем, что claude виден демону, даже если команду запустили из
      # окружения с урезанным PATH.
      export PATH="$PATH:/run/current-system/sw/bin"
      mkdir -p "$OD_DATA_DIR"

      ${od}/bin/od --port ${toString apiPort} --no-open &
      od_pid=$!
      caddy run --config ${caddyfile} --adapter caddyfile &
      caddy_pid=$!

      # Ctrl+C / выход — убиваем оба процесса, в фоне ничего не остаётся.
      trap 'kill "$od_pid" "$caddy_pid" 2>/dev/null || true' EXIT INT TERM

      echo "Open Design: API :${toString apiPort}, web http://127.0.0.1:${toString webPort}"
      echo "Ctrl+C — остановить."
      # Небольшая пауза, чтобы caddy успел подняться до открытия браузера.
      sleep 1
      xdg-open "http://127.0.0.1:${toString webPort}" >/dev/null 2>&1 || true

      wait
    '';
  };
in
{
  environment.systemPackages = [ open-design ];
}
