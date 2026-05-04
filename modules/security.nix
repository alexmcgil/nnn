{ lib, pkgs, config, ... }:

{
  # Никакого GNOME Keyring
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  programs.seahorse.enable = lib.mkForce false;

  # KWallet выключаем как хранилище и PAM-интеграцию
  security.pam.services.login.kwallet.enable = lib.mkForce false;
  security.pam.services.sddm.kwallet.enable = lib.mkForce false;
  security.pam.services.greetd.kwallet.enable = lib.mkForce false;

  # KeePassXC + интеграция с браузерами
  # (дополнительно может быть в modules/apps/productivity.nix, здесь как системный пакет)
  environment.systemPackages = with pkgs; [ keepassxc ];

  # Polkit
  security.polkit.enable = true;
}
