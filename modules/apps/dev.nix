{ config, lib, pkgs, ... }:

{
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
    # на всякий случай частые зависимости:
    glib
    libxkbcommon
    fontconfig
    freetype
  ];
  
  environment.systemPackages = with pkgs; [
    # Редакторы
    zed-editor
    jetbrains.idea

    # Компиляторы и системы сборки
    # gcc
    # clang
    # cmake
    # meson
    # ninja
    # pkg-config

    fnm
    pnpm
    bun

    # Платформы
    # nodejs_22
    # jdk21
    # gradle
    # python313
    # go

    # Rust — через rustup (управляет тулчейном самостоятельно)
    # rustup
  ];

  # direnv + nix-direnv уже включены в core.nix
  # programs.direnv и programs.direnv.nix-direnv — в core.nix
}
