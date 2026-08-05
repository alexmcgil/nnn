{ config, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    # AmneziaVPN на Linux настраивает DNS через D-Bus API systemd-resolved.
    # Без этого интерфейс и handshake поднимаются, но доменный split tunnelling
    # остаётся без VPN-DNS (в журнале: DnsUtilsLinux DBus errors).
    dns = "systemd-resolved";
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };

  services.resolved.enable = true;

  # Имя таблицы жёстко задано в Linux-клиенте Amnezia. На обычных дистрибутивах
  # его добавляет установщик, а в NixOS /etc декларативный, поэтому регистрируем
  # таблицу здесь. Она нужна для fwmark 0x3211 в split tunnelling.
  environment.etc."iproute2/rt_tables.d/amnezia.conf".text = ''
    201 amnvpnrt
  '';

  # В Linux-клиенте 4.8.21 shell жёстко задан как /bin/bash. NixOS штатно
  # предоставляет только /bin/sh, поэтому QProcess не может запустить ни одну
  # команду firewall (код -2), даже когда bash присутствует в PATH сервиса.
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
  ];

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
    # Daemon запускает эти программы по коротким именам для firewall, policy
    # routing и split tunnelling. В PATH вручную объявленного systemd-сервиса
    # они сами не попадают; QProcess возвращает -2 и GUI молча оставляет только
    # два full-tunnel маршрута /1, из-за чего весь трафик таймаутится.
    path = with pkgs; [
      bash
      coreutils
      findutils
      gawk
      gnugrep
      iproute2
      iptables
    ];
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
