{ config, lib, pkgs, ... }:

{
  # Nix settings
  # Cachix-кэши объявлены в flake.nix → nixConfig (noctalia + aagl)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Разрешить unfree пакеты
  nixpkgs.config.allowUnfree = true;

  # Часовой пояс и локаль
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Консольная раскладка
  console.keyMap = "us";

  # Базовые CLI-инструменты
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
    btop
    tree
    file
    unzip
    ripgrep
    fd
    jq
    nvme-cli
    btrfs-progs
    smartmontools
  ];

  # direnv + nix-direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Нужны Noctalia для виджетов Battery/PowerProfile
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
