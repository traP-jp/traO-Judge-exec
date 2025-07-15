{pkgs}: let
  myClang = pkgs.clang;
  /*
  myBoost = pkgs.boost;
  myGmp = pkgs.gmp;
  myEigen = pkgs.eigen;
  myAcLibrary = pkgs.ac-library;
  myZ3 = pkgs.z3;
  */
  clangWrapper = pkgs.writeShellScriptBin "clang++" ''
    exec "${myClang}/bin/clang++" "$@" -std=c++23
  '';
  compileCmd = cfg: pkgs.writeShellScriptBin "compile-clang" ''
    ${pkgs.coreutils}/bin/cp ${cfg.src} ${cfg.temp}/main.cpp && \
    ${clangWrapper}/bin/clang++ -std=c++23 -o ${cfg.out}/main.out ${cfg.temp}/main.cpp
  '';
in
  clangWrapper // {
    traojudge = {
      languages = [
        {
          main = {
            binName = "clang++";
            compile = cfg: "${compileCmd cfg}/bin/compile-clang";
            name = "C++(clang)";
            run = cfg: "${cfg.out}/main.out";
          };
          tests = {
            /*
            test1 = {
              source = builtins.readFile ./main.cpp;
              stdin = "";
              stdout = "Hello, World!";
            };
            */
            minimal = {
              source = builtins.readFile ./minimal.cpp;
              stdin = "";
              stdout = "";
            };
          };
        }
      ];
    };
  }
