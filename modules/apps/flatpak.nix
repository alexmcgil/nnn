{ config, lib, pkgs, ... }:

{
  services.flatpak.enable = true;

  # XDG порталы уже включены в desktop-модулях
  # После установки добавить Flathub:
  #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}
