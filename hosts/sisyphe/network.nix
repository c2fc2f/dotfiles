{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
  };

  systemd.network = {
    enable = true;
    networks."10-enp6s0" = {
      matchConfig = {
        Name = "enp6s0";
      };

      networkConfig = {
        Address = [
          "54.37.86.164/24"
          "2001:41d0:303:4ea4::/64"
        ];
        Gateway = [
          "54.37.86.254"
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
          Gateway = "2001:41d0:0303:4eff:00ff:00ff:00ff:00ff";
          GatewayOnLink = true;
        }
      ];
    };
  };
}
