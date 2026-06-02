{ config, lib, pkgs, ... }:

{
  # Nix settings
  # Cachix-кэши объявлены в flake.nix → nixConfig (noctalia + aagl)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://ezkea.cachix.org"       # aagl
      "https://noctalia.cachix.org"    # noctalia-shell
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
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
  i18n.defaultLocale = "en_US.UTF-8";
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

  # zram — сжатый swap в ОЗУ (zstd ~3:1). Дисковый swap не используем:
  # гибернация не нужна, а swap-файл на btrfs требует NOCOW-subvolume.
  # 50% от 60 ГБ ОЗУ — с запасом, реально использоваться будет редко.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # При zram-only swap имеет смысл агрессивнее выгружать холодные страницы
  # в быстрый сжатый swap (дефолт 60 рассчитан на медленный диск).
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
