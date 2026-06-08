_: prev: {
  custom = (prev.custom or { }) // {
    is-ctrl-pressed = prev.callPackage ./_is-ctrl-pressed { };
  };
}
