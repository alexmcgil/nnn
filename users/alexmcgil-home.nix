{ pkgs, inputs, ... }:

{
  home.username = "alexmcgil";
  home.homeDirectory = "/home/alexmcgil";
  home.stateVersion = "25.11";
  
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
  
      # PDF
      "application/pdf"                  = "zen.desktop";
  
      # Архивы
      "application/zip"                  = "org.kde.ark.desktop";
      "application/x-xz-compressed-tar"  = "org.kde.ark.desktop";
  
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
      "text/html"                        = [ "zen-beta.desktop" "zen.desktop" ];
      "application/xhtml+xml"            = [ "zen-beta.desktop" "zen.desktop" ];
      "x-scheme-handler/http"            = [ "zen-beta.desktop" "zen.desktop" ];
      "x-scheme-handler/https"           = [ "zen-beta.desktop" "zen.desktop" ];
      "application/zip"                  = [ "org.kde.ark.desktop" ];
      "x-scheme-handler/tg"              = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite"         = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/mailto"          = [ "org.mozilla.Thunderbird.desktop" ];
    };
  };


  xdg.configFile."mimeapps.list".force = true;
  
  # ---- Noctalia shell ----
  imports = [
    inputs.noctalia.homeModules.default
    ./fish.nix
  ];

  programs.noctalia-shell = {
    enable = true;

    # Tokyo Night цветовая схема (из colors.json)
    colors = {
      mError             = "#f7768e";
      mHover             = "#9ece6a";
      mOnError           = "#16161e";
      mOnHover           = "#16161e";
      mOnPrimary         = "#16161e";
      mOnSecondary       = "#16161e";
      mOnSurface         = "#c0caf5";
      mOnSurfaceVariant  = "#9aa5ce";
      mOnTertiary        = "#16161e";
      mOutline           = "#353d57";
      mPrimary           = "#7aa2f7";
      mSecondary         = "#bb9af7";
      mShadow            = "#15161e";
      mSurface           = "#1a1b26";
      mSurfaceVariant    = "#24283b";
      mTertiary          = "#9ece6a";
    };

    # Плагины (из plugins.json)
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        assistant-panel    = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        clipper            = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        kaomoji-provider   = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        mini-docker        = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        model-usage        = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        mpvpaper           = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        network-manager-vpn = { enabled = true; sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        privacy-indicator  = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        screen-toolkit     = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        slowbongo          = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        ssh-sessions       = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        syncthing-status   = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        usb-drive-manager  = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        video-wallpaper    = { enabled = false; sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
        zed-provider       = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
      };
      version = 2;
    };

    # Настройки — только отличия от дефолтов (сравнено с noctalia.md → Configuration Defaults)
    settings = {
      settingsVersion = 59;

      appLauncher = {
        enableClipboardHistory = true;   # default: false
        iconMode = "native";             # default: "tabler"
        terminalCommand = "kitty -e";    # default: "alacritty -e"
      };

      audio = {
        preferredPlayer = "mpv";         # default: ""
      };

      bar = {
        density = "comfortable";         # default: "default"
        widgets = {
          left = [
            {
              colorizeSystemIcon = "none";
              colorizeSystemText = "none";
              customIconPath = "";
              enableColorization = false;
              icon = "rocket";
              iconColor = "none";
              id = "Launcher";
              useDistroLogo = false;
            }
            {
              clockColor = "none";
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              id = "Clock";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
            }
            {
              compactMode = true;
              diskPath = "/";
              iconColor = "none";
              id = "SystemMonitor";
              showCpuCores = false;
              showCpuFreq = false;
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskAvailable = false;
              showDiskUsage = false;
              showDiskUsageAsPercent = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
              showSwapUsage = false;
              textColor = "none";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              colorizeIcons = true;
              hideMode = "hidden";
              id = "ActiveWindow";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              showText = true;
              textColor = "none";
              useFixedWidth = false;
            }
            {
              compactMode = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              id = "MediaMini";
              maxWidth = 145;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              textColor = "none";
              useFixedWidth = false;
              visualizerType = "linear";
            }
            { iconColor = "none"; id = "KeepAwake"; textColor = "none"; }
            { id = "plugin:assistant-panel"; defaultSettings = { ai = { apiKeys = {}; maxHistoryLength = 100; model = "gemini-2.5-flash"; openaiBaseUrl = "https://api.openai.com/v1/chat/completions"; openaiLocal = false; provider = "google"; systemPrompt = "You are a helpful assistant integrated into a Linux desktop shell. Be concise and helpful."; temperature = 0.7; }; maxHistoryLength = 100; panelDetached = true; panelHeightRatio = 0.85; panelPosition = "right"; panelWidth = 520; scale = 1; translator = { backend = "google"; deeplApiKey = ""; realTimeTranslation = true; sourceLanguage = "auto"; targetLanguage = "en"; }; }; }
            { id = "plugin:model-usage"; defaultSettings = { barCycleIntervalSec = 5; barDisplayMode = "active"; barMetric = "prompts"; providers = { claude = { credentialsPath = "~/.claude/.credentials.json"; enabled = false; statsPath = "~/.claude/stats-cache.json"; }; codex = { enabled = false; }; copilot = { enabled = false; }; openrouter = { apiKey = ""; enabled = false; }; zen = { apiKey = ""; enabled = false; }; }; refreshIntervalSec = 30; }; }
            { id = "plugin:mini-docker"; defaultSettings = { refreshInterval = 5000; }; }
          ];
          center = [
            {
              characterCount = 2;
              colorizeIcons = false;
              emptyColor = "secondary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              fontWeight = "bold";
              groupedBorderOpacity = 1;
              hideUnoccupied = false;
              iconScale = 0.8;
              id = "Workspace";
              labelMode = "index";
              occupiedColor = "secondary";
              pillSize = 0.6;
              showApplications = false;
              showApplicationsHover = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
            }
          ];
          right = [
            { blacklist = []; chevronColor = "none"; colorizeIcons = false; drawerEnabled = true; hidePassive = false; id = "Tray"; pinned = []; }
            { displayMode = "forceOpen"; iconColor = "none"; id = "KeyboardLayout"; showIcon = true; textColor = "none"; }
            { hideWhenZero = false; hideWhenZeroUnread = false; iconColor = "none"; id = "NotificationHistory"; showUnreadBadge = true; unreadBadgeColor = "primary"; }
            { deviceNativePath = "__default__"; displayMode = "icon-always"; hideIfIdle = false; hideIfNotDetected = true; id = "Battery"; showNoctaliaPerformance = true; showPowerProfiles = true; }
            { displayMode = "onhover"; iconColor = "none"; id = "Volume"; middleClickCommand = "pwvucontrol || pavucontrol"; textColor = "none"; }
            { applyToAllMonitors = false; displayMode = "onhover"; iconColor = "none"; id = "Brightness"; textColor = "none"; }
            { id = "plugin:privacy-indicator"; defaultSettings = { activeColor = "primary"; camFilterRegex = ""; enableToast = true; hideInactive = false; iconSpacing = 4; inactiveColor = "none"; micFilterRegex = ""; removeMargins = false; }; }
            { id = "plugin:network-manager-vpn"; defaultSettings = { connectedColor = "primary"; disableToastNotifications = false; disconnectedColor = "none"; displayMode = "onhover"; }; }
            { id = "plugin:slowbongo"; defaultSettings = { catColor = "default"; catOffsetY = 0; catSize = 1; idleTimeout = 0; raveMode = false; tappyMode = false; useMprisFilter = false; waitingTimeout = 30000; }; }
            { id = "plugin:usb-drive-manager"; defaultSettings = { autoMount = false; fileBrowser = "dolphin"; hideWhenEmpty = false; iconColor = "none"; showBadge = false; showNotifications = true; terminalCommand = "kitty"; }; }
            { id = "plugin:screen-toolkit"; defaultSettings = { colorHistory = []; detectedCompositor = ""; detectedRecorder = ""; filenameFormat = ""; installedLangs = [ "eng" ]; paletteColors = []; screenshotPath = ""; selectedOcrLang = "eng"; transAvailable = false; videoPath = ""; }; }
            { commandPrefix = "ssh"; id = "plugin:ssh-sessions"; defaultSettings = { pollInterval = 10; showInactiveHosts = true; terminalCommand = ""; }; }
            { id = "plugin:arch-updater"; defaultSettings = { boldText = true; boldVer = true; checkCmd = "(checkupdates; paru -Qua) 2>/dev/null"; customIconPath = ""; desktopTip = true; enableColorization = false; flatpak = true; hideOnEmpty = false; iconColor = "none"; iconName = "arrow-big-down-lines"; noctalia = true; refreshInterval = 120; refreshTimer = true; toast = true; tooltip = true; updateCmd = "ghostty -e bash -c 'echo \"Updating System...\";paru; flatpak update; read -n 1 -p \"Press any key to exit...\"'"; useDistroLogo = false; }; }
            { id = "plugin:clipper"; defaultSettings = { enableTodoIntegration = false; notecardsEnabled = true; pincardsEnabled = true; showCloseButton = true; }; }
            { id = "plugin:syncthing-status"; defaultSettings = { apiKey = ""; apiUrl = ""; configPath = ""; enabled = true; folderIds = []; pollIntervalMs = 10000; verifyTls = false; }; }
            { colorizeDistroLogo = false; colorizeSystemIcon = "none"; colorizeSystemText = "none"; customIconPath = ""; enableColorization = false; icon = "noctalia"; id = "ControlCenter"; useDistroLogo = false; }
          ];
        };
      };

      brightness = {
        enableDdcSupport = true;         # default: false
      };

      colorSchemes = {
        predefinedScheme = "Tokyo Night"; # default: "Noctalia (default)"
      };

      controlCenter = {
        cards = [
          { enabled = true;  id = "profile-card"; }
          { enabled = true;  id = "shortcuts-card"; }
          { enabled = true;  id = "audio-card"; }
          { enabled = true;  id = "brightness-card"; }  # default: false
          { enabled = true;  id = "weather-card"; }
          { enabled = true;  id = "media-sysmon-card"; }
        ];
      };

      desktopWidgets = {
        enabled = true;                  # default: false
        overviewEnabled = true;
        monitorWidgets = [
          {
            name = "eDP-1";
            widgets = [
              { clockColor = "none"; clockStyle = "digital"; customFont = ""; format = "HH:mm\\nd MMMM yyyy"; id = "Clock"; roundedCorners = true; scale = 0.9670385120228145; showBackground = true; useCustomFont = false; x = 33; y = 68; }
              { hideMode = "visible"; id = "MediaPlayer"; roundedCorners = true; scale = 1; showAlbumArt = true; showBackground = true; showButtons = true; showVisualizer = true; visualizerType = "linear"; x = 651; y = 189; }
              { id = "Weather"; roundedCorners = true; scale = 1; showBackground = true; x = 1188; y = 86; }
            ];
          }
        ];
      };

      dock = {
        launcherPosition = "start";      # default: "end"
        showLauncherIcon = true;         # default: false
      };

      general = {
        avatarImage = "/home/alexmcgil/Pictures/avatar.png"; # TODO: скопировать фото
        enableLockScreenMediaControls = true;  # default: false
        lockScreenAnimations = true;           # default: false
        passwordChars = true;                  # default: false
        telemetryEnabled = true;
      };

      idle = {
        lockTimeout = 0;
        screenOffTimeout = 0;
        suspendTimeout = 0;
      };

      location = {
        autoLocate = false;              # default: true
        firstDayOfWeek = 1;             # default: -1
        name = "St Petersburg";
        showWeekNumberInCalendar = true; # default: false
      };

      notifications = {
        enableKeyboardLayoutToast = false; # default: true
      };

      systemMonitor = {
        enableDgpuMonitoring = true;     # default: false
      };

      templates = {
        activeTemplates = [
          { enabled = true; id = "btop"; }
          { enabled = true; id = "cava"; }
          { enabled = true; id = "discord"; }
          { enabled = true; id = "gtk"; }
          { enabled = true; id = "qt"; }
          { enabled = true; id = "zed"; }
          { enabled = true; id = "kitty"; }
          { enabled = true; id = "niri"; }
          { enabled = true; id = "telegram"; }
          { enabled = true; id = "zenBrowser"; }
        ];
      };

      wallpaper = {
        automationEnabled = true;        # default: false
        directory = "/home/alexmcgil/Pictures/Wallpapers";
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
        { command = [ "noctalia-shell" ]; }
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
        {
          matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
          default-column-width = {};
        }
        {
          matches = [
            { app-id = "zen$"; }
            { app-id = "zen-beta$"; }
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
            { app-id = "Minecraft"; }
          ];
          open-on-workspace = "4";
          open-focused = false;
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

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [];
        "Mod+Space".action.spawn  = [ "noctalia-shell" "ipc" "call" "launcher" "toggle" ];
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
