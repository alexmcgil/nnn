{ config, ... }:

let
  standalone = config.targets.genericLinux.enable;
  switchCommand =
    if standalone then
      ''home-manager switch -b hm-backup --flake "path:$flake_dir#alexmcgil@cachyos" $argv''
    else
      ''sudo nixos-rebuild switch --flake "$flake_dir#"(hostname) $argv'';
in
{
  # Одни команды для NixOS и CachyOS. Отдельные файлы функций не заменяют
  # config.fish, пользовательские алиасы или историю системного Fish.
  xdg.configFile."fish/functions/nrs.fish".text = ''
    function nrs --description 'Применить конфигурацию Nix'
      set -l flake_dir "${config.home.homeDirectory}/nixos"
      ${switchCommand}
    end
  '';

  xdg.configFile."fish/functions/nrsu.fish".text = ''
    function nrsu --description 'Обновить inputs и применить конфигурацию Nix'
      set -l flake_dir "${config.home.homeDirectory}/nixos"

      nix flake update --flake "path:$flake_dir"
      or return

      git -C "$flake_dir" add -- flake.lock
      or return
      if not git -C "$flake_dir" diff --cached --quiet -- flake.lock
        # Коммитим только lock-файл, даже если другие изменения уже staged.
        git -C "$flake_dir" commit --only -m "Обновить flake.lock" -- flake.lock
        or return
      end

      nrs $argv
    end
  '';
}
