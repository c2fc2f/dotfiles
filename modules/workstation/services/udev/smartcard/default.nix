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
  nixpkgs.overlays = [ (import ./_overlay.nix) ];

  services.udev.extraRules = ''
    ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="0024",\
      ENV{ID_VENDOR_ID}=="349e",\
      ENV{ID_VENDOR}=="TOKEN2",\
      RUN+="${lib.getExe lockScript}"

    ACTION=="add",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="0024",\
      ENV{ID_VENDOR_ID}=="349e",\
      ENV{ID_VENDOR}=="TOKEN2",\
      ATTR{bInterfaceClass}=="0b",\
      RUN+="${pkgs.procps}/bin/pkill -TERM -f scdaemon"
  '';
}
