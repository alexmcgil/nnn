{ config, lib, pkgs, ... }:

{
  networking.wireguard.interfaces.wgp2p = {
    ips = [ "10.66.66.2/32" ];

    privateKeyFile = "/etc/nixos/secrets/wgp2p.key";

    mtu = 1360;

    peers = [
      {
        publicKey = "JaDccvQb8gntKZnlBKPXztaYELxu5mFS4DjrQlXSIyM=";
        presharedKeyFile = "/etc/nixos/secrets/wgp2p.psk";
        endpoint = "185.196.117.103:51830";
        allowedIPs = [ "10.66.66.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };

  networking.networkmanager.unmanaged = [ "interface-name:wgp2p" ];

  networking.firewall.trustedInterfaces = [ "wgp2p" ];

  networking.hosts = {
    "10.66.66.1" = [ "wps-p2p" ];
    "10.66.66.2" = [ "desk-p2p" ];
    "10.66.66.3" = [ "lap-p2p" ];
  };
}
