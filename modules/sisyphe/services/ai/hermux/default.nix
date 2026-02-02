{
  config,
  hermux,
  ...
}:

{
  imports = [
    hermux.nixosModules.hermux
  ];

  services.hermux = {
    enable = true;

    listen = {
      address = "127.0.0.33";
      port = 3333;
    };

    tokens = config.sops.secrets."hermux/tokens".path;
  };
}
