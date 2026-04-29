{
  pkgs,
  username,
  lib,
  ...
}:
let
  scrcpyCloner = pkgs.makeDesktopItem {
    name = "Phone Screen Cloner ";
    desktopName = "Clone Phone";
    exec = "${lib.getExe pkgs.scrcpy} --render-driver=opengl --turn-screen-off --stay-awake";
    icon = "${./assets/clone.jpg}";
    comment = "Launch scrcpy to clone phone screen and turn off the screen";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [ scrcpyCloner ];
  };
}
