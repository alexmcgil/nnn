{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    autoPrune.enable = true;
    daemon.settings = {
      features = {
        cdi = true; # Container Device Interface — нужно для NVIDIA через CDI
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
