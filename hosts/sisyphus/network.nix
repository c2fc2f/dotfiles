{
  networking = {
    dhcpcd.enable = false;
    useNetworkd = true;

    firewall.allowedUDPPorts = [
      546
    ];
  };

  systemd.network = {
    enable = true;

    networks."10-enp65s0f0" = {
      matchConfig = {
        Name = "enp65s0f0";
      };

      linkConfig = {
        MACAddress = "7c:c2:55:a9:6c:d6";
      };

      networkConfig = {
        Address = [
          "195.154.246.203/24"
          "2001:bc8:30e5:100::1/56"
        ];
        Gateway = [
          "195.154.246.1"
        ];
        DNS = [
          "51.159.47.28"
          "51.159.47.26"
        ];

        DHCP = "ipv6";
        IPv6AcceptRA = "yes";

        KeepConfiguration = "yes";
        ConfigureWithoutCarrier = true;
      };

      dhcpV6Config = {
        DUIDType = "link-layer";
        DUIDRawData = "00:01:5b:5e:29:ad:40:2f";
      };

      ipv6AcceptRAConfig = {
        DHCPv6Client = "always";
        UseOnLinkPrefix = false;
        UseAutonomousPrefix = false;
      };
    };

    networks."10-enp65s0f1" = {
      matchConfig = {
        Name = "enp65s0f1";
      };

      linkConfig = {
        MACAddress = "7c:c2:55:a9:6c:d7";
      };

      networkConfig = {
        Address = [
          "10.88.211.11/25"
        ];
      };
    };
  };
}
