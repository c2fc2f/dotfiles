{
  username,
  mainDomain,
  builder,
  ...
}:

{
  nix.settings = {
    trusted-users = [
      "@wheel"
      username
    ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-substituters = [
      "ssh://${username}@${builder}.${mainDomain}"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    warn-dirty = false;

    auto-optimise-store = true;

    download-buffer-size = 1073741824;
  };
}
