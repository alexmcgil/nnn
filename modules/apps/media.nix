{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    vlc
    obs-studio
    audacity
    gimp3
    krita
    kdenlive
    feishin        # Navidrome/Jellyfin музыкальный клиент
    haruna         # KDE видеоплеер
    qbittorrent
  ];
}
