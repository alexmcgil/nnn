{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    mongodb-compass
    postman
    dbeaver-bin
    obsidian
  ];
}
