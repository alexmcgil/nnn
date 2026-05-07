{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };

  # WireGuard — ядерный модуль встроен в linuxPackages_latest
  # wireguard-tools нужен для wg / wg-quick
  environment.systemPackages = with pkgs; [ 
    amnezia-vpn
    amneziawg-tools
    wireguard-tools
  ];

  systemd.services.amneziavpn = {
    description = "AmneziaVPN Background Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };

  # Разрешить wg-quick поднимать интерфейсы (нужен для wg-quick up/down)
  networking.firewall.checkReversePath = "loose";

  # Брандмауэр
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
    # Открываем порты при необходимости в конкретных модулях (jellyfin, sunshine и т.д.)
  };

  # SSH включён здесь для удобства (детали в modules/services/ssh.nix)
  services.openssh.enable = true;
}
