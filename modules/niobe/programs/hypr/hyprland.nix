{
  lib,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    wayland.windowManager.hyprland = {
      settings = {
        monitor = lib.mkForce [
          "DP-2,1920x1080@60,-1920x0,1"
          "HDMI-A-3,1920x1080@100,0x0,1"
          "DP-3,1920x1080@60,1920x0,1"
        ];

        workspace = lib.mkForce [
          "10,monitor:DP-2,default:true"
          "9,monitor:DP-3,default:true"
        ];

        device = [
          {
            name = "logitech-g-pro--1";
            sensitivity = "-0.7";
            accel_profile = "flat";
          }
        ];
      };
    };
  };
}
