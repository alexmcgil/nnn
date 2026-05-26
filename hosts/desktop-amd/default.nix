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

    ../../modules/hardware/amd-cpu.nix
    ../../modules/hardware/nvidia.nix

    ../../modules/desktop/plasma.nix
    ../../modules/desktop/niri.nix

    ../../modules/apps/ai.nix
    ../../modules/apps/cli.nix
    ../../modules/apps/browsers.nix
    ../../modules/apps/messengers.nix
    ../../modules/apps/dev.nix
    ../../modules/apps/media.nix
    ../../modules/apps/productivity.nix
    ../../modules/apps/steam.nix
    ../../modules/apps/gaming.nix
    ../../modules/apps/docker.nix
    ../../modules/apps/virt.nix
    ../../modules/apps/waydroid.nix
    ../../modules/apps/flatpak.nix

    ../../modules/services/ssh.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/sunshine.nix
    ../../modules/services/fwupd.nix
    ../../modules/services/openrgb.nix
    ../../modules/services/zapret.nix

    ../../users/alexmcgil.nix
  ];

  networking.hostName = "desktop-amd";

  # Cross-build aarch64 артефактов (sdImage для Pi) через qemu-user
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "25.11";
}
