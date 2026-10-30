{ config, lib, pkgs, ... }:

{
  networking.wireguard.interfaces.wgp2p = {
    ips = [ "10.66.66.2/32" ];

    privateKeyFile = "/etc/nixos/secrets/wgp2p.key";
    # Десктоп заменяет бывший VPS; роутер пробрасывает сюда только UDP 51830.
    listenPort = 51830;
    # Помечаем только внешний UDP, чтобы ответы не уходили в корпоративный tun0.
    fwMark = "51830";
    mtu = 1360;

    peers = [
      {
        # Адрес ноутбука за NAT узнаём из его входящего handshake.
        name = "laptop-intel";
        publicKey = "fbpc4FO0RhWJCKFjo5J1TiJzi+IjmhGenpajDd0fCR8=";
        allowedIPs = [ "10.66.66.3/32" ];
      }
    ];
  };

  networking.networkmanager.unmanaged = [ "interface-name:wgp2p" ];

  # Домашний uplink: отдельная таблица обходит более специфичные маршруты openconnect.
  systemd.services.wgp2p-uplink = {
    description = "Прямой выход WireGuard через домашний роутер";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ip route replace default via 192.168.0.1 dev eno1 table 51830
      ip rule add priority 100 fwmark 51830 lookup 51830
    '';
    preStop = ''
      ip rule del priority 100 fwmark 51830 lookup 51830
      ip route flush table 51830
    '';
  };

  # Сам интерфейс создаётся до network.target; маршрут нужен только к запуску пира.
  systemd.services.wireguard-wgp2p-peer-laptop-intel = {
    requires = [ "wgp2p-uplink.service" ];
    after = [ "wgp2p-uplink.service" ];
  };

  networking.firewall.trustedInterfaces = [ "wgp2p" ];
  networking.firewall.allowedUDPPorts = [ 51830 ];

  networking.hosts = {
    "10.66.66.2" = [ "desk-p2p" ];
    "10.66.66.3" = [ "lap-p2p" ];
  };
}
