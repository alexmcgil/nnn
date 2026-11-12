{ config, lib, pkgs, pkgs-stable, inputs, ... }:

# AAGL (Anime Game Launcher) требует cachix:
# nix-shell -p cachix --run 'cachix use ezkea'
# Кэш прописан в modules/core.nix → nix.settings.substituters

{
  # AAGL модуль из flake-input
  imports = [ inputs.aagl.nixosModules.default ];

  programs.anime-game-launcher.enable = true;

  environment.systemPackages = with pkgs; [
    # WORKAROUND GAME-LUTRIS: версия 0.5.22 из unstable ломалась; используем stable.
    # Upstream issue/PR: неизвестен. Удалить, когда пакет из unstable снова работает.
    (lib.warnIf (lib.getVersion lutris != "0.5.22")
      "WORKAROUND GAME-LUTRIS: версия Lutris в unstable изменилась; проверьте подмену"
      pkgs-stable.lutris)
    bottles
    heroic             # Heroic Games Launcher (Epic/GOG/Amazon)
    prismlauncher      # Minecraft
    mcpelauncher-ui-qt
    temurin-bin-21   # для Minecraft 1.21+ нужна Java 21
    temurin-bin-17   # для 1.17–1.20.x
    temurin-bin-8    # для старых версий (1.16 и ниже)
    
    mangohud
    goverlay           # GUI для MangoHud
    protontricks
    protonup-qt        # GE-Proton установка
    winetricks
    wineWow64Packages.stagingFull
    umu-launcher       # Unified Launcher для Proton

    protonup-ng
  ];
}
