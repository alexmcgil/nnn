{ pkgs, inputs, ... }:

{
  home.username = "alexmcgil";
  home.homeDirectory = "/home/alexmcgil";
  home.stateVersion = "25.11";

  # ---- Noctalia shell ----
  imports = [
    inputs.noctalia.homeModules.default
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
        arch-updater       = { enabled = true;  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins"; };
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
            { id = "plugin:usb-drive-manager"; defaultSettings = { autoMount = false; fileBrowser = "yazi"; hideWhenEmpty = false; iconColor = "none"; showBadge = false; showNotifications = true; terminalCommand = "kitty"; }; }
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
      user.email = "alexmcgil@example.com"; # TODO: указать реальную почту
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

  # ---- home-manager self-management ----
  programs.home-manager.enable = true;
}
