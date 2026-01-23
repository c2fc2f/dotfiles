{
  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/vda";
  };

  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    defaultGateway = {
      address = "74.208.126.1";
      interface = "ens6";
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens6";
    };

    interfaces.ens6 = {
      ipv4.addresses = [
        {
          address = "74.208.126.108";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "2607:f1c0:f08c:a900::1";
          prefixLength = 80;
        }
      ];
    };
  };
}
