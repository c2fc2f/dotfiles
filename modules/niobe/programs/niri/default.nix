{
  pkgs,
  lib,
  nix-wrapper,
  focal,
  niri,
  rootDomain,
  ...
}:
let
  # HORRIBLE SHIT I NEED TO USE FLAKE-PART !!!!!!!!!!!!!!!!!!!!!!!!!!!
  # TODO
  package = import ../../../workstation/programs/niri/_package.nix {
    inherit pkgs;
    inherit lib;
    inherit nix-wrapper;
    inherit focal;
    inherit niri;
    inherit rootDomain;
  };
in
{
  programs.niri.package = lib.mkForce (
    package.wrap {
      settings = {
        outputs = {
          "DP-2" = {
            mode = "1920x1080@60.000";
            position = _: {
              props = {
                x = -1920;
                y = 0;
              };
            };
          };
          "HDMI-A-3" = {
            mode = "1920x1080@100.047";
            position = _: {
              props = {
                x = 0;
                y = 0;
              };
            };
          };
          "DP-3" = {
            mode = "1920x1080@60.000";
            position = _: {
              props = {
                x = 1920;
                y = 0;
              };
            };
          };
        };

        input = {
          keyboard = {
            xkb.layout = "fr";
            numlock = true;
          };

          mouse = {
            accel-speed = -0.5;
            accel-profile = "flat";
          };
        };

        workspaces = {
          "entertainment".open-on-output = "DP-3";
          "chat".open-on-output = "DP-2";
        };
      };
    }
  );
}
