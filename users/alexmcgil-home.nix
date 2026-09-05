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
    inputs.peon-ping.homeManagerModules.default
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.xmcl.homeModules.xmcl
    ./fish.nix
  ];

  # ---- KDE/Qt темизация ----
  # plasma-manager управляет ТОЛЬКО иконками и widget-style.
  # Цветами (Tokyo Night) управляет noctalia через templates qt/gtk —
  # поэтому overrideConfig НЕ включаем (иначе война за [Colors:*]/ColorScheme).
  # Чинит сломанные ссылки на Arch-темы (breeze-plus-dark / Darkly).
  programs.plasma = {
    enable = true;
    workspace.iconTheme = "Papirus-Dark";
    configFile.kdeglobals.KDE.widgetStyle = "Breeze";
  };

  home.packages = with pkgs; [
    papirus-icon-theme

    # Зависимости перенесённых Luau-плагинов Noctalia v5.
    evtest
    gpu-screen-recorder
    mpvpaper
    satty
    sqlite
    tesseract
    translate-shell
    udiskie
    wf-recorder
    wl-screenrec
    zbar
  ];

  programs.peon-ping = {
    enable = true;
    package = inputs.peon-ping.packages.${pkgs.stdenv.hostPlatform.system}.default;
    claudeCodeIntegration = true;
  };

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

  programs.noctalia = {
    enable = true;

    # Сохраняем точные цвета из v4 вместо близкой встроенной Tokyo-Night.
    # Для светлого режима Noctalia использует dark-вариант, если light не задан.
    customPalettes."Tokyo Night".dark = {
      mError            = "#f7768e";
      mHover            = "#9ece6a";
      mOnError          = "#16161e";
      mOnHover          = "#16161e";
      mOnPrimary        = "#16161e";
      mOnSecondary      = "#16161e";
      mOnSurface        = "#c0caf5";
      mOnSurfaceVariant = "#9aa5ce";
      mOnTertiary       = "#16161e";
      mOutline          = "#353d57";
      mPrimary          = "#7aa2f7";
      mSecondary        = "#bb9af7";
      mShadow           = "#15161e";
      mSurface          = "#1a1b26";
      mSurfaceVariant   = "#24283b";
      mTertiary         = "#9ece6a";
    };

    # В v5 настройки — TOML-схема. Home Manager генерирует config.toml и
    # проверяет его через `noctalia config validate` во время сборки.
    settings = {
      shell = {
        avatar_path = "/home/alexmcgil/Pictures/avatar.png"; # TODO: скопировать фото
        clipboard_enabled = true;
        password_style = "random";
        telemetry_enabled = true;
      };

      theme = {
        source = "custom";
        custom_palette = "Tokyo Night";
        mode = "dark";

        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "btop"
            "cava"
            "gtk3"
            "gtk4"
            "qt"
            "kcolorscheme"
            "kitty"
            "niri"
          ];
          enable_community_templates = true;
          community_ids = [
            "discord"
            "telegram"
            "zed"
            "zen-browser"
          ];
        };
      };

      wallpaper = {
        enabled = true;
        directory = "/home/alexmcgil/Pictures/Wallpapers";
        automation.enabled = true;
      };

      # Аналог overview-фона v4; niri кладёт этот layer-surface в backdrop.
      backdrop = {
        enabled = true;
        blur_intensity = 0.5;
        tint_intensity = 0.3;
      };

      lockscreen = {
        enabled = true;
        blurred_desktop = true;
      };

      brightness.enable_ddcutil = true;

      weather.enabled = true;
      location = {
        auto_locate = false;
        address = "St Petersburg";
      };

      control_center.calendar.show_week_numbers = true;
      osd.kinds.keyboard_layout = false;
      system.monitor.enabled = true;

      dock = {
        enabled = true;
        launcher_position = "start";
      };

      bar.main = {
        position = "top";

        start = [
          "launcher"
          "clock"
          "cpu"
          "temp"
          "ram"
          "active_window"
          "media"
          "caffeine"
          "mini_docker"
        ];

        center = [ "workspaces" ];

        end = [
          "tray"
          "keyboard_layout"
          "notifications"
          "battery"
          "volume"
          "brightness"
          "privacy"
          "bongocat"
          "udiskie"
          "screen_toolkit"
          "nix_monitor"
          "clipboard"
          "notes"
          "syncthing"
          "control-center"
        ];
      };

      widget = {
        clock = {
          format = "{:%H:%M %a, %b %d}";
          tooltip_format = "{:%H:%M %A, %B %d}";
        };

        active_window.max_length = 145.0;
        media.max_length = 145.0;

        mini_docker.type = "8bury/mini-docker:mini-docker";
        bongocat.type = "noctalia/bongocat:cat";
        udiskie.type = "aristides/udiskie:status";
        screen_toolkit.type = "alexander/screen-toolkit:widget";
        nix_monitor.type = "avivbintangaringga/nix-monitor:nix-monitor";
        notes.type = "noctalia/notes:notes";
        syncthing.type = "rylos/syncthing:bar";
      };

      # v4 QML-плагины несовместимы с новым Luau API. Здесь только прямые
      # аналоги; VPN-плагин намеренно не переносим — он требует отдельной настройки.
      plugins = {
        auto_update = "all";
        enabled = [
          "noctalia/bongocat"
          "noctalia/kaomoji"
          "noctalia/mpvpaper"
          "noctalia/notes"
          "noctalia/translator"
          "8bury/mini-docker"
          "alexander/screen-toolkit"
          "cleboost/ssh-launcher"
          "rylos/syncthing"
          "aristides/udiskie"
          "cleboost/zed-provider"
          "avivbintangaringga/nix-monitor"
        ];
      };

      plugin_settings = {
        "8bury/mini-docker".refresh_interval = 5;

        "alexander/screen-toolkit"."selected-ocr-lang" = "eng";

        "aristides/udiskie" = {
          enable_notifications = true;
          auto_open_filemanager = false;
          file_manager_cmd = "dolphin";
        };

        "rylos/syncthing".poll_interval = 10;

        "avivbintangaringga/nix-monitor" = {
          branch = "nixos-unstable";
          update_check_interval = 120;
        };
      };

      desktop_widgets = {
        enabled = true;
        widget_order = [
          "clock_main"
          "media_main"
          "weather_main"
        ];

        widget = {
          clock_main = {
            type = "clock";
            cx = 180.0;
            cy = 100.0;
            settings = {
              format = "{:%H:%M}\\n{:%d %B %Y}";
              background_opacity = 0.8;
            };
          };

          media_main = {
            type = "media_player";
            cx = 750.0;
            cy = 250.0;
          };

          weather_main = {
            type = "weather";
            cx = 1200.0;
            cy = 100.0;
          };
        };
      };
    };
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

  # ---- niri ----
  programs.niri = {
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:caps_toggle";
          };
          numlock = true;
        };
        touchpad = {
          tap = true;
          accel-speed = 0.1;
          accel-profile = "adaptive";
        };
        warp-mouse-to-focus.enable = true;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.5; }
          { proportion = 0.66; }
          { proportion = 0.33; }
        ];

        preset-window-heights = [
          { proportion = 0.5; }
          { proportion = 1.0; }
        ];

        default-column-width = { proportion = 0.5; };

        focus-ring = {
          # Цвета переопределяются noctalia через шаблон niri (Tokyo Night)
          width = 4;
          active   = { color = "#7aa2f7"; };
          inactive = { color = "#1a1b26"; };
          urgent   = { color = "#f7768e"; };
        };

        border = {
          enable = true;
          width = 2;
          active   = { color = "#7aa2f7"; };
          inactive = { color = "#1a1b26"; };
          urgent   = { color = "#f7768e"; };
        };

        shadow = {
          enable = true;
          draw-behind-window = true;
          softness = 30;
          spread = 5;
          offset = { x = 0; y = 5; };
          color = "#0007";
        };

        struts = {};
      };

      spawn-at-startup = [
        { command = [ "xwayland-satellite" ]; }
        { command = [ "wl-paste" "--type" "text" "--watch" "cliphist" "store" ]; }
        { command = [ "wl-paste" "--type" "image" "--watch" "cliphist" "store" ]; }
        { command = [ "noctalia" ]; }
        
        { command = [ "zen-beta" ]; }
        { command = [ "obsidian" ]; }
        { command = [ "Telegram" ]; }
        { command = [ "feishin" ]; }
      ];

      hotkey-overlay.skip-at-startup = true;

      prefer-no-csd = true;

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      animations = {};

      workspaces = {
        "1" = { };
        "2" = { };
        "3" = { };
        "4" = { };
        "5" = { };
        "6" = { };
        "7" = { };
      };

      window-rules = [
        # Окно настроек v5 — обычный xdg-toplevel, поэтому делаем его плавающим.
        {
          matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
          open-floating = true;
          default-column-width = { fixed = 1080; };
          default-window-height = { fixed = 920; };
        }
        {
          matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
          default-column-width = {};
        }
        {
          matches = [
            { app-id = "zen$"; }
            { app-id = "zen-beta$"; }
            { app-id = "chromium-browser$"; }
          ];
          open-maximized = true;
          open-on-workspace = "1";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "LM-Studio$"; }
          ];
          open-maximized = true;
          open-on-workspace = "1";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "dev.zed.Zed$"; }
          ];
          open-on-workspace = "2";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "obsidian$"; }
          ];
          open-on-workspace = "2";
          open-focused = true;
        }
        {
          matches = [
            { app-id = "org.telegram.desktop$"; }
            { app-id = "electron$"; }
            { app-id = "discord$"; }
          ];
          open-on-workspace = "3";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "steam$"; }
          ];
          open-on-workspace = "4";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "moe.launcher.an-anime-game-launcher$"; }
          ];
          open-on-workspace = "4";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "org.prismlauncher.PrismLauncher$"; }
          ];
          open-on-workspace = "4";
          open-focused = false;
        }
        
        {
          matches = [
            { app-id = "Minecraft"; }
          ];
          open-on-workspace = "4";
          open-maximized = true;
          open-focused = true;
        }
        {
          matches = [
            { app-id = "feishin$"; }
          ];
          open-on-workspace = "5";
          open-focused = false;
        }
        {
          matches = [
            { app-id = "zen$"; title = "^Picture-in-Picture$"; }
          ];
          open-floating = true;
        }
        {
          matches = [
            { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
            { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
          ];
          block-out-from = "screen-capture";
        }
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
        }
      ];

      # Размытая подложка v5 в overview niri (видна и между воркспейсами).
      # Noctalia создаёт отдельный surface с namespace "noctalia-backdrop";
      # этим правилом niri кладёт его в compositor backdrop.
      # Работает только для background layer-surface, игнорирующих exclusive zone.
      layer-rules = [
        {
          matches = [ { namespace = "^noctalia-backdrop$"; } ];
          place-within-backdrop = true;
        }
      ];

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [];
        "Mod+Space".action.spawn  = [ "noctalia" "msg" "panel-toggle" "launcher" ];
        "Mod+Return".action.spawn = "kitty";
        "Super+L".action.spawn    = "swaylock";
        "Super+Alt+S" = { allow-when-locked = true; action.spawn = [ "sh" "-c" "pkill orca || exec orca" ]; };

        "XF86AudioRaiseVolume" = { allow-when-locked = true; action.spawn = [ "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0" ]; };
        "XF86AudioLowerVolume" = { allow-when-locked = true; action.spawn = [ "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-" ]; };
        "XF86AudioMute"        = { allow-when-locked = true; action.spawn = [ "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ]; };
        "XF86AudioMicMute"     = { allow-when-locked = true; action.spawn = [ "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ]; };
        "XF86AudioPlay"        = { allow-when-locked = true; action.spawn = [ "sh" "-c" "playerctl play-pause" ]; };
        "XF86AudioStop"        = { allow-when-locked = true; action.spawn = [ "sh" "-c" "playerctl stop" ]; };
        "XF86AudioPrev"        = { allow-when-locked = true; action.spawn = [ "sh" "-c" "playerctl previous" ]; };
        "XF86AudioNext"        = { allow-when-locked = true; action.spawn = [ "sh" "-c" "playerctl next" ]; };
        "XF86MonBrightnessUp"   = { allow-when-locked = true; action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ]; };
        "XF86MonBrightnessDown" = { allow-when-locked = true; action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ]; };

        "Mod+O" = { repeat = false; action.toggle-overview = []; };
        "Mod+Q" = { repeat = false; action.close-window = []; };

        "Mod+Left".action.focus-column-left   = [];
        "Mod+Down".action.focus-window-down    = [];
        "Mod+Up".action.focus-window-up        = [];
        "Mod+Right".action.focus-column-right  = [];
        "Mod+H".action.focus-column-left       = [];
        "Mod+J".action.focus-window-down       = [];
        "Mod+K".action.focus-window-up         = [];
        "Mod+L".action.focus-column-right      = [];

        "Mod+Ctrl+Left".action.move-column-left   = [];
        "Mod+Ctrl+Down".action.move-window-down   = [];
        "Mod+Ctrl+Up".action.move-window-up       = [];
        "Mod+Ctrl+Right".action.move-column-right = [];
        "Mod+Ctrl+H".action.move-column-left      = [];
        "Mod+Ctrl+J".action.move-window-down      = [];
        "Mod+Ctrl+K".action.move-window-up        = [];
        "Mod+Ctrl+L".action.move-column-right     = [];

        "Mod+Home".action.focus-column-first  = [];
        "Mod+End".action.focus-column-last    = [];
        "Mod+Ctrl+Home".action.move-column-to-first = [];
        "Mod+Ctrl+End".action.move-column-to-last   = [];

        "Mod+Shift+Left".action.focus-monitor-left   = [];
        "Mod+Shift+Down".action.focus-monitor-down   = [];
        "Mod+Shift+Up".action.focus-monitor-up       = [];
        "Mod+Shift+Right".action.focus-monitor-right = [];
        "Mod+Shift+H".action.focus-monitor-left      = [];
        "Mod+Shift+J".action.focus-monitor-down      = [];
        "Mod+Shift+K".action.focus-monitor-up        = [];
        "Mod+Shift+L".action.focus-monitor-right     = [];

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left   = [];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down   = [];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up       = [];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left      = [];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down      = [];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up        = [];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right     = [];

        "Mod+Page_Down".action.focus-workspace-down       = [];
        "Mod+Page_Up".action.focus-workspace-up           = [];
        "Mod+U".action.focus-workspace-down               = [];
        "Mod+I".action.focus-workspace-up                 = [];
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up    = [];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+I".action.move-column-to-workspace-up   = [];

        "Mod+Shift+Page_Down".action.move-workspace-down = [];
        "Mod+Shift+Page_Up".action.move-workspace-up     = [];
        "Mod+Shift+U".action.move-workspace-down         = [];
        "Mod+Shift+I".action.move-workspace-up           = [];

        "Mod+WheelScrollDown"      = { cooldown-ms = 150; action.focus-workspace-down = []; };
        "Mod+WheelScrollUp"        = { cooldown-ms = 150; action.focus-workspace-up = []; };
        "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action.move-column-to-workspace-down = []; };
        "Mod+Ctrl+WheelScrollUp"   = { cooldown-ms = 150; action.move-column-to-workspace-up = []; };
        "Mod+WheelScrollRight".action.focus-column-right       = [];
        "Mod+WheelScrollLeft".action.focus-column-left         = [];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right   = [];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left     = [];
        "Mod+Shift+WheelScrollDown".action.focus-column-right  = [];
        "Mod+Shift+WheelScrollUp".action.focus-column-left     = [];
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left    = [];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;

        "Mod+BracketLeft".action.consume-or-expel-window-left  = [];
        "Mod+BracketRight".action.consume-or-expel-window-right = [];
        "Mod+Comma".action.consume-window-into-column           = [];
        "Mod+Period".action.expel-window-from-column            = [];

        "Mod+R".action.switch-preset-column-width          = [];
        "Mod+Shift+R".action.switch-preset-window-height   = [];
        "Mod+Ctrl+R".action.reset-window-height            = [];
        "Mod+F".action.maximize-column                     = [];
        "Mod+Shift+F".action.fullscreen-window             = [];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [];
        "Mod+C".action.center-column                       = [];
        "Mod+Ctrl+C".action.center-visible-columns         = [];

        "Mod+Minus".action.set-column-width       = "-10%";
        "Mod+Equal".action.set-column-width        = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating                    = [];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
        "Mod+W".action.toggle-column-tabbed-display              = [];

        "Print".action.screenshot              = [];
        "Mod+Shift+S".action.screenshot        = [];
        "Ctrl+Print".action.screenshot-screen  = [];
        "Alt+Print".action.screenshot-window   = [];

        "Mod+Escape" = { allow-inhibiting = false; action.toggle-keyboard-shortcuts-inhibit = []; };
        "Mod+Shift+E".action.quit         = [];
        "Ctrl+Alt+Delete".action.quit     = [];
        "Mod+Shift+P".action.power-off-monitors = [];
      };
    };
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
