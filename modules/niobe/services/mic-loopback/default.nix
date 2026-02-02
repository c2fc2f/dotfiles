{
  pkgs,
  ...
}:

{
  systemd.user.services.mic-loopback = {
    name = "Mic-Loopback";
    description = "Microphone loopback for self-monitoring";

    wantedBy = [
      "default.target"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.pipewire}/bin/pw-loopback --capture-props='node.name=mic_monitor_in' --playback-props='node.name=mic_monitor_out'";
      Restart = "on-failure";
    };
  };
}
