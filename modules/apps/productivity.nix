{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-stable
    # mongodb-compass
    postman
    dbeaver-bin
    obsidian
    thunar
    # WORKAROUND APP-LOCALSEND-ZLIB: LocalSend 1.18.0 не находит libz.so.1 при запуске.
    # Upstream issue/PR: неизвестен. Удалить после проверки штатного пакета на целевой машине.
    (lib.warnIf (lib.getVersion localsend != "1.18.0")
      "WORKAROUND APP-LOCALSEND-ZLIB: версия LocalSend изменилась; проверьте необходимость обёртки"
      (symlinkJoin {
        name = "localsend-with-zlib";
        paths = [ localsend ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/localsend_app --prefix LD_LIBRARY_PATH : ${zlib}/lib
        '';
      }))
    (callPackage ../../packages/xdman.nix { })
    kdePackages.filelight

    qmk
    via

    # Recommended by https://discourse.nixos.org/t/via-vial-cant-find-my-keyboard/52525/5
    qmk-udev-rules
    qmk_hid
    vial
  ];

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [pkgs.via];
}
