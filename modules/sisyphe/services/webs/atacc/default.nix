{
  config,
  pkgs,
  lib,
  ...
}:
let
  name = "atacc";
in
{
  users.users.${name} = {
    isSystemUser = true;
    group = "atacc";
    home = "/opt/atacc";
  };

  users.groups.${name} = { };

  systemd.services.${name} = {
    description = "ATACC";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    confinement.packages = with pkgs; [
      nodejs_20
    ];

    environment = {
      PORT = "3456";
    };

    serviceConfig = {
      User = name;
      Group = name;

      WorkingDirectory = "/opt/atacc/api/v1";
      ExecStart = "${lib.getExe pkgs.nodejs_20} app/api.js";

      Restart = "always";

      EnvironmentFile = config.sops.secrets."atacc/env".path;

      # --- Isolation & Security Settings ---

      # 1. Network Isolation
      # Shared with the host to allow communication with HAProxy via localhost/IPs.
      PrivateNetwork = false;

      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      # Note: PrivateNetwork=true would create an isolated loopback,
      # making the service unreachable from outside its own namespace.

      # 2. File System Isolation
      # Makes the entire root filesystem read-only to the service
      ProtectSystem = "strict";
      # Hides /home, /root, and /run/user from the service
      ProtectHome = true;
      # Gives the service its own private /tmp and /var/tmp
      PrivateTmp = true;
      # Mounts a private /dev (hiding physical hardware)
      PrivateDevices = true;

      # 3. Restricting to Working Directory
      # Allows read/write ONLY in the working directory
      ReadWritePaths = [
        config.users.users.${name}.home
      ];
      # Prevents the service from seeing other sensitive paths
      InaccessiblePaths = [
        "/etc/ssh"
        "/root"
        "/home"
      ];

      # 4. System Information & Privilege Restriction
      # Prevents the service from gaining new privileges (setuid, etc.)
      NoNewPrivileges = true;
      # Provides a private /etc, /var, etc. (minimal environment)
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      # Hides other users' processes
      ProtectProc = "invisible";
      ProcSubset = "pid";

      # 5. Restrict System Calls
      # Only allows common system calls, blocking dangerous ones like @reboot
      SystemCallFilter = [
        "@system-service"
        "@pkey"
        "~@privileged"
        "~@resources"
      ];
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers =
          let
            inherit (config.systemd.services.atacc.environment) PORT;
          in
          [
            {
              name = "server1";
              addr = "127.0.0.1:${PORT}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = "atacc-edu.org";
          backend = name;
        }
      ];
    };
  };
}
