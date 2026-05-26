{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix

    # sdImage-модуль формирует raw-образ при nix build
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    # Общая обвязка (без desktop-модулей)
    ../../modules/core.nix
    ../../modules/services/ssh.nix
    ../../modules/services/wg-bridge.nix
    ../../users/alexmcgil.nix
  ];

  networking.hostName = "pi-bridge";

  # Wi-Fi через NetworkManager (SSID/пароль вводятся вручную через nmcli при первом буте)
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  # SSH-ключ для деплоя с desktop-amd
  users.users.alexmcgil.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8qMrdapDPrwavCpN8OBvcfp3tFGG9noD2RRC6TSchmXllhsCtX9OlkMXFUHGPvxke2kGDRTsyhZGpBPbQkeGa9MrFY0D0uttFsza147zjJ41LAYF0LZTFnW1Ucz+CtJCeyi+UReFG4qg8ddwWY6yj50QfMAT050Cc4/BptVgdEZa5hLFP7rOQl90GEkmeuyJaUEP4/8oAkIFaByvfsnajc4JLJQEtdjQqal7uy5ngO+eLKmqcqjVWdtiUNFPRz8toNw9QcErf7OfLt4xUyoPvSNLDocjL57qJqXEF2SNOlCfx19hhjWJTftWLYfCMeAawy62Iz+e5WZGfnyZmcS0fh22Drny0r4b9Ec944tGCLIYKlyFYHNIC2m/EasaCCQilEPYP/mPXyn7iWd66/jcsD1iGHH36l9V5PJx796zU2aeSHY+t+W2umF3fBEnUeyoaYaAIUFWL55xqEb1tzg2gmgso6FzkmDWAT57++2B+H8UFmEvCcTjmaYNGzOu8J4s= alexmcgil@sap"
  ];

  # sudo без пароля для wheel — нужно для nixos-rebuild --target-host
  # (пароль/защита всё равно есть на стадии SSH через ключи)
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Глушим desktop-home-manager — на headless Pi его 33 КБ конфига бесполезны
  home-manager.users.alexmcgil = lib.mkForce { home.stateVersion = "25.11"; };

  system.stateVersion = "25.11";
}
