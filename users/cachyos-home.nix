{ config, lib, pkgs, inputs, ... }:
let
  lockAction.spawn = [ "/usr/bin/noctalia" "msg" "session" "lock" ];
in
{
  imports = [
    inputs.niri.homeModules.config
    ./desktop.nix
    ./rebuild-commands.nix
  ];

  home.username = "alexmcgil";
  home.homeDirectory = "/home/alexmcgil";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  # Системный wg-quick читает root-owned копию; установка описана в extra/wgp2p/desktop.md.
  xdg.configFile."wgp2p/wgp2p.conf".source = ../extra/wgp2p/laptop-intel.conf;
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Mesa для Intel UHD. NVIDIA и системные модули desktop-amd здесь не нужны.
  targets.genericLinux.enable = true;
  programs.niri.package = pkgs.niri;

  # PAM из Nix ищет unix_chkpwd в /run/wrappers/bin, которого нет в CachyOS.
  # Оболочку и проверку пароля обеспечивает системный пакет noctalia из pacman;
  # Home Manager по-прежнему управляет настройками, палитрами и плагинами.
  programs.noctalia.package = null;
  home.activation.validateNoctalia = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    /usr/bin/noctalia config validate ${config.xdg.configFile."noctalia/config.toml".source}
  '';

  # Отключаем natural-scroll, включённый по умолчанию модулем niri:
  # на этой машине нужна прокрутка в противоположном направлении.
  programs.niri.settings.input.touchpad.natural-scroll = false;

  home.packages = with pkgs; [
    brightnessctl
    cliphist
    ddcutil
    playerctl
    wl-clipboard
  ];

  # Композитор и оболочка остаются из pacman; путь не зависит от PATH Nix.
  programs.niri.settings.spawn-at-startup = lib.mkForce [
    { command = [ "/usr/bin/xwayland-satellite" ]; }
    { command = [ "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "text" "--watch" "${pkgs.cliphist}/bin/cliphist" "store" ]; }
    { command = [ "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "image" "--watch" "${pkgs.cliphist}/bin/cliphist" "store" ]; }
    { command = [ "/usr/bin/noctalia" ]; }
  ];
  programs.niri.settings.binds."Mod+Space".action = lib.mkForce {
    spawn = [ "/usr/bin/noctalia" "msg" "panel-toggle" "launcher" ];
  };
  # Mod в обычной сессии — Super: общий Mod+L для focus-column-right
  # перехватывал блокировку. Оба варианта здесь выполняют одно действие;
  # переход вправо остаётся на Mod+Right. desktop-amd не затрагиваем.
  programs.niri.settings.binds."Mod+L" = {
    action = lib.mkForce lockAction;
    allow-inhibiting = false;
  };
  programs.niri.settings.binds."Super+L" = {
    action = lib.mkForce lockAction;
    allow-inhibiting = false;
  };

  # Порталы устанавливает CachyOS; здесь задаём только выбор бэкенда.
  xdg.configFile."xdg-desktop-portal/niri-portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.FileChooser=gtk
    org.freedesktop.impl.portal.ScreenCast=gnome
    org.freedesktop.impl.portal.Screenshot=gnome
  '';

  # Подключаем профиль Nix к существующему Fish, не заменяя его настройки.
  xdg.configFile."fish/conf.d/home-manager.fish".text = ''
    if test -f /etc/profile.d/nix-daemon.fish
      source /etc/profile.d/nix-daemon.fish
    end
    fish_add_path --prepend "$HOME/.nix-profile/bin"
    if not contains -- "$HOME/.nix-profile/share" $XDG_DATA_DIRS
      set -gx XDG_DATA_DIRS "$HOME/.nix-profile/share" $XDG_DATA_DIRS
    end
  '';

  # Применяется при следующем входе в сессию, без переменных NVIDIA.
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_MENU_PREFIX = "plasma-";
    MOZ_ENABLE_WAYLAND = "1";
  };
  # Системный niri запускается вне shell Home Manager и получает окружение
  # через systemd, поэтому одного hm-session-vars.sh недостаточно.
  systemd.user.sessionVariables = config.home.sessionVariables // {
    PATH = "${config.home.profileDirectory}/bin:\${PATH}";
  };
}
