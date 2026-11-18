# Мониторы и дополнительные рабочие столы стационарного компьютера.
{ ... }:
{
  programs.niri.settings = {
    outputs = {
      # EDID-имена стабильны, в отличие от номеров разъёмов после перезагрузки.
      "Samsung Electric Company LS24D300G H1AK500000".position = { x = 0; y = 0; };
      "PNP(AOC) CU34G4 2SERAHA001236" = {
        mode = { width = 3440; height = 1440; refresh = 180.0; };
        position = { x = 1920; y = 0; };
        focus-at-startup = true;
      };
    };

    workspaces = {
      "1".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "2".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "3".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "4".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "5".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "6".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "7".open-on-output = "PNP(AOC) CU34G4 2SERAHA001236";
      "z".open-on-output = "Samsung Electric Company LS24D300G H1AK500000";
      "x".open-on-output = "Samsung Electric Company LS24D300G H1AK500000";
      "c".open-on-output = "Samsung Electric Company LS24D300G H1AK500000";
    };

    window-rules = [
      {
        matches = [ { app-id = "^md\\.obsidian\\.Obsidian$"; } ];
        open-on-workspace = "x";
        open-focused = true;
      }
      {
        matches = [ { app-id = "org.telegram.desktop$"; } ];
        open-on-workspace = "c";
        open-focused = false;
      }
      {
        matches = [ { app-id = "^org\\.keepassxc\\.KeePassXC$"; } ];
        open-on-workspace = "z";
        open-focused = false;
      }
    ];
  };
}
