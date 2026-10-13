{ pkgs, inputs, ... }:

{
  home.username = "alexmcgil";
  home.homeDirectory = "/home/alexmcgil";
  home.stateVersion = "26.05";
  
  xdg.mimeApps = {
    enable = true;
  
    # Default Applications — что открывает что по умолчанию
    defaultApplications = {
      # Файловый менеджер
      "inode/directory"                  = "org.kde.dolphin.desktop";
      "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
  
      # Браузер (Zen Beta)
      "text/html"                        = "zen-beta.desktop";
      "application/xhtml+xml"            = "zen-beta.desktop";
      "application/x-extension-htm"      = "zen-beta.desktop";
      "application/x-extension-html"     = "zen-beta.desktop";
      "application/x-extension-shtml"    = "zen-beta.desktop";
      "application/x-extension-xht"     = "zen-beta.desktop";
      "application/x-extension-xhtml"    = "zen-beta.desktop";
      "x-scheme-handler/http"            = "zen-beta.desktop";
      "x-scheme-handler/https"           = "zen-beta.desktop";
      "x-scheme-handler/chrome"          = "zen-beta.desktop";
  
      # PDF (zen.desktop не существует — правильный id zen-beta.desktop)
      "application/pdf"                  = "zen-beta.desktop";

      # Архивы
      "application/zip"                  = "org.kde.ark.desktop";
      "application/x-xz-compressed-tar"  = "org.kde.ark.desktop";

      # Изображения (nsxiv — лёгкий X11-вьювер через Xwayland).
      # nsxiv.desktop помечен NoDisplay=true (в меню приложений не светится),
      # но как явный дефолт-хендлер KIO/GIO вызывают его штатно.
      "image/png"                        = "nsxiv.desktop";
      "image/jpeg"                       = "nsxiv.desktop";
      "image/gif"                        = "nsxiv.desktop";
      "image/webp"                       = "nsxiv.desktop";
      "image/bmp"                        = "nsxiv.desktop";
      "image/tiff"                       = "nsxiv.desktop";
      # SVG nsxiv не рендерит (imlib2 без svg-лоадера) — отдаём Gwenview.
      "image/svg+xml"                    = "org.kde.gwenview.desktop";

      # Видео / аудио (mpv также нужен плагину noctalia/mpvpaper)
      "video/mp4"                        = "mpv.desktop";
      "video/x-matroska"                 = "mpv.desktop";
      "video/webm"                       = "mpv.desktop";
      "video/quicktime"                  = "mpv.desktop";
      "video/x-msvideo"                  = "mpv.desktop";
      "audio/mpeg"                       = "mpv.desktop";
      "audio/flac"                       = "mpv.desktop";
      "audio/x-wav"                      = "mpv.desktop";
      "audio/ogg"                        = "mpv.desktop";
      "audio/aac"                        = "mpv.desktop";

      # Thunderbird (почта, календарь, RSS)
      "x-scheme-handler/mailto"          = "org.mozilla.Thunderbird.desktop";
      "message/rfc822"                   = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/mid"             = "org.mozilla.Thunderbird.desktop";
      "text/calendar"                    = "org.mozilla.Thunderbird.desktop";
      "application/x-extension-ics"      = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/webcal"          = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/webcals"         = "org.mozilla.Thunderbird.desktop";
      "application/rss+xml"              = "org.mozilla.Thunderbird.desktop";
      "application/x-extension-rss"      = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/feed"            = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/news"            = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/nntp"            = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/snews"           = "org.mozilla.Thunderbird.desktop";
  
      # Telegram / AyuGram
      "x-scheme-handler/tg"              = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite"         = "org.telegram.desktop.desktop";
  
      # Разработка / прочее
      "x-scheme-handler/jetbrains"       = "jetbrainsd.desktop";
      "x-scheme-handler/postman"         = "Postman.desktop";
      "x-scheme-handler/mongodb"         = "MongoDB Compass.desktop";
      "x-scheme-handler/mongodb+srv"     = "MongoDB Compass.desktop";
      "x-scheme-handler/claude-cli"      = "claude-code-url-handler.desktop";
      "x-scheme-handler/ftb"             = "FTB Electron App.desktop";
  
      # Wine / PortProton
      "application/x-ms-dos-executable"  = "PortProton.desktop";
      "application/x-msi"                = "PortProton.desktop";
      "application/x-msdos-program"     = "PortProton.desktop";
      "application/x-wine-extension-msp" = "PortProton.desktop";
      "text/win-bat"                     = "PortProton.desktop";
    };
  
    # Added Associations — дополнительные приложения, которыми можно открыть файл
    associations.added = {
      "text/html"                        = [ "zen-beta.desktop" ];
      "application/xhtml+xml"            = [ "zen-beta.desktop" ];
      "x-scheme-handler/http"            = [ "zen-beta.desktop" ];
      "x-scheme-handler/https"           = [ "zen-beta.desktop" ];
      "application/zip"                  = [ "org.kde.ark.desktop" ];
      "x-scheme-handler/tg"              = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite"         = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/mailto"          = [ "org.mozilla.Thunderbird.desktop" ];
    };
  };


  xdg.configFile."mimeapps.list".force = true;
  
  # ---- Noctalia ----
  imports = [
    ./desktop.nix
    inputs.xmcl.homeModules.xmcl
    ./fish.nix
  ];

  programs.xmcl = {
    enable = true;
    # Electron хранит учётные данные через Secret Service,
    # который в этой конфигурации предоставляет KeePassXC.
    commandLineArgs = [ ''--password-store="gnome-libsecret"'' ];
    jres = with pkgs; [
      jre8
      temurin-jre-bin-17
      temurin-jre-bin-21
    ];
  };

  # ---- Git ----
  programs.git = {
    enable = true;
    settings = {
      user.name = "alexmcgil";
      user.email = "alexmcgil@vivaldi.net";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "zed --wait";
      merge.conflictStyle = "zdiff3";
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate --all";
      };
    };
  };

  # ---- direnv ----
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ---- Desktop entries overrides ----
  home.file.".local/bin/lm-studio-launcher" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec /run/current-system/sw/bin/lm-studio "$@"
    '';
  };

  xdg.desktopEntries."lm-studio" = {
    name = "LM Studio";
    exec = "/home/alexmcgil/.local/bin/lm-studio-launcher";
    terminal = false;
    type = "Application";
    icon = "lm-studio";
    comment = "Use the chat UI or local server to experiment and develop with local LLMs.";
    categories = [ "Development" ];
    mimeType = [ "x-scheme-handler/lmstudio" ];
  };

  # ---- home-manager self-management ----
  programs.home-manager.enable = true;
}
