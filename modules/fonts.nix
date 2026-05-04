{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    dejavu_fonts
    liberation_ttf
    fira-code
    fira-sans
    inter
    open-sans
    jetbrains-mono
    cantarell-fonts
    twitter-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    material-symbols
    wqy-zenhei
    adwaita-fonts
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" ];
    sansSerif = [ "Inter" "Noto Sans" ];
    monospace = [ "JetBrains Mono" "JetBrainsMono Nerd Font" ];
  };
}
