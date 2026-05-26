{ config, lib, pkgs, ... }:

{
  # IP forwarding и поддержка маршрутизации src-marked пакетов (для wg-quick)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };

  # WireGuard сервер
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/nixos/secrets/wg-pi-bridge.key";

    peers = [
      # Ноут
      {
        publicKey = "REPLACE_WITH_LAPTOP_PUBKEY";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      # Телефон
      {
        publicKey = "REPLACE_WITH_PHONE_PUBKEY";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      # Запасной peer
      {
        publicKey = "REPLACE_WITH_SPARE_PUBKEY";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };

  # NAT: трафик из wg0 маскарадится в wlan0 → клиент видит всю локалку
  networking.nat = {
    enable = true;
    enableIPv6 = false;
    externalInterface = "wlan0";
    internalInterfaces = [ "wg0" ];
  };

  # Firewall: открываем UDP 51820 наружу, доверяем wg0
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    checkReversePath = "loose";
    trustedInterfaces = [ "wg0" ];
  };

  # wireguard-tools для диагностики (wg show)
  environment.systemPackages = with pkgs; [ wireguard-tools ];
}
