{
  pkgs,
  lib,
  config,
  nix-wrapper,
  focal,
  niri,
  ...
}:
{
  programs.niri = {
    enable = true;
    # HORRIBLE SHIT I NEED TO USE FLAKE-PART !!!!!!!!!!!!!!!!!!!!!!!!!!!
    # TODO
    package = import ./_package.nix {
      inherit pkgs;
      inherit lib;
      inherit nix-wrapper;
      inherit focal;
      inherit niri;
    };
  };

  systemd.user.services.niri = {
    stopIfChanged = false;
  };

  # restart niri with new settings on rebuild
  system.userActivationScripts = {
    niri-reload-config = {
      text = lib.getExe (
        pkgs.writeShellApplication {
          name = "niri-reload-config";
          runtimeInputs = [
            config.programs.niri.package
            pkgs.procps
          ];
          text =
            let
              inherit
                (config.programs.niri.package.configuration.constructFiles.generatedConfig
                )
                outPath
                ;
            in
            ''
              if pgrep -x "niri" > /dev/null; then
                niri msg action load-config-file --path "${outPath}"
              fi
            '';
        }
      );
    };
  };
}
