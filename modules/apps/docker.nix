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
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          runtimeArgs = [];
        };
      };
      default-runtime = "nvidia";
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
