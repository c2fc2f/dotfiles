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

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.1:8099";
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

    defaultBackend = name;
  };
}
