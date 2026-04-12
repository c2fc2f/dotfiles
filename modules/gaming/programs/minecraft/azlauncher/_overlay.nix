_: prev: {
  custom = (prev.custom or { }) // {
    azlauncher = prev.callPackage ./_package.nix { };
  };
}
