{
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  security.pam = {
    u2f = {
      enable = true;

      settings = {
        cue = true;

        origin = "nixos";
        appid = "nixos";

        # pamu2fcfg -u `whoami` -o nixos -i nixos
        authfile = ./assets/u2f_keys;
      };
      control = "required";
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock.u2fAuth = true;
    };
  };
}
