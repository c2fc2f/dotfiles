{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
  };

  systemd.network = {
    networks."10-enp6s0" = {
      matchConfig = {
        Name = "enp6s0";
      };

      networkConfig = {
        Address = [
          "51.255.74.102/24"
          "2001:41d0:1004:2666::/64"
        ];
        Gateway = [
          "51.255.74.254"
        ];
        DNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];

        KeepConfiguration = "yes";
        ConfigureWithoutCarrier = true;
      };

      routes = [
        {
          Gateway = "2001:41d0:1004:26ff:00ff:00ff:00ff:00ff";
          GatewayOnLink = true;
        }
      ];
    };
  };
}
