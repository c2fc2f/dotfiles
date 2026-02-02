{
  pkgs,
  username,
  ...
}:
/*
  networkmanagerapplet, a system tray applet for managing network connections
  via NetworkManager. It provides a graphical interface to connect to Wi-Fi,
  VPNs, and other network types, typically used in desktop environments with a
  panel or system tray.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.networkmanagerapplet
    ];
  };
}
