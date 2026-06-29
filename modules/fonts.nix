{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    dejavu_fonts
    liberation_ttf
    fira-code
    fira-sans
    inter
    open-sans
    jetbrains-mono
    twitter-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    material-symbols
    wqy_zenhei
    adwaita-fonts
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" ];
    sansSerif = [ "Inter" "Noto Sans" ];
    monospace = [ "JetBrains Mono" "JetBrainsMono Nerd Font" ];
  };
}
