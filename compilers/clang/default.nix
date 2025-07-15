{pkgs}: let
  myClang = pkgs.clang;
  myBoost = pkgs.boost;
  myGmp = pkgs.gmp;
  myEigen = pkgs.eigen;
  myAcLibrary = pkgs.ac-library;
  myZ3 = pkgs.z3;
  clangWrapper = pkgs.writeShellScriptBin "clang++" ''
    export LD_LIBRARY_PATH="${myBoost}/lib:${myGmp}/lib:${myEigen}/share:${myZ3.lib}/lib:$LD_LIBRARY_PATH"
    export LIBRARY_PATH="${myBoost}/lib:${myGmp}/lib:${myEigen}/share:${myZ3.lib}/lib:$LIBRARY_PATH"
    export CPLUS_INCLUDE_PATH="${myBoost.dev}/include:${myGmp.dev}/include:${myEigen}/include:${myAcLibrary.dev}/include:${myZ3.dev}/include:$CPLUS_INCLUDE_PATH"
    exec "${myClang}/bin/clang++" "$@" -lgmpxx -lgmp -lz3
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
            test1 = {
              source = builtins.readFile ./test1.cpp;
              stdin = "";
              stdout = builtins.readFile ./test1.stdout;
            };
            /*
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
