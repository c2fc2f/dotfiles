{
  pkgs,
  lib,
  username,
  ...
}:

{
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  home-manager.users.${username} = { config, ... }: {
    programs.swaylock = {
      enable = true;

      settings = {
        image = "${./assets/background.jpg}";
        scaling = "fill";

        indicator-radius = 100;
        indicator-thickness = 10;

        ring-color = "cdd6f4";
        key-hl-color = "cc8822";
        line-color = "00000000";
        inside-color = "00000033";
        separator-color = "00000000";

        text-color = "cdd6f4";
        font = "JetBrainsMono Nerd Font";
        font-size = 22;

        ignore-empty-password = true;
      };
    };

    systemd.user.services.swaylock = {
      Unit = {
        Description = "Screen locker for Wayland";
        Documentation = [ "man:swaylock(1)" ];
        Before = [ "sleep.target" ];
        PartOf = [ "lock.target" ];
        After = [ "lock.target" ];
        OnSuccess = [ "unlock.target" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${lib.getExe config.programs.swaylock.package} -f";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "lock.target" ];
      };
    };
  };

  services.systemd-lock-handler.enable = true;

  security.pam.services.swaylock = { };
}
