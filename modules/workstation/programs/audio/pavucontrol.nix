{
  pkgs,
  username,
  ...
}:
/*
  pavucontrol, the PulseAudio Volume Control GUI. It allows users to manage
  audio input/output devices, adjust application-specific volumes, and
  configure audio routing.

  Especially useful for systems using PulseAudio.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.pavucontrol
    ];
  };
}
