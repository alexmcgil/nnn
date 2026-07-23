{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    vlc
    obs-studio
    audacity
    gimp3
    krita
    nsxiv          # лёгкий вьювер изображений (X11 → Xwayland), дефолт для image/*
    kdePackages.kdenlive
    feishin        # Navidrome/Jellyfin музыкальный клиент
    haruna         # KDE видеоплеер
    qbittorrent

    ffmpeg-full

    # bambu-studio
  ];
}
