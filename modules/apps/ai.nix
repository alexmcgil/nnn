{ config, lib, pkgs, pkgs-stable, inputs, ... }:

let
  chatgpt-linux = pkgs.callPackage ../../packages/chatgpt-linux.nix { };
  paseoPackages = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system};
in {

  environment.systemPackages = with pkgs; [
    lmstudio
    opencode

    chatgpt-linux

    claude-code
    claude-monitor
    codex
    codex-acp

    paseoPackages.desktop
    paseoPackages.default

    rtk

    # happy-coder
  ];
}
