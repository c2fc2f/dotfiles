{ pkgs, lib, ... }:
let
  lockScript = pkgs.writeShellApplication {
    name = "lock-all-sessions";

    runtimeInputs = with pkgs; [
      systemd
      custom.is-ctrl-pressed
    ];

    text = ''
      if is-ctrl-pressed; then
        exit 0
      fi

      loginctl lock-sessions
    '';
  };
in
{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  services.udev.extraRules = ''
    ACTION=="remove", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", RUN+="${lib.getExe lockScript}"
  '';
}
