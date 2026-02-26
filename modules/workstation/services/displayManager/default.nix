{
  username,
  ...
}:
/*
  display manager — the graphical login screen that launches user sessions.
  This block allows you to:
   - Enable a specific display manager (e.g., GDM, SDDM, LightDM).
   - Customize session behavior, auto-login, and appearance.
   - Set the default session (like Hyprland, GNOME, KDE, etc.).
*/
{
  services.displayManager = {
    enable = true;

    autoLogin = {
      enable = true;
      user = username;
    };

    sddm = {
      enable = true;
      wayland.enable = true;
    };

    defaultSession = "hyprland";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_DRM_NO_ATOMIC = "1";
  };
}
