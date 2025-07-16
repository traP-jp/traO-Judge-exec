{pkgs, ...}: let
  myHaskell = pkgs.haskell.compiler.ghc983;
in
  pkgs.writeShellScriptBin "ghc" "exec ${myHaskell}/bin/ghc $@"
  // {
    traojudge = {
      name = "Haskell";
      binName = "ghc";
      compile = ghc: "${myHaskell} \"$SRC\"";
      run = ghc: "exec \"$DIST\"";
    };
  }
