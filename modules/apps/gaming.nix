{ config, lib, pkgs, inputs, ... }:

# AAGL (Anime Game Launcher) требует cachix:
# nix-shell -p cachix --run 'cachix use ezkea'
# Кэш прописан в modules/core.nix → nix.settings.substituters

{
  # AAGL модуль из flake-input
  imports = [ inputs.aagl.nixosModules.default ];

  programs.anime-game-launcher.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    heroic             # Heroic Games Launcher (Epic/GOG/Amazon)
    prismlauncher      # Minecraft
    mangohud
    goverlay           # GUI для MangoHud
    protontricks
    protonup-qt        # GE-Proton установка
    winetricks
    wineWowPackages.stagingFull
    umu-launcher       # Unified Launcher для Proton
  ];
}
