_:

path:
builtins.head (
  builtins.match "(.*)\\.nix" (builtins.baseNameOf (toString path))
)
