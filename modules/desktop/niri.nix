{ config, lib, pkgs, inputs, ... }:

# niri — tiling Wayland compositor
# noctalia-shell работает поверх quickshell
# На момент написания noctalia-shell отсутствует в nixpkgs.
# TODO: клонировать вручную после установки:
#   git clone https://github.com/<noctalia-repo> ~/.config/quickshell/noctalia
# Либо подключить отдельный flake-input, когда пакет появится в nixpkgs или
# появится собственный flake у проекта.

{
  # Включить niri через nixosModule из flake-input sodiboo/niri-flake
  programs.niri.enable = true;

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-gnome  # альтернатива
    ];
    config.common.default = "*";
  };

  # Пакеты для niri-сессии
  environment.systemPackages = with pkgs; [
    waybar
    fuzzel
    mako
    wl-clipboard
    cliphist
    xwayland-satellite
    quickshell
    qt6.qtwayland
    # noctalia-shell пока не в nixpkgs — смотри TODO выше
  ];

  # Xwayland через xwayland-satellite (не системный xwayland)
  # systemd user service запустит xwayland-satellite автоматически при старте niri

  # Переменные для Qt-приложений в Wayland
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}
