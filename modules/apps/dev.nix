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
    config.boot.kernelPackages.nvidia_x11
  ];
  
  environment.systemPackages = with pkgs; [
    # Prisma engines (для работы без скачивания бинарников)
    prisma-engines

    glab
    warp-terminal
    lens
    kubectl

    # Редакторы
    zed-editor
    # jetbrains.idea

    # Language servers
    nil
    nixd

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
    uv
    # nodejs_22
    # jdk21
    # gradle
    # python313
    # go

    # Rust — через rustup (управляет тулчейном самостоятельно)
    # rustup
  ];

  environment.sessionVariables = {
    # Prisma на NixOS: указываем системный schema-engine вместо скачивания
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
  };

  # direnv + nix-direnv уже включены в core.nix
  # programs.direnv и programs.direnv.nix-direnv — в core.nix
}
