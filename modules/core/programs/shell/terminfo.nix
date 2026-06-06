{ pkgs, ... }:
/*
  terminfo definitions for :
    - the Kitty terminal.

  This ensures proper terminal capabilities (like colors and key handling) are
  recognized by applications, especially when connecting to remote systems or
  using tools that rely on accurate terminfo entries.
*/
{ environment.systemPackages = [ pkgs.kitty.terminfo ]; }
