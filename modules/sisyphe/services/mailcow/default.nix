{
  mainDomain,
  ...
}:

{
  networking.firewall.allowedTCPPorts = [
    25
    465
    587
    143
    993
    110
    995
    4190
  ];

  custom.services.haproxy = {
    backends = [
      {
        name = "mailcow";
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.25:3380";
            check = true;
          }
        ];
      }
    ];

    maps.url = [
      {
        url = "mail.${mainDomain}";
        backend = "mailcow";
      }
    ];
  };
}
