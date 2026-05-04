{ config, lib, pkgs, pkgs-stable, inputs, ... }:

{

  environment.systemPackages = with pkgs; [
    pkgs.lmstudio
    pkgs.opencode
  ];
}
