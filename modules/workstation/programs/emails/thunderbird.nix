{ username, ... }:

{
  home-manager.users.${username} = {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;

        withExternalGnupg = true;

        settings = {
          "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";
          "extensions.autoDisableScopes" = 0;

          "mail.default_send_format" = 1;
          "mail.identity.default.compose_html" = false;
          "mailnews.display.html_as" = 1;
          "mailnews.display.prefer_plaintext" = false;
          "mailnews.send_plaintext_flowed" = false;
        };
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
