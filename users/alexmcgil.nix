{ pkgs, inputs, ... }:

{
  users.mutableUsers = false;

  users.users.alexmcgil = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    home = "/home/alexmcgil";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "render"
      "docker"
      "libvirtd"
      "plugdev"
      "kvm"
    ];
    # Хэш пароля хранится в файле ВНЕ репозитория (публичный реп — не хранить хэш в git).
    # Создать файл на целевой машине перед nixos-install:
    #   mkdir -p /etc/nixos/secrets
    #   nix-shell -p mkpasswd --run 'mkpasswd -m sha-512' > /etc/nixos/secrets/alexmcgil.hash
    #   chmod 600 /etc/nixos/secrets/alexmcgil.hash
    # Желательно использовать тот же пароль, что был на CachyOS.
    hashedPasswordFile = "/etc/nixos/secrets/alexmcgil.hash";
  };

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.alexmcgil = import ./alexmcgil-home.nix;
}
