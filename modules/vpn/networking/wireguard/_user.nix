{
  config,
  hostName,
  mainDomain,
  ...
}:
let
  wireconf = import ./_assets/users/${hostName}.nix;

  nameWithoutExt =
    path: builtins.head (builtins.match "(.*)\\.nix" (builtins.baseNameOf (toString path)));

  genInterfaces =
    files:
    builtins.listToAttrs (
      builtins.map (
        file:
        let
          conf = import file;
          name = nameWithoutExt file;
        in
        {
          name = "wg-${name}";
          value = {
            autostart = false;

            address = [
              "${conf.address.ipv6}${wireconf.suffix}/128"
              "${conf.address.ipv4}${wireconf.suffix}/32"
            ];

            privateKeyFile = config.sops.secrets."wireguard/privateKey".path;
            peers = [
              {
                inherit (conf) publicKey;
                allowedIPs = [
                  "::/0"
                  "0.0.0.0/0"
                ];
                endpoint = "${name}.${mainDomain}:51820";
              }
            ];
          };
        }
      ) files
    );
in
{
  networking.wg-quick.interfaces = genInterfaces [
    # keep-sorted start
    ./_assets/servers/icare.nix
    ./_assets/servers/sisyphe.nix
    # keep-sorted end
  ];
}
