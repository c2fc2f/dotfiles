{ pkgs, lib, ... }:

{
  users.users.atacc = {
    isSystemUser = true;
    group = "atacc";
    home = "/opt/atacc";
  };

  users.groups.atacc = { };

  systemd.services.atacc = {
    description = "ATACC";
    after = [ "network.target" ];
    confinement.packages = with pkgs; [
      nodejs_20
    ];

    serviceConfig = {
      User = "atacc";
      Group = "atacc";
      WorkingDirectory = "/opt/atacc/api/v1";
      ExecStart = "${lib.getExe pkgs.nodejs_20} app/api.js";
      Restart = "always";
    };

    wantedBy = [ "multi-user.target" ];
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "atacc";
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.1:3456";
            check = true;
          }
        ];
      }
    ];

    maps = {
      url = [
        {
          url = "atacc.sagbot.com";
          backend = "atacc";
        }
        {
          url = "atacc-edu.org";
          backend = "atacc";
        }
      ];
    };
  };
}
