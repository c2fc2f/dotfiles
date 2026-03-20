{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.librewolf = {
      enable = true;

      policies = {
        DisableAccounts = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;

        EnableTrackingProtection = {
          Cryptomining = true;
          Fingerprinting = true;
          Locked = true;
          Value = true;
        };

        DisplayBookmarksToolbar = "never";

        DontCheckDefaultBrowser = true;

        ExtensionSettings =
          let
            moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
          in
          {
            "*" = {
              installation_mode = "blocked";
            };

            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = moz "bitwarden-password-manager";
              installation_mode = "force_installed";
              updates_disabled = false;
              private_browsing = true;
            };

            "sponsorBlocker@ajay.app" = {
              install_url = moz "sponsorblock";
              installation_mode = "force_installed";
              updates_disabled = false;
              private_browsing = true;
            };

            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = moz "privacy-badger17";
              installation_mode = "force_installed";
              updates_disabled = false;
              private_browsing = true;
            };

            "firefox-compact-dark@mozilla.org" = {
              install_url = moz "default-compact-dark-theme";
              installation_mode = "force_installed";
              updates_disabled = false;
              private_browsing = true;
            };

            "{3c078156-979c-498b-8990-85f7987dd929}" = {
              install_url = moz "sidebery";
              installation_mode = "force_installed";
              updates_disabled = false;
              private_browsing = true;
            };
          };
      };

      profiles.default = {
        id = 0;
        isDefault = true;
        containersForce = true;

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;

          "browser.privatebrowsing.autostart" = true;
          "browser.translations.automaticallyPopup" = false;
          "browser.chrome.toolbar_tips" = false;
          "browser.ml.chat.enabled" = false;
          "browser.compactmode.show" = true;
          "browser.uidensity" = 1;
          "browser.startup.homepage" = "about:blank";

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        userChrome = ''
          #TabsToolbar {
            visibility: collapse !important;
          }
          #sidebar-header {
            display: none;
          }
        '';

        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";

          engines =
            let
              nixIcons = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps";
            in
            {
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixIcons}/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };

              "Nix Options" = {
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixIcons}/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };

              "NixOS Wiki" = {
                urls = [
                  {
                    template = "https://wiki.nixos.org/w/index.php";
                    params = [
                      {
                        name = "search";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixIcons}/nix-snowflake.svg";
                definedAliases = [ "@nw" ];
              };

              "My NixOS" = {
                urls = [
                  {
                    template = "https://mynixos.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixIcons}/nix-snowflake.svg";
                definedAliases = [ "@my" ];
              };
            };
        };
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      BROWSER = "librewolf";
    };

    xdg.mimeApps.defaultApplications = {
      "text/html" = [
        "librewolf.desktop"
      ];
      "x-scheme-handler/http" = [
        "librewolf.desktop"
      ];
      "x-scheme-handler/https" = [
        "librewolf.desktop"
      ];
      "x-scheme-handler/about" = [
        "librewolf.desktop"
      ];
      "x-scheme-handler/unknown" = [
        "librewolf.desktop"
      ];
    };
  };
}
