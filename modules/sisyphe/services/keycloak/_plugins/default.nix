{ pkgs, ... }:

{
  plugins = [
    (pkgs.callPackage ./tailcloakify { })
  ];
}
