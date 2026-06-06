{
  networking.nat = {
    enable = true;

    externalInterface = "ens6";
    forwardPorts = [
      {
        sourcePort = 51413;
        proto = "tcp";
        destination = "10.6.0.5:51413";
      }
      {
        sourcePort = 51413;
        proto = "udp";
        destination = "10.6.0.5:51413";
      }
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 51413 ];
    allowedUDPPorts = [ 51413 ];
  };
}
