{
  hostName,
  systemInfo,
  rootDomain,
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
        remoteHost = "${name}.${rootDomain}";
      }
    ))
  ];
in
{
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
          ExecStart =
            let
              inherit (config.services.shadowsocks) port;
              inherit (srv) remoteHost localIp;
            in
            ''
              ${pkgs.shadowsocks-rust}/bin/sslocal \
                --server-addr ${remoteHost}:${toString port} \
                --encrypt-method chacha20-ietf-poly1305 \
                --local-addr ${localIp}:1080 \
                --plugin ${lib.getExe pkgs.shadowsocks-v2ray-plugin} \
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
