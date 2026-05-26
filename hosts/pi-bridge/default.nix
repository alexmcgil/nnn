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
    "REPLACE_WITH_SSH_PUBKEY"
  ];

  # sudo без пароля для wheel — нужно для nixos-rebuild --target-host
  # (пароль/защита всё равно есть на стадии SSH через ключи)
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Глушим desktop-home-manager — на headless Pi его 33 КБ конфига бесполезны
  home-manager.users.alexmcgil = lib.mkForce { home.stateVersion = "25.11"; };

  system.stateVersion = "25.11";
}
