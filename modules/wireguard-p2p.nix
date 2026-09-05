{ config, lib, pkgs, ... }:

{
  # Отдельный WireGuard-интерфейс для связи с собственными машинами (ноутбук ↔
  # десктоп) через хаб на wps: ssh, проброс портов, rsync, syncthing, dev-серверы.
  #
  # Почему отдельный интерфейс, а не существующий full-tunnel-конфиг:
  # corp-VPN (openconnect) режет трафик клиент-клиент, поэтому нужен свой оверлей.
  # Но full-tunnel рядом с ним жить не может — wg-quick при AllowedIPs = 0.0.0.0/0
  # поднимает policy routing (`ip rule add not fwmark <mark> lookup <table>`), а это
  # правило по приоритету выше main и перебивает split-tunnel маршруты openconnect,
  # то есть corp-доступ отваливается целиком. Здесь в allowedIPs только /24 хаба:
  # один обычный маршрут в main, никаких ip rule — туннели не мешают друг другу.
  #
  # Серверная часть, диагностика и порядок переноса хаба на другой сервер лежат
  # в /opt/wgp2p на wps (исходник скриптов — extra/wgp2p/ в этом репозитории).
  networking.wireguard.interfaces.wgp2p = {
    # /32, а не /24: маршрут на подсеть ставит сам модуль из allowedIPs
    # (`ip route replace 10.66.66.0/24 dev wgp2p`), connected route от /24 только
    # продублировал бы его.
    ips = [ "10.66.66.2/32" ];

    # Секреты вне git — репозиторий публичный. Каталог тот же, что у пароля
    # пользователя (users/alexmcgil.nix → /etc/nixos/secrets/alexmcgil.hash).
    privateKeyFile = "/etc/nixos/secrets/wgp2p.key";

    # Не дефолтные 1420: машина может оказаться в сети, где Endpoint попадает
    # внутрь corp-тоннеля (tun0 MTU 1422). Тогда WG-пакет должен влезть с учётом
    # оверхеда IP+UDP+WireGuard (60 байт): 1422 - 60 = 1362, берём 1360 с запасом.
    # Иначе получается чёрная дыра PMTU: ssh подключается, scp виснет.
    mtu = 1360;

    peers = [
      {
        # Публичный ключ хаба: /opt/wgp2p/keys/server.pub на wps.
        publicKey = "JaDccvQb8gntKZnlBKPXztaYELxu5mFS4DjrQlXSIyM=";
        presharedKeyFile = "/etc/nixos/secrets/wgp2p.psk";
        endpoint = "185.196.117.103:51830";
        # Только подсеть туннеля — см. комментарий про 0.0.0.0/0 выше.
        allowedIPs = [ "10.66.66.0/24" ];
        # Обе машины за NAT: без keepalive хаб не сможет инициировать пакеты
        # в сторону простаивающего клиента, и входящий ssh не дойдёт.
        persistentKeepalive = 25;
      }
    ];
  };

  # NetworkManager умеет управлять WireGuard-интерфейсами и способен вмешаться в
  # созданный извне wgp2p (снять адрес, погасить линк). Интерфейс поднимает
  # systemd-юнит wireguard-wgp2p.service, поэтому явно исключаем его из NM.
  networking.networkmanager.unmanaged = [ "interface-name:wgp2p" ];

  # В этой подсети только собственные машины и сам хаб, поэтому доверяем
  # интерфейсу целиком — иначе каждый dev-сервер и каждый проброшенный порт
  # пришлось бы открывать отдельным правилом. Список мержится с docker0/br-+
  # из modules/network.nix.
  networking.firewall.trustedInterfaces = [ "wgp2p" ];

  # Короткие имена вместо адресов. Суффикс -p2p, чтобы не путать с LAN-адресами
  # тех же машин и не пересекаться с corp-DNS.
  networking.hosts = {
    "10.66.66.1" = [ "wps-p2p" ];
    "10.66.66.2" = [ "desk-p2p" ];
    "10.66.66.3" = [ "lap-p2p" ];
  };
}
