{pkgs, ...}:
builtins.map (
  lang-with-test: import ./each-lang.nix {inherit pkgs;} lang-with-test
)
