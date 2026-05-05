{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "alexmcgil";
    dataDir = "/home/alexmcgil";
    configDir = "/home/alexmcgil/.config/syncthing";
    openDefaultPorts = true;

    settings = {
      devices = {
        "laptop-intel" = { id = "NQLLZN3-557I4N6-5MYIHUM-QDG4NE5-SDZRUTW-PDMPM56-D7OVJ2B-6P4LSQB"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };

      folders = {
        "Documents" = {
          path = "/home/alexmcgil/Documents";
          devices = [ "laptop-intel" ];
        };
        "Scripts" = {
          path = "/home/alexmcgil/scripts";
          devices = [ "laptop-intel" ];
          ignorePerms = false;
        };
        # "Example" = {
        #   path = "/home/myusername/Example";
        #   devices = [ "device1" ];
        # };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
