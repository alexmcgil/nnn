{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix

    ../../modules/core.nix
    ../../modules/boot.nix
    ../../modules/network.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/fonts.nix
    ../../modules/security.nix

    ../../modules/hardware/intel-cpu.nix
    ../../modules/hardware/intel-gpu.nix

    ../../modules/desktop/plasma.nix
    ../../modules/desktop/niri.nix

    ../../modules/apps/cli.nix
    ../../modules/apps/browsers.nix
    ../../modules/apps/messengers.nix
    ../../modules/apps/dev.nix
    ../../modules/apps/media.nix
    ../../modules/apps/productivity.nix
    ../../modules/apps/steam.nix
    # ../../modules/apps/gaming.nix       # раскомментировать при необходимости
    ../../modules/apps/docker.nix
    ../../modules/apps/virt.nix
    # ../../modules/apps/waydroid.nix     # раскомментировать при необходимости
    ../../modules/apps/flatpak.nix

    ../../modules/services/ssh.nix
    ../../modules/services/syncthing.nix
    # ../../modules/services/jellyfin.nix  # раскомментировать при необходимости
    # ../../modules/services/sunshine.nix  # раскомментировать при необходимости
    ../../modules/services/fwupd.nix
    ../../modules/services/openrgb.nix

    ../../users/alexmcgil.nix
  ];

  networking.hostName = "laptop-intel";

  system.stateVersion = "26.05";
}
