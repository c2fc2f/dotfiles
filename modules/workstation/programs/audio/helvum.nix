{
  pkgs,
  username,
  ...
}:
/*
  helvum, a GTK-based patchbay for PipeWire. It provides a graphical interface
  to view and manage audio and MIDI routing between applications and devices
  in real time. Useful for users needing fine-grained control over their audio
  setup.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.helvum
    ];
  };
}
