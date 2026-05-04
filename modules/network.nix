{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-openconnect
    ];
  };

  # WireGuard — ядерный модуль встроен в linuxPackages_latest
  # wireguard-tools нужен для wg / wg-quick
  environment.systemPackages = [ 
    pkgs.wireguard-tools
    pkgs.kdePackages.networkmanager-qt
  ];

  # Разрешить wg-quick поднимать интерфейсы (нужен для wg-quick up/down)
  networking.firewall.checkReversePath = "loose";

  # Брандмауэр
  networking.firewall = {
    enable = true;
    # Открываем порты при необходимости в конкретных модулях (jellyfin, sunshine и т.д.)
  };

  # SSH включён здесь для удобства (детали в modules/services/ssh.nix)
  services.openssh.enable = true;
}
