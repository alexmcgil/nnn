{ pkgs, ... }:

{
  users.mutableUsers = false;

  users.users.alexmcgil = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    home = "/home/alexmcgil";
    shell = pkgs.zsh;
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
    # ВАЖНО: сгенерируй хэш командой:
    #   nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
    # и подставь вывод сюда.
    # Желательно использовать тот же пароль, что был на CachyOS,
    # чтобы не потерять доступ к сохранённым данным браузерных расширений KeePassXC.
    hashedPassword = "REPLACE_WITH_OUTPUT_OF_mkpasswd";
  };

  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = true;

  # home-manager подключён через flake, но home.nix пользователя опишет сам
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # home-manager.users.alexmcgil = import ../home/alexmcgil.nix;  # раскомментировать позже
}
