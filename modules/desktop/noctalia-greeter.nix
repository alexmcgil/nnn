{ pkgs, ... }:

{
  # Noctalia Greeter заменяет SDDM, но по-прежнему даёт выбрать между
  # основной сессией niri и запасной Plasma. Штатный модуль nixpkgs сам
  # включает greetd, AccountsService и Polkit.
  services.displayManager.noctalia-greeter = {
    enable = true;

    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };

    settings = {
      cursor.size = 24;

      # Совпадает с раскладкой основной niri-сессии.
      keyboard = {
        layout = "us,ru";
        options = "grp:caps_toggle";
        numlock = true;
      };
    };
  };
}
