{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Редакторы
    zed-editor
    jetbrains.idea
    obsidian

    # Компиляторы и системы сборки
    gcc
    clang
    cmake
    meson
    ninja
    pkg-config

    # Платформы
    nodejs_22
    jdk21
    gradle
    python313
    go

    # Rust — через rustup (управляет тулчейном самостоятельно)
    rustup
  ];

  # direnv + nix-direnv уже включены в core.nix
  # programs.direnv и programs.direnv.nix-direnv — в core.nix
}
