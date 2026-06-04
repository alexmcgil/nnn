{ config, lib, pkgs, ... }:

{
  # Прямой WiFi-стриминг на Quest 3.
  # Интернет ПК идёт по eno1, поэтому WiFi-модуль wlp9s0 целиком отдан под AP.
  # Точку доступа поднимает hostapd (надёжнее и логируемее, чем wpa_supplicant-AP
  # внутри NetworkManager); IP/DHCP/NAT — свои.

  # wlp9s0 забираем у NetworkManager — им управляет hostapd
  networking.networkmanager.unmanaged = [ "interface-name:wlp9s0" ];

  # Регуляторная БД для корректной работы 5 ГГц AP (мощность/каналы)
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="RU"
  '';

  # 1. Точка доступа на hostapd
  services.hostapd = {
    enable = true;
    radios.wlp9s0 = {
      band = "5g";
      channel = 36;          # без DFS; 80 МГц занимает 36–48
      countryCode = "RU";
      # 80 МГц ради битрейта стрима. На канале 36 вторичный канал — вверх (HT40+)
      wifi4.capabilities = [ "HT40+" "SHORT-GI-20" "SHORT-GI-40" ];
      wifi5 = {
        operatingChannelWidth = "80";
        capabilities = [ "SHORT-GI-80" ];
      };
      networks.wlp9s0 = {
        ssid = "Quest3-VR";
        authentication = {
          mode = "wpa2-sha1";   # классический WPA2-PSK — макс. совместимость с Quest
          wpaPassword = "adminroot";
        };
      };
    };
  };

  # 2. Статический адрес точки доступа (hostapd сам IP не назначает)
  systemd.services.vr-ap-ip = {
    description = "Статический IP для VR-точки доступа (wlp9s0)";
    after = [ "hostapd.service" ];
    bindsTo = [ "hostapd.service" ];
    wantedBy = [ "hostapd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip addr replace 10.42.0.1/24 dev wlp9s0
      ${pkgs.iproute2}/bin/ip link set wlp9s0 up
    '';
  };

  # 3. DHCP/DNS для шлема — отдельный dnsmasq, только на wlp9s0
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;   # не трогаем системный резолвинг хоста
    settings = {
      interface = "wlp9s0";
      bind-dynamic = true;         # переживёт появление интерфейса позже
      dhcp-range = [ "10.42.0.10,10.42.0.100,12h" ];
      dhcp-option = [
        "option:router,10.42.0.1"
        "option:dns-server,10.42.0.1"
      ];
      server = [ "1.1.1.1" "8.8.8.8" ];  # апстрим DNS для шлема
    };
  };

  # 4. Форвардинг + NAT по подсети-источнику (без привязки к интерфейсу),
  #    чтобы трафик шлема следовал за default route: WG up → VPN, WG down → eno1
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -s 10.42.0.0/24 ! -d 10.42.0.0/24 -j MASQUERADE
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D POSTROUTING -s 10.42.0.0/24 ! -d 10.42.0.0/24 -j MASQUERADE 2>/dev/null || true
  '';

  # 5. Прямой приватный линк ПК <-> шлем открываем целиком
  #    (DHCP/DNS + порты ALVR/WiVRn/SteamVR), интерфейс не смотрит во внешнюю сеть
  networking.firewall.trustedInterfaces = [ "wlp9s0" ];

  # 6. VR-стриминг-софт
  services.wivrn = {
    enable = true;
    openFirewall = true;
    autoStart = false;       # запускать по необходимости (рядом живут SteamVR/ALVR)
  };

  environment.systemPackages = with pkgs; [
    alvr
    monado
    android-tools   # adb для установки клиента ALVR на Quest
  ];
}
