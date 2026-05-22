{
  hostName,
  systemInfo,
  mainDomain,
  config,
  lib,
  pkgs,
  ...
}:
let
  serversWithConfig = lib.pipe systemInfo [
    (lib.filterAttrs (
      name: info:
      name != hostName
      && builtins.elem "server" info.groups
      && builtins.elem "tunnels" info.groups
    ))

    builtins.attrNames
    (lib.imap1 (
      i: name: {
        inherit name;
        localIp = "127.0.0.${toString (i + 1)}";
        remoteHost = "${name}.${mainDomain}";
      }
    ))
  ];
in
{
  imports = lib.optional (builtins.elem "server"
    systemInfo.${hostName}.groups
  ) ./_server.nix;

  networking.hosts = builtins.listToAttrs (
    map (srv: {
      name = srv.localIp;
      value = [ "${srv.name}.proxy" ];
    }) serversWithConfig
  );

  systemd.services = builtins.listToAttrs (
    map (srv: {
      name = "shadowsocks-client-${srv.name}";
      value = {
        description = "Shadowsocks Rust Local Client - ${srv.name}";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = ''
            ${pkgs.shadowsocks-rust}/bin/sslocal \
              --server-addr ${srv.remoteHost}:8388 \
              --encrypt-method chacha20-ietf-poly1305 \
              --local-addr ${srv.localIp}:1080 \
              -6
          '';
          Restart = "on-failure";
          RestartSec = "5s";

          DynamicUser = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          PrivateTmp = true;

          EnvironmentFile = config.sops.templates."shadowsocks-client.env".path;
        };
      };
    }) serversWithConfig
  );

  sops.templates."shadowsocks-client.env" = {
    content = ''
      SS_SERVER_PASSWORD="${config.sops.placeholder."shadowsocks/password"}"
    '';
  };
}
