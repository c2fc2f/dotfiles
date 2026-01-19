{
  pkgs,
  username,
  firefox,
  ...
}:
/*
  This allows managing Firefox settings declaratively via Home Manager, such
  as enabling policies, setting preferences, or customizing profiles.
*/
{
  home-manager.users.${username} = {
    programs.firefox = {
      enable = true;
      package = firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;

      policies = {
        ExtensionSettings = {
          "*" = {
            private_browsing = true;
          };
        };
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "newtab";
      };

      profiles.default = {
        id = 0;
        isDefault = true;
        containersForce = true;

        settings = {
          "extensions.autoDisableScopes" = 0;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

          "privacy.trackingprotection.enabled" = true;

          "general.platform.override" = "Win32";

          "geo.enabled" = false;

          "toolkit.telemetry.enabled" = true;

          "browser.privatebrowsing.autostart" = true;
          "browser.translations.automaticallyPopup" = false;
          "browser.chrome.toolbar_tips" = false;
          "browser.ml.chat.enabled" = false;
          "browser.compactmode.show" = true;
          "browser.uidensity" = 1;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "browser.startup.homepage" = "about:blank";

          "browser.uiCustomization.state" = {
            placements = {
              "widget-overflow-fixed-list" = [ ];
              "unified-extensions-area" = [
                "sponsorblocker_ajay_app-browser-action"
                "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                "ublock0_raymondhill_net-browser-action"
              ];
              "nav-bar" = [
                "sidebar-button"
                "home-button"
                "back-button"
                "forward-button"
                "urlbar-container"
                "vertical-spacer"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "unified-extensions-button"
                "firefox-view-button"
              ];
              "toolbar-menubar" = [ "menubar-items" ];
              TabsToolbar = [ ];
              "vertical-tabs" = [ "tabbrowser-tabs" ];
              PersonalToolbar = [ "personal-bookmarks" ];
            };

            seen = [
              "reset-pbm-toolbar-button"
              "profiler-button"
              "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "sponsorblocker_ajay_app-browser-action"
              "developer-button"
              "screenshot-button"
            ];

            dirtyAreaCache = [
              "unified-extensions-area"
              "nav-bar"
              "TabsToolbar"
              "vertical-tabs"
              "toolbar-menubar"
              "PersonalToolbar"
              "widget-overflow-fixed-list"
            ];

            currentVersion = 22;
            newElementCount = 4;
          };

          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "always-show";

          "sidebar.backupState" = {
            panelOpen = false;
            launcherWidth = 55;
            expandedLauncherWidth = 303;
            launcherExpanded = false;
            launcherVisible = true;
            pinnedTabsHeight = 0;
            expandedPinnedTabsHeight = 0;
          };
        };

        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            privacy-badger
            ublock-origin
            bitwarden
            sponsorblock
          ];
        };
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      BROWSER = "firefox-nightly";
    };

    xdg.mimeApps.defaultApplications = {
      "text/html" = [
        "firefox-nightly.desktop"
      ];
      "x-scheme-handler/http" = [
        "firefox-nightly.desktop"
      ];
      "x-scheme-handler/https" = [
        "firefox-nightly.desktop"
      ];
      "x-scheme-handler/about" = [
        "firefox-nightly.desktop"
      ];
      "x-scheme-handler/unknown" = [
        "firefox-nightly.desktop"
      ];
    };
  };
}
