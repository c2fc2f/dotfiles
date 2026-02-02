{
  pkgs,
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
  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override { flavor = "mocha"; })
  ];

  services.displayManager = {
    enable = true;
    sddm = {
      enable = true;
      theme = "catppuccin-mocha-mauve";
      # Don't work somehow
      autoNumlock = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_DRM_NO_ATOMIC = "1";
  };
}
