{
  description = "NixOS configuration for desktop-amd and laptop-intel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, disko, niri, zen-browser, aagl, zapret-discord-youtube, ... }@inputs:
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
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/${hostname}
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        desktop-amd = mkHost {
          system = "x86_64-linux";
          hostname = "desktop-amd";
          extraModules = [
            disko.nixosModules.disko
            niri.nixosModules.niri
            aagl.nixosModules.default
            zapret-discord-youtube.nixosModules.default
          ];
        };

        laptop-intel = mkHost {
          system = "x86_64-linux";
          hostname = "laptop-intel";
          extraModules = [
            disko.nixosModules.disko
            niri.nixosModules.niri
            aagl.nixosModules.default
            zapret-discord-youtube.nixosModules.default
          ];
        };

        pi-bridge = mkHost {
          system = "aarch64-linux";
          hostname = "pi-bridge";
          extraModules = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4
          ];
        };
      };
    };
}
