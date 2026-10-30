{ config, lib, pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    # Удалённый стриминг должен быть доступен после входа в графическую сессию.
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
