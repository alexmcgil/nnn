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
    github-cli
    warp-terminal
    lens
    kubectl

    # Редакторы
    zed-editor
    # jetbrains.idea

    # Language servers
    nil
    nixd
    # Временный фикс pnpm-хэша 6.0.2 из upstream; убрать после исправления nixos-unstable.
    (typescript-language-server.overrideAttrs (old: {
      pnpmDeps = old.pnpmDeps.overrideAttrs {
        outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
      };
    }))
    vscode-langservers-extracted
    yaml-language-server

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

    # Локальная разработка jay-flow
    poppler-utils # pdftocairo для PDF-превью
    cloudflared   # туннель к MinIO для AI-worker

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
