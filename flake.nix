{
  description = "NixOS configuration for desktop-amd and laptop-intel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Отдельный канал для AmneziaVPN: 4.8.21 из unstable несовместим с Qt 6.11
    # на странице импорта конфигурации (QQmlComponent recommendedText).
    nixpkgs-2605.url = "github:NixOS/nixpkgs/nixos-26.05";

    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Запинено на ветку legacy-v4. main/v5 — переписанный с нуля alpha-шелл
    # (C++/OpenGL ES) с несовместимым форматом конфига (TOML вместо JSON,
    # модуль programs.noctalia вместо programs.noctalia-shell, плагины → Luau).
    # Тянуть legacy-v4 — значит оставаться на v4 и получать его багфиксы,
    # при этом nix flake update не утащит на v5.
    # План перехода на v5 зафиксирован в docs/noctalia-v5-migration.md
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    peon-ping = {
      url = "github:PeonPing/peon-ping";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Без follows nixpkgs: пакеты (daemon `od` + web) собираются через
    # dream2nix ровно с тем nixpkgs, против которого их тестировал апстрим,
    # что заметно надёжнее для тяжёлой pnpm-сборки. Ценой лишнего eval.
    open-design.url = "github:nexu-io/open-design";
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-2605, home-manager, disko, niri, zen-browser, aagl, zapret-discord-youtube, ... }@inputs:
      let
      mkHost = { system, hostname, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
            pkgs-2605 = import nixpkgs-2605 {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            niri.nixosModules.niri
            aagl.nixosModules.default
            zapret-discord-youtube.nixosModules.default
            ./hosts/${hostname}
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        desktop-amd = mkHost {
          system = "x86_64-linux";
          hostname = "desktop-amd";
        };

        laptop-intel = mkHost {
          system = "x86_64-linux";
          hostname = "laptop-intel";
        };
      };
    };
}
