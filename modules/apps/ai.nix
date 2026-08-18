{ config, lib, pkgs, pkgs-stable, inputs, ... }:

{

  environment.systemPackages = with pkgs; [
    lmstudio
    opencode

    claude-code
    claude-monitor
    codex
    codex-acp

    rtk

    # happy-coder
  ];
}
