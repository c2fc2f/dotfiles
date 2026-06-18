{
  systemd.network = {
    networks."10-ens3" = {
      matchConfig = {
        Name = "ens3";
      };

      networkConfig = {
        Address = [ "185.224.129.103/28" ];

        Gateway = [ "185.224.129.97" ];

        DNS = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        KeepConfiguration = "yes";
        ConfigureWithoutCarrier = true;
      };
    };
  };
}
