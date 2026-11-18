# Профиль ноутбука общий для NixOS и Home Manager на CachyOS.
{ lib, ... }:
{
  programs.niri.settings = {
    # Встроенный экран; внешние мониторы niri располагает автоматически.
    outputs."eDP-1" = {
      position = { x = 0; y = 0; };
      focus-at-startup = true;
    };
    workspaces = lib.genAttrs [ "1" "2" "3" "4" "5" "6" "7" ] (_: {
      open-on-output = "eDP-1";
    });
    input = {
      touchpad = {
        # Подавляем касания при наборе текста, сохраняя tap вне печати.
        dwt = true;
        natural-scroll = false;
        # Постоянная скорость удобнее для точного наведения на тачпаде.
        accel-profile = lib.mkForce "flat";
        accel-speed = lib.mkForce 0.0;
      };
    };
    window-rules = [
      {
        matches = [ { app-id = "^md\\.obsidian\\.Obsidian$"; } ];
        open-on-workspace = "2";
        open-focused = true;
      }
      {
        matches = [ { app-id = "org.telegram.desktop$"; } ];
        open-on-workspace = "3";
        open-focused = false;
      }
      {
        matches = [ { app-id = "^org\\.keepassxc\\.KeePassXC$"; } ];
        open-on-workspace = "7";
        open-focused = false;
      }
    ];
  };
}
