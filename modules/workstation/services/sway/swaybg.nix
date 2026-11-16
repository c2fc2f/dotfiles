{ pkgs, lib, ... }:

{
  systemd.user.services.swaybg = {
    enable = true;

    description = "Swaybg wallpaper daemon";

    wantedBy = [ "niri.service" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.swaybg} -i ${./assets/background.jpg} -m fill";
      Restart = "on-failure";
    };
  };
}
