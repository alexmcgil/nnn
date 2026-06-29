{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    mongodb-compass
    postman
    dbeaver-bin
    obsidian
    thunar
    localsend
    kdePackages.filelight

    qmk
    via

    # Recommended by https://discourse.nixos.org/t/via-vial-cant-find-my-keyboard/52525/5
    qmk-udev-rules
    qmk_hid
    vial
  ];

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [pkgs.via];
}
