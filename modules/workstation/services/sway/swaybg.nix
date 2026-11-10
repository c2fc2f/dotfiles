{ pkgs, lib, ... }:

{
  systemd.user.services.swaybg = {
    enable = true;

    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.swaybg} -i ${../../assets/background.jpg} -m fill";
      Restart = "on-failure";
    };
  };
}
