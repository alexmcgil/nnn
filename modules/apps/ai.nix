{ config, lib, pkgs, pkgs-stable, inputs, ... }:

{

  environment.systemPackages = with pkgs; [
    lmstudio
    opencode
  ];
}
