final: prev: {
  custom = (prev.custom or { }) // {
    chromium =
      (prev.custom.chromium or { })
      // (final.lib.mapAttrs
        (nom: _: final.callPackage (./. + "/${nom}") { })
        (
          final.lib.filterAttrs (_: type: type == "directory") (
            builtins.readDir ./.
          )
        )
      );
  };
}
