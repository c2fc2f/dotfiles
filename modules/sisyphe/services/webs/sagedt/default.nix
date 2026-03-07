{
  mainDomain,
  ...
}:

{
  users.users.sagedt = {
    isSystemUser = true;
    group = "sagedt";
  };

  users.groups.sagedt = { };

  systemd.services.sagedtAPI = {
    description = "API Rust - Sagedt";
    after = [ "network.target" ];

    serviceConfig = {
      User = "sagedt";
      Group = "sagedt";
      WorkingDirectory = "/opt/ADEcampus-API/";
      ExecStart = "/opt/ADEcampus-API/target/release/ADEcampus";
      Restart = "always";
      Environment = "RUST_LOG=info";
    };

    wantedBy = [ "multi-user.target" ];
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "sagedt";
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.3:11593";
            check = true;
          }
        ];
        extraConfig = "http-request set-path %[path,regsub(^/sagedt/?,/)]";
      }
    ];

    maps = {
      url = [
        {
          url = "api.${mainDomain}/sagedt";
          backend = "sagedt";
        }
      ];
    };
  };
}
