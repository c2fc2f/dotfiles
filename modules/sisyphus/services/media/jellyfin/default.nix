{ mainDomain, config, ... }:
let
  name = "jellyfin";
in
{
  services.${name} = {
    enable = true;

    forceEncodingConfig = true;
  };

  systemd.services.jellyfin.serviceConfig = {
    BindReadOnlyPaths = [ config.custom.media.directory ];
  };

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];

  users.users.${config.services.jellyfin.user}.extraGroups = [
    config.custom.media.group
  ];

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.1:8096";
            check = true;
          }
        ];
      }
    ];

    maps = {
      url = [
        {
          url = "media.${mainDomain}";
          backend = name;
        }
      ];
    };
  };
}
