{ pkgs, username, ... }:
/*
  OBS Studio, a comprehensive and highly extensible open-source application
  used for video recording, live streaming, and multimedia production. OBS
  Studio is widely used by content creators, educators, and streamers due to
  its powerful feature set, plugin support, and high configurability.
*/
{
  programs.adb.enable = true;

  users.users.${username}.extraGroups = [
    "adbusers"
  ];

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      droidcam-obs
    ];
  };
}
