{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "alexmcgil";
    dataDir = "/home/alexmcgil";
    configDir = "/home/alexmcgil/.config/syncthing";
    openDefaultPorts = true;
  };
}
