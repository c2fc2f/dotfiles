/*
  nix-ld, a compatibility layer that allows running dynamically linked,
  non-Nix binaries by providing missing shared libraries at runtime. Useful
  for running prebuilt binaries not packaged with Nix.
*/
{ programs.nix-ld.enable = true; }
