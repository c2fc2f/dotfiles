{
  services.unbound = {
    enable = true;

    settings = {
      server = {
        interface = [
          "127.0.0.1"
          "::1"
        ];
        access-control = [
          "127.0.0.0/8 allow"
          "::1 allow"
        ];
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
