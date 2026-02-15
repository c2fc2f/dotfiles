{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      (
        (pkgs.sage.override {
          requireSageTests = false;
        }).overrideAttrs
        (_: {
          doCheck = false;
        })
      )
    ];
  };
}
