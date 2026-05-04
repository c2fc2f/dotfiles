{
  pkgs,
  username,
  hostName,
  ...
}:

{
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  security.pam = {
    u2f = {
      settings = {
        cue = true;
      };
      control = "required";
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock.u2fAuth = true;
    };
  };

  home-manager.users.${username} = {
    home.packages = [
      pkgs.yubico-pam
      pkgs.yubikey-manager
    ];

    # pamu2fcfg -u `whoami` -opam://`hostname` -ipam://`hostname`
    home.file.".config/Yubico/u2f_keys".source = ./assets/${hostName};
  };
}
