{
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  security.pam = {
    u2f = {
      settings = {
        cue = true;

        origin = "nixos";
        appid = "nixos";

        pinverification = 1;

        # pamu2fcfg -u `whoami` -o nixos -i nixos
        authfile = "${./assets/u2f_keys}";
      };
      control = "required";
    };

    services.sudo.u2fAuth = true;
  };
}
