{
  lib,
}:

n: text:
let
  spaces = lib.concatStrings (lib.replicate n " ");
  lines = lib.splitString "\n" text;
  filteredLines = if lines != [ ] && lib.last lines == "" then lib.init lines else lines;
in
lib.concatMapStringsSep "\n" (line: spaces + line) filteredLines
