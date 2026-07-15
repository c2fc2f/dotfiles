{
  pkgs,
  username,
  config,
  ...
}:
let
  name = "heisenbridge";
  matrix = config.services.matrix-tuwunel;

  stateDir = "/var/lib/${name}";
  registrationFile = "${stateDir}/registration.yml";

  sharedGroup = "matrix-appservices";
in
{
  services.heisenbridge = {
    enable = true;

    owner = "@${username}:${matrix.settings.global.server_name}";
    homeserver = matrix.settings.global.well_known.client;
  };

  users.groups.${sharedGroup} = { };

  systemd = {
    services = {
      ${name}.serviceConfig = {
        SupplementaryGroups = [ sharedGroup ];

        ExecStartPost = [
          "+${pkgs.coreutils}/bin/chmod 0750 ${stateDir}"
          "+${pkgs.coreutils}/bin/chgrp ${sharedGroup} ${stateDir}"
          "+${pkgs.coreutils}/bin/chmod 0640 ${registrationFile}"
          "+${pkgs.coreutils}/bin/chgrp ${sharedGroup} ${registrationFile}"
        ];
      };

      tuwunel = {
        after = [ "${name}.service" ];
        wants = [ "${name}.service" ];

        serviceConfig = {
          SupplementaryGroups = [ sharedGroup ];
          BindReadOnlyPaths = [ stateDir ];
        };
      };
    };

    tmpfiles.rules = [
      "L+ ${matrix.settings.global.appservice_dir}/${name}.yaml - - - - ${registrationFile}"
    ];
  };
}
