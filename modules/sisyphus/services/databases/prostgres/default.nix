{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;

    enableTCPIP = true;

    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';

    authentication = pkgs.lib.mkOverride 10 ''
      #type   database  DBuser    auth-method    optional_ident_map
      local   all       postgres  peer           map=superuser_map
      local   sameuser  all       peer           map=superuser_map

      # ipv4
      host    sameuser  all       127.0.0.1/32   scram-sha-256
      # ipv6
      host    sameuser  all       ::1/128        scram-sha-256
    '';
  };
}
