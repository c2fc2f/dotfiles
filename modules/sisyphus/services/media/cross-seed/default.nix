{
  lib,
  clib,
  config,
  username,
  ...
}:

let
  cfg = config.custom.media;

  q = config.services.qbittorrent;
  p = config.services.prowlarr.settings.server;
  s = config.services.sonarr.settings.server;
  r = config.services.radarr.settings.server;

  indexer = 16;
in
{

  services.cross-seed = {
    enable = true;

    settings = {
      host = "127.0.0.68";
      port = 2468;

      action = "inject";

      matchMode = "flexible";
      linkDirs = [ "${cfg.directory}/cross-seed" ];
      linkType = "hardlink";
      dataDirs = [ "${cfg.directory}/downloads" ];

      includeSingleEpisodes = false;
      includeNonVideos = true;
      seasonFromEpisodes = 1;
      maxDataDepth = 3;

      outputDir = null;
    };

    useGenConfigDefaults = true;

    settingsFile = config.sops.templates."cross-seed.json".path;
  };

  sops.templates."cross-seed.json" = {
    content = ''
      {
        "apiKey": "${config.sops.placeholder."cross-seed/apiKey"}",
        "torznab": [
          ${builtins.concatStringsSep ",\n    " (
            map (
              idx:
              clib.rmBlank ''
                "http://${p.bindaddress}:${toString p.port}${p.urlbase}
                /${toString idx}/api?apikey=${
                  config.sops.placeholder."prowlarr/apiKey"
                }"
              ''
            ) (lib.range 1 indexer)
          )}
        ],
        "sonarr": [ 
          "http://${s.bindaddress}:${toString s.port}${s.urlbase}?apikey=${
            config.sops.placeholder."sonarr/apiKey"
          }" 
        ],
        "radarr": [ 
          "http://${r.bindaddress}:${toString r.port}${r.urlbase}?apikey=${
            config.sops.placeholder."radarr/apiKey"
          }"
        ],
        "torrentClients": [
          "qbittorrent:http://${username}:${
            config.sops.placeholder."cross-seed/qbittorrent/password"
          }@localhost:${toString q.webuiPort}"
        ]
      }
    '';
  };

  users.groups.${cfg.group}.members = [
    config.services.cross-seed.user
  ];

  systemd.services.cross-seed = {
    restartTriggers = [ config.sops.templates."cross-seed.json".path ];
    serviceConfig.ReadWritePaths = [ cfg.directory ];
  };

  systemd.tmpfiles.rules = [
    "d ${cfg.directory}/cross-seed ${cfg.permissions} nobody ${cfg.group} - -"
  ];
}
