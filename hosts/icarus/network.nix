{
  systemd.network = {
    networks."10-ens6" = {
      matchConfig = {
        Name = "ens6";
      };

      networkConfig = {
        Address = [
          "74.208.126.108/24"
          "2607:f1c0:f08c:a900::1/80"
        ];

        Gateway = [
          "74.208.126.1"
          "fe80::1"
        ];

        DNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];

        IPv6AcceptRA = "yes";
        KeepConfiguration = "yes";
        ConfigureWithoutCarrier = true;
      };

      ipv6AcceptRAConfig = {
        UseOnLinkPrefix = true;
        UseAutonomousPrefix = true;
      };
    };
  };
}
