{
  pkgs,
  config,
  mainDomain,
  ...
}:

{
  services.neo4j = {
    enable = true;

    https = {
      enable = false;
      listenAddress = "0.0.0.0:7473";
      advertisedAddress = "neo4j.${mainDomain}";

    };

    http = {
      enable = true;
      listenAddress = "0.0.0.0:7474";
      advertisedAddress = "neo4j.${mainDomain}";
    };

    bolt = {
      listenAddress = "0.0.0.0:7687";
      advertisedAddress = "neo4j.${mainDomain}";

      tlsLevel = "REQUIRED";
      sslPolicy = "bolt";
    };

    ssl.policies.bolt =
      let
        certDir = config.security.acme.certs.${mainDomain}.directory;
      in
      {
        clientAuth = "OPTIONAL";

        privateKey = "${certDir}/key.pem";
        publicCertificate = "${certDir}/cert.pem";
      };

    extraServerConfig = ''
      dbms.ssl.policy.bolt.enabled=true
      server.unmanaged_extension_classes=n10s.endpoint=/rdf
    '';
  };

  systemd.services.neo4j.preStart =
    let
      cfg = config.services.neo4j;
    in
    ''
      rm ${cfg.directories.plugins}/*
      ln -sf ${./apoc.conf} ${cfg.directories.home}/conf/apoc.conf
    ''
    + builtins.concatStringsSep "\n" (
      builtins.map (plugin: "ln -s ${plugin}/* ${cfg.directories.plugins}") (
        pkgs.callPackage ./_plugins { }
      )
    );

  users.groups.acme.members = [
    "neo4j"
  ];

  security.acme.certs.${mainDomain}.reloadServices = [
    "neo4j"
  ];

  networking.firewall.allowedTCPPorts = [
    7687
  ];

  custom.services.haproxy = {
    backends = [
      {
        name = "neo4j";
        mode = "http";
        servers =
          let
            server = config.services.neo4j.http;
          in
          [
            {
              name = "server1";
              addr = server.listenAddress;
              check = true;
            }
          ];
      }
    ];

    maps = {
      url =
        let
          server = config.services.neo4j.http;
        in
        [
          {
            url = server.advertisedAddress;
            backend = "neo4j";
          }
        ];
    };
  };
}
