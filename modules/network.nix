{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-openconnect
    ];
  };

  # Брандмауэр
  networking.firewall = {
    enable = true;
    # Открываем порты при необходимости в конкретных модулях (jellyfin, sunshine и т.д.)
  };

  # SSH включён здесь для удобства (детали в modules/services/ssh.nix)
  services.openssh.enable = true;
}
