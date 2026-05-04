{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    # keepassxc уже в modules/security.nix как системный пакет
    mongodb-compass
    postman
    dbeaver-bin
  ];
}
