{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };

  # Обычный WireGuard встроен в ядро, а AmneziaWG требует отдельного модуля.
  # Одних amneziawg-tools недостаточно: без модуля GUI создаёт интерфейс, но не
  # может применить AWG-параметры Jc/Jmin/Jmax и соединение остаётся без handshake.
  boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
  boot.kernelModules = [ "amneziawg" ];

  # wireguard-tools и amneziawg-tools нужны для wg/wg-quick и awg/awg-quick.
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
    allowedTCPPorts = [ 25565 8188 3000 5173 1234 8096 53317 ];
    allowedUDPPorts = [ 25565 8188 1234 8096 53317 ];
    # Открываем порты при необходимости в конкретных модулях (jellyfin, sunshine и т.д.)
  };

  # SSH включён здесь для удобства (детали в modules/services/ssh.nix)
  services.openssh.enable = true;
}
