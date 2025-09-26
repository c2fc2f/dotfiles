{ noctalia, username, ... }:

{
  home-manager.users.${username} = {
    imports = [
      noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = {
        settingsVersion = 6;
        bar = {
          position = "top";
          backgroundOpacity = 1;
          monitors = [ ];
          density = "default";
          showCapsule = true;
          floating = false;
          marginVertical = 0.25;
          marginHorizontal = 0.25;
          widgets = {
            left = [
              {
                id = "SystemMonitor";
              }
              {
                id = "ActiveWindow";
              }
              {
                id = "MediaMini";
              }
            ];
            center = [
              {
                id = "Workspace";
              }
            ];
            right = [
              {
                id = "ScreenRecorder";
              }
              {
                id = "Tray";
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "Battery";
              }
              {
                id = "Volume";
              }
              {
                id = "Brightness";
              }
              {
                id = "NightLight";
              }
              {
                id = "Clock";
              }
              {
                id = "ControlCenter";
              }
            ];
          };
        };
        general = {
          avatarImage = "";
          dimDesktop = true;
          showScreenCorners = false;
          forceBlackScreenCorners = false;
          radiusRatio = 1;
          screenRadiusRatio = 1;
          animationSpeed = 1;
        };
        location = {
          name = "Tokyo";
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = false;
        };
        screenRecorder = {
          directory = "";
          frameRate = 60;
          audioCodec = "opus";
          videoCodec = "h264";
          quality = "very_high";
          colorRange = "limited";
          showCursor = true;
          audioSource = "default_output";
          videoSource = "portal";
        };
        wallpaper = {
          enabled = true;
          directory = "";
          enableMultiMonitorDirectories = false;
          setWallpaperOnAllMonitors = true;
          fillMode = "crop";
          fillColor = "#000000";
          randomEnabled = false;
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = "random";
          transitionEdgeSmoothness = 5.0e-2;
          monitors = [ ];
        };
        appLauncher = {
          enableClipboardHistory = false;
          position = "center";
          backgroundOpacity = 1;
          pinnedExecs = [ ];
          useApp2Unit = false;
          sortByMostUsed = true;
        };
        dock = {
          autoHide = false;
          exclusive = false;
          backgroundOpacity = 1;
          floatingRatio = 1;
          monitors = [ ];
          pinnedApps = [ ];
        };
        network = {
          wifiEnabled = true;
          bluetoothEnabled = true;
        };
        notifications = {
          doNotDisturb = false;
          monitors = [ ];
          location = "top_right";
          alwaysOnTop = false;
          lastSeenTs = 0;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          enableOSD = true;
        };
        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          cavaFrameRate = 60;
          visualizerType = "linear";
          mprisBlacklist = [ ];
          preferredPlayer = "";
        };
        ui = {
          fontDefault = "Roboto";
          fontFixed = "DejaVu Sans Mono";
          fontBillboard = "Inter";
          monitorsScaling = [ ];
          idleInhibitorEnabled = false;
        };
        brightness = {
          brightnessStep = 5;
        };
        colorSchemes = {
          useWallpaperColors = false;
          predefinedScheme = "Noctalia (default)";
          darkMode = true;
        };
        matugen = {
          gtk4 = false;
          gtk3 = false;
          qt6 = false;
          qt5 = false;
          kitty = false;
          ghostty = false;
          foot = false;
          fuzzel = false;
          vesktop = false;
          pywalfox = false;
          enableUserTemplates = false;
        };
        nightLight = {
          enabled = false;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
        };
      };
    };
  };
}
