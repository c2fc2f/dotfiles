{ pkgs, ... }:

{
  systemd.user.services.elgato-goxlr-loopback = {
    description = "Elgato HDMI to GoXLR Game loopback";
    wantedBy = [ "default.target" ];

    wants = [
      "pipewire.service"
      "wireplumber.service"
    ];
    after = [
      "pipewire.service"
      "wireplumber.service"
    ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.pipewire}/bin/pw-loopback \
          --capture-props='{ "target.object": "alsa_input.pci-0000_04_00.0.stereo-fallback" }' \
          --playback-props='{ "target.object": "alsa_output.usb-TC-Helicon_GoXLRMini-00.HiFi__Line1__sink" }'
      '';
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
