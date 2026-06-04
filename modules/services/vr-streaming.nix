{ config, lib, pkgs, ... }:

{
  # Прямой WiFi-стриминг на Quest 3.
  # Интернет ПК идёт по eno1, поэтому WiFi-модуль wlp9s0 целиком отдан под AP.

  # 1. Точка доступа (декларативный keyfile-профиль NetworkManager)
  networking.networkmanager.ensureProfiles.profiles.vr-hotspot = {
    connection = {
      id = "vr-hotspot";
      type = "wifi";
      interface-name = "wlp9s0";
      autoconnect = true;
      autoconnect-priority = 10;
    };
    wifi = {
      mode = "ap";
      ssid = "Quest3-VR";
      band = "a";      # 5 ГГц
      channel = 36;    # без DFS-ожидания
    };
    wifi-security = {
      key-mgmt = "wpa-psk";  # WPA2 — макс. совместимость с Quest
      psk = "adminroot";
    };
    ipv4.method = "shared";   # dnsmasq DHCP/DNS + NAT + IP forwarding
    ipv6.method = "disabled";
  };

  # 2. Форвардинг (метод shared включает сам, фиксируем явно)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # 3. Прямой приватный линк ПК <-> шлем открываем целиком
  #    (DHCP/DNS + порты ALVR/WiVRn/SteamVR), интерфейс не смотрит во внешнюю сеть
  networking.firewall.trustedInterfaces = [ "wlp9s0" ];
}
