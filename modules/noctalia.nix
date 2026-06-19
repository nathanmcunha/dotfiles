{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      settingsVersion = 59;
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        density = "comfortable";
        enableClipPreview = true;
        enableClipboardChips = true;
        enableClipboardHistory = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        ignoreMouseInput = false;
        overviewLayer = false;
        pinnedApps = [ ];
        position = "center";
        screenshotAnnotationTool = "";
        showCategories = true;
        showIconBackground = false;
        sortByMostUsed = true;
        terminalCommand = "alacritty -e";
        viewMode = "list";
      };
      audio = {
        mprisBlacklist = [ ];
        preferredPlayer = "";
        spectrumFrameRate = 30;
        spectrumMirrored = true;
        visualizerType = "linear";
        volumeFeedback = true;
        volumeFeedbackSoundFile = "";
        volumeOverdrive = false;
        volumeStep = 1;
      };
      bar = {
        autoHideDelay = 500;
        autoShowDelay = 150;
        backgroundOpacity = 1;
        barType = "simple";
        capsuleColorKey = "none";
        capsuleOpacity = 0.9;
        contentPadding = 2;
        density = "normal";
        displayMode = "always_visible";
        enableExclusionZoneInset = true;
        fontScale = 1.2;
        frameRadius = 0;
        frameThickness = 8;
        hideOnOverview = false;
        marginHorizontal = 4;
        marginVertical = 4;
        middleClickAction = "none";
        middleClickCommand = "";
        middleClickFollowMouse = false;
        monitors = [
          "HDMI-A-4"
          "DP-3"
        ];
        mouseWheelAction = "none";
        mouseWheelWrap = true;
        outerCorners = false;
        position = "top";
        reverseScroll = false;
        rightClickAction = "controlCenter";
        rightClickCommand = "";
        rightClickFollowMouse = true;
        screenOverrides = [
          {
            density = "mini";
            enabled = true;
            name = "DP-3";
            widgets = {
              center = [
                {
                  clockColor = "none";
                  customFont = "";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = false;
                }
              ];
              left = [
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  followFocusedScreen = false;
                  fontWeight = "bold";
                  groupedBorderOpacity = 1;
                  hideUnoccupied = true;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "index";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                  showApplications = true;
                  showApplicationsHover = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = false;
                  unfocusedIconsOpacity = 1;
                }
              ];
              right = [ ];
            };
          }
        ];
        showCapsule = true;
        showOnWorkspaceSwitch = true;
        showOutline = false;
        useSeparateOpacity = true;
        widgetSpacing = 6;
        widgets = {
          center = [
            {
              clockColor = "none";
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              id = "Clock";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
            }
          ];
          left = [
            {
              defaultSettings = { };
              id = "plugin:workspace-overview";
            }
            {
              characterCount = 2;
              colorizeIcons = false;
              emptyColor = "secondary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              fontWeight = "bold";
              groupedBorderOpacity = 1;
              hideUnoccupied = true;
              iconScale = 0.8;
              id = "Workspace";
              labelMode = "index";
              occupiedColor = "secondary";
              pillSize = 0.6;
              showApplications = true;
              showApplicationsHover = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = false;
              unfocusedIconsOpacity = 1;
            }
            {
              compactMode = true;
              hideMode = "hidden";
              hideWhenIdle = false;
              id = "MediaMini";
              maxWidth = 145;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = false;
              showArtistFirst = false;
              showProgressRing = true;
              showVisualizer = true;
              textColor = "none";
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          right = [
            {
              compactMode = false;
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
              showMemoryAsPercent = true;
              showMemoryUsage = false;
              showNetworkStats = false;
              showSwapUsage = false;
              textColor = "none";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              displayMode = "onhover";
              iconColor = "none";
              id = "Volume";
              middleClickCommand = "pwvucontrol || pavucontrol";
              textColor = "none";
            }
            {
              id = "plugin:display-settings";
            }
            {
              defaultSettings = {
                colorHistory = [ ];
                detectedRecorder = "";
                filenameFormat = "";
                gifMaxSeconds = 30;
                installedLangs = [ "eng" ];
                paletteColors = [ ];
                recordCopyToClipboard = false;
                recordSkipConfirmation = false;
                screenshotPath = "";
                selectedOcrLang = "eng";
                transAvailable = false;
                videoPath = "";
              };
              id = "plugin:screen-toolkit";
            }
            {
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              colorizeSystemText = "none";
              customIconPath = "";
              enableColorization = true;
              icon = "noctalia";
              id = "ControlCenter";
              useDistroLogo = true;
            }
          ];
        };
      };
      brightness = {
        backlightDeviceMappings = [ ];
        brightnessStep = 1;
        enableDdcSupport = false;
        enforceMinimum = true;
      };
      calendar = {
        cards = [
          {
            enabled = true;
            id = "calendar-header-card";
          }
          {
            enabled = true;
            id = "calendar-month-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
        ];
      };
      colorSchemes = {
        darkMode = false;
        generationMethod = "manual";
        manualSunrise = "06:00";
        manualSunset = "17:00";
        monitorForColors = "";
        predefinedScheme = "";
        schedulingMode = "auto";
        syncGsettings = true;
        useWallpaperColors = false;
      };
      controlCenter = {
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = false;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
        diskPath = "/";
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
      };
      desktopWidgets = {
        enabled = true;
        gridSnap = false;
        gridSnapScale = false;
        monitorWidgets = [
          {
            name = "DP-3";
            widgets = [
              {
                hideMode = "visible";
                id = "MediaPlayer";
                roundedCorners = true;
                showAlbumArt = true;
                showBackground = true;
                showButtons = true;
                showVisualizer = true;
                visualizerType = "linear";
                x = 422;
                y = 57;
              }
              {
                clockColor = "none";
                clockStyle = "digital";
                customFont = "";
                format = "HH:mm\\nd MMMM yyyy";
                id = "Clock";
                roundedCorners = true;
                scale = 2.151037257250227;
                showBackground = true;
                useCustomFont = false;
                x = 452;
                y = 221;
              }
            ];
          }
        ];
        overviewEnabled = true;
      };
      dock = {
        animationSpeed = 1;
        backgroundOpacity = 1;
        colorizeIcons = false;
        deadOpacity = 0.6;
        displayMode = "auto_hide";
        dockType = "floating";
        enabled = false;
        floatingRatio = 1;
        groupApps = false;
        groupClickAction = "cycle";
        groupContextMenuMode = "extended";
        groupIndicatorStyle = "dots";
        inactiveIndicators = false;
        indicatorColor = "primary";
        indicatorOpacity = 0.6;
        indicatorThickness = 3;
        launcherIcon = "";
        launcherIconColor = "none";
        launcherPosition = "end";
        launcherUseDistroLogo = false;
        monitors = [ ];
        onlySameOutput = true;
        pinnedApps = [ ];
        pinnedStatic = false;
        position = "bottom";
        showDockIndicator = false;
        showLauncherIcon = false;
        sitOnFrame = false;
        size = 1;
      };
      general = {
        allowPanelsOnScreenWithoutBar = true;
        allowPasswordWithFprintd = false;
        animationDisabled = false;
        animationSpeed = 1;
        autoStartAuth = false;
        avatarImage = "/home/nathanmcunha/.face";
        boxRadiusRatio = 1;
        clockFormat = "hh\\nmm";
        clockStyle = "custom";
        compactLockScreen = false;
        dimmerOpacity = 0.2;
        enableBlurBehind = true;
        enableLockScreenCountdown = true;
        enableLockScreenMediaControls = false;
        enableShadows = true;
        forceBlackScreenCorners = false;
        iRadiusRatio = 1;
        keybinds = {
          keyDown = [ "Down" ];
          keyEnter = [
            "Return"
            "Enter"
          ];
          keyEscape = [ "Esc" ];
          keyLeft = [ "Left" ];
          keyRemove = [ "Del" ];
          keyRight = [ "Right" ];
          keyUp = [ "Up" ];
        };
        language = "";
        lockOnSuspend = true;
        lockScreenAnimations = false;
        lockScreenBlur = 0.5;
        lockScreenCountdownDuration = 10000;
        lockScreenMonitors = [ ];
        lockScreenTint = 0;
        passwordChars = true;
        radiusRatio = 1;
        reverseScroll = false;
        scaleRatio = 1;
        screenRadiusRatio = 1;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        showChangelogOnStartup = true;
        showHibernateOnLockScreen = false;
        showScreenCorners = false;
        showSessionButtonsOnLockScreen = true;
        smoothScrollEnabled = true;
        telemetryEnabled = false;
      };
      hooks = {
        colorGeneration = "";
        darkModeChange = "echo \${1:-0} > ~/.config/noctalia/.darkmode";
        enabled = true;
        performanceModeDisabled = "";
        performanceModeEnabled = "";
        screenLock = "";
        screenUnlock = "";
        session = "";
        startup = "";
        wallpaperChange = "";
      };
      idle = {
        customCommands = "[]";
        enabled = false;
        fadeDuration = 5;
        lockCommand = "";
        lockTimeout = 300;
        resumeLockCommand = "";
        resumeScreenOffCommand = "";
        resumeSuspendCommand = "";
        screenOffCommand = "";
        screenOffTimeout = 600;
        suspendCommand = "";
        suspendTimeout = 1800;
      };
      location = {
        analogClockInCalendar = false;
        autoLocate = true;
        firstDayOfWeek = -1;
        hideWeatherCityName = false;
        hideWeatherTimezone = false;
        name = "Rio de Janeiro";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = true;
        weatherShowEffects = true;
        weatherTaliaMascotAlways = false;
      };
      network = {
        bluetoothAutoConnect = true;
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        bluetoothRssiPollIntervalMs = 60000;
        bluetoothRssiPollingEnabled = false;
        disableDiscoverability = false;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
      };
      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = false;
        forced = false;
        manualSunrise = "06:00";
        manualSunset = "17:00";
        nightTemp = "4000";
      };
      noctaliaPerformance = {
        disableDesktopWidgets = true;
        disableWallpaper = true;
      };
      notifications = {
        backgroundOpacity = 0.9;
        clearDismissed = true;
        criticalUrgencyDuration = 15;
        density = "default";
        enableBatteryToast = true;
        enableKeyboardLayoutToast = true;
        enableMarkdown = false;
        enableMediaToast = false;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [ ];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          critical = true;
          low = true;
          normal = true;
        };
        sounds = {
          criticalSoundFile = "";
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          lowSoundFile = "";
          normalSoundFile = "";
          separateSounds = false;
          volume = 0.5;
        };
      };
      osd = {
        autoHideMs = 2000;
        backgroundOpacity = 0.9;
        enabled = true;
        enabledTypes = [
          0
          1
          2
        ];
        location = "top_right";
        monitors = [ ];
        overlayLayer = true;
      };
      plugins = {
        autoUpdate = false;
        notifyUpdates = true;
      };
      sessionMenu = {
        countdownDuration = 10000;
        enableCountdown = true;
        largeButtonsLayout = "single-row";
        largeButtonsStyle = false;
        position = "center";
        powerOptions = [
          {
            action = "lock";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "1";
          }
          {
            action = "suspend";
            command = "";
            countdownEnabled = true;
            enabled = false;
            keybind = "";
          }
          {
            action = "hibernate";
            command = "";
            countdownEnabled = true;
            enabled = false;
            keybind = "";
          }
          {
            action = "reboot";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "2";
          }
          {
            action = "logout";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "3";
          }
          {
            action = "shutdown";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "4";
          }
          {
            action = "rebootToUefi";
            command = "";
            countdownEnabled = true;
            enabled = true;
            keybind = "5";
          }
          {
            action = "userspaceReboot";
            command = "";
            countdownEnabled = true;
            enabled = false;
            keybind = "";
          }
        ];
        showHeader = true;
        showKeybinds = true;
      };
      systemMonitor = {
        batteryCriticalThreshold = 5;
        batteryWarningThreshold = 20;
        cpuCriticalThreshold = 90;
        cpuWarningThreshold = 80;
        criticalColor = "";
        diskAvailCriticalThreshold = 10;
        diskAvailWarningThreshold = 20;
        diskCriticalThreshold = 90;
        diskWarningThreshold = 80;
        enableDgpuMonitoring = false;
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        gpuCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        memCriticalThreshold = 90;
        memWarningThreshold = 80;
        swapCriticalThreshold = 90;
        swapWarningThreshold = 80;
        tempCriticalThreshold = 90;
        tempWarningThreshold = 80;
        useCustomColors = false;
        warningColor = "";
      };
      templates = {
        activeTemplates = [
          {
            enabled = true;
            id = "discord";
          }
          {
            enabled = true;
            id = "gtk";
          }
          {
            enabled = false;
            id = "niri";
          }
          {
            enabled = true;
            id = "qt";
          }
          {
            enabled = true;
            id = "kitty";
          }
          {
            enabled = true;
            id = "helix";
          }
          {
            enabled = true;
            id = "pywalfox";
          }
          {
            enabled = true;
            id = "kcolorscheme";
          }
          {
            enabled = false;
            id = "starship";
          }
          {
            enabled = true;
            id = "btop";
          }
          {
            enabled = true;
            id = "zathura";
          }
          {
            enabled = true;
            id = "zen-browser";
          }
        ];
        enableUserTheming = true;
      };
      ui = {
        boxBorderEnabled = false;
        fontDefault = "Lexend";
        fontDefaultScale = 1;
        fontFixed = "Atkinson Hyperlegible Mono";
        fontFixedScale = 1;
        panelBackgroundOpacity = 0.9;
        panelsAttachedToBar = true;
        scrollbarAlwaysVisible = true;
        settingsPanelMode = "attached";
        settingsPanelSideBarCardStyle = false;
        tooltipsEnabled = true;
        translucentWidgets = true;
      };
      wallpaper = {
        automationEnabled = true;
        directory = "/home/nathanmcunha/Pictures/Wallpapers/gruvbox/wallpapers";
        enableMultiMonitorDirectories = false;
        enabled = true;
        favorites = [ ];
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = false;
        linkLightAndDarkWallpapers = true;
        monitorDirectories = [ ];
        overviewBlur = 0.4;
        overviewEnabled = false;
        overviewTint = 0.6;
        panelPosition = "follow_bar";
        randomIntervalSec = 1800;
        setWallpaperOnAllMonitors = true;
        showHiddenFiles = false;
        skipStartupTransition = false;
        solidColor = "#1a1a2e";
        sortOrder = "name";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        transitionType = [
          "fade"
          "disc"
          "stripes"
          "wipe"
          "pixelate"
          "honeycomb"
        ];
        useOriginalImages = false;
        useSolidColor = false;
        useWallhaven = false;
        viewMode = "recursive";
        wallhavenApiKey = "";
        wallhavenCategories = "111";
        wallhavenOrder = "desc";
        wallhavenPurity = "100";
        wallhavenQuery = "";
        wallhavenRatios = "";
        wallhavenResolutionHeight = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenSorting = "relevance";
        wallpaperChangeMode = "random";
      };
    };

    colors = {
      # Rosé Pine Dawn — https://rosepinetheme.com/
      mPrimary = "#286983";
      mOnPrimary = "#fffaf3";
      mSecondary = "#56949f";
      mOnSecondary = "#fffaf3";
      mTertiary = "#907aa9";
      mOnTertiary = "#fffaf3";
      mError = "#b4637a";
      mOnError = "#fffaf3";
      mSurface = "#faf4ed";
      mOnSurface = "#575279";
      mSurfaceVariant = "#fffaf3";
      mOnSurfaceVariant = "#797593";
      mOutline = "#9893a5";
      mShadow = "#f2e9e1";
      mHover = "#286983";
      mOnHover = "#fffaf3";
    };

    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        "kaomoji-provider" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "mirror-mirror" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "polkit-agent" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "screen-recorder" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "screen-toolkit" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "unicode-picker" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        "workspace-overview" = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };

    pluginSettings = {
      "screen-toolkit" = {
        colorHistory = [ "#E3ECEA" ];
        paletteColors = "";
        installedLangs = [ "eng" ];
        transAvailable = true;
        selectedOcrLang = "eng";
        screenshotPath = "";
        videoPath = "";
        filenameFormat = "";
        detectedRecorder = "";
        recordSkipConfirmation = false;
        recordCopyToClipboard = false;
        gifMaxSeconds = 30;
        resultHex = "#E3ECEA";
        resultRgb = "rgb(227, 236, 234)";
        resultHsv = "hsv(167, 4%, 93%)";
        resultHsl = "hsl(167, 19%, 91%)";
        colorCapturePath = "/tmp/screen-toolkit-colorpicker.png";
        colorCacheBust = 1780432368782;
        ocrResult = "";
        ocrCapturePath = "";
        qrResult = "";
        qrCapturePath = "";
        translateResult = "";
      };
    };

    user-templates = {
      templates = {
        alacritty = {
          input_path = "~/.config/noctalia/templates/alacritty-colors.toml";
          output_path = "~/.config/alacritty/theme-colors.toml";
        };
        dunst = {
          input_path = "~/.config/noctalia/templates/dunstrc";
          output_path = "~/.config/dunst/dunstrc";
          post_hook = "pkill dunst; dunst &";
        };
        hyprland = {
          input_path = "~/.config/noctalia/templates/hyprland-colors.conf";
          output_path = "~/.config/hypr/colors.conf";
          post_hook = "hyprctl reload";
        };
        hyprlock = {
          input_path = "~/.config/noctalia/templates/hyprlock.conf";
          output_path = "~/.config/hypr/hyprlock.conf";
        };
        omp = {
          input_path = "~/.config/noctalia/templates/omp-theme.json";
          output_path = "~/.omp/agent/themes/noctalia.json";
        };
        opencode = {
          input_path = "~/.config/noctalia/templates/opencode-theme.json";
          output_path = "~/.config/opencode/themes/noctalia.json";
        };
        wofi = {
          input_path = "~/.config/noctalia/templates/wofi-style.css";
          output_path = "~/.config/wofi/style.css";
        };
      };
    };
  };

  home = {
    packages = with pkgs; [
      # dependencies required by noctalia plugins and features
      gpu-screen-recorder
      (tesseract.override {
        enableLanguages = [ "eng" ];
      })
      zbar
      translate-shell
      gifski
      wl-mirror
    ];
    file = {
      ".config/noctalia/templates/hyprland-colors.conf".source =
        ../files/noctalia/templates/hyprland-colors.conf;
      ".config/noctalia/templates/wofi-style.css".source = ../files/noctalia/templates/wofi-style.css;
      ".config/noctalia/templates/dunstrc".source = ../files/noctalia/templates/dunstrc;
      ".config/noctalia/templates/alacritty-colors.toml".source =
        ../files/noctalia/templates/alacritty-colors.toml;
      ".config/noctalia/templates/hyprlock.conf".source = ../files/noctalia/templates/hyprlock.conf;
      ".config/noctalia/templates/opencode-theme.json".source =
        ../files/noctalia/templates/opencode-theme.json;
      ".config/noctalia/templates/omp-theme.json".source = ../files/noctalia/templates/omp-theme.json;
    };
  };

  # colors.json must be force-managed because the activation script
  # replaces the store symlink with a writable copy (Noctalia needs
  # runtime writes), making subsequent home-manager checkLinkTargets
  # see a conflicting file.
  xdg.configFile."noctalia/colors.json".force = true;

  home.activation.noctaliaColorsWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    colorsFile="$HOME/.config/noctalia/colors.json"
    if [ -L "$colorsFile" ]; then
      target="$(readlink -f "$colorsFile")"
      rm "$colorsFile"
      cp "$target" "$colorsFile"
      chmod u+w "$colorsFile"
    fi
  '';
  home.activation.restartNoctalia = lib.hm.dag.entryAfter [ "noctaliaColorsWritable" ] ''
    if pgrep -x quickshell > /dev/null 2>&1; then
      pkill -x quickshell
      hyprctl dispatch exec noctalia-shell
    fi
  '';
}
