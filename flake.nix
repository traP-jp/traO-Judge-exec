{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-2411.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:adisbladis/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gods = {
      url = "github:emirpasic/gods/v1.18.1";
      flake = false;
    };
    gonum = {
      url = "github:gonum/gonum/v0.15.1";
      flake = false;
    };
    gostl = {
      url = "github:liyue201/gostl/v1.2.0";
      flake = false;
    };
    golang-org-exp = {
      # No version tag available in the repository. (v0.0.0-20241009180824-f66d83c29e7c)
      url = "github:golang/exp/225e2abe05e664228e7afb6bf5b97a25d56ba575";
      flake = false;
    };
    seed7-source = {
      url = "github:ThomasMertes/seed7";
      flake = false;
    };
  };

  outputs = flake-inputs @ {
    self,
    nixpkgs,
    nixpkgs-2405,
    nixpkgs-2411,
    flake-utils,
    uv2nix,
    pyproject-nix,
    rust-overlay,
    gods,
    gonum,
    gostl,
    golang-org-exp,
    seed7-source,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      allpkgs = import ./allpkgs.nix {inherit flake-inputs system;};
      pkgs = allpkgs.default;
      interpreters = import ./interpreters {inherit allpkgs;};
      compilers = import ./compilers {inherit allpkgs;};
      tools = import ./tools {inherit allpkgs;};
      misc = import ./misc {inherit allpkgs;};
    in {
      packages = {
        environment = pkgs.symlinkJoin {
          name = "exec-container-enviroment";
          paths = [
            interpreters.all
            compilers.all
            tools.all
            misc.all
          ];
        };
        default = pkgs.dockerTools.buildImage {
          name = "exec-container";
          copyToRoot = pkgs.symlinkJoin {
            name = "exec-container-enviroment";
            paths = [
              self.packages.${system}.environment
              self.packages.${system}.languageSettings
            ];
          };
          config = {
            Env = [
              "TRAOJUDGE_LANGUAGES_JSON=/languages.json"
            ];
          };
        };
        languageSettings = import ./languageSettings.nix {inherit pkgs allpkgs;};

        test.all = let
          withTestFlatten =
            builtins.foldl' (
              acc: x: acc ++ x.languages
            ) []
            compilers.withTests;
        in
          import ./utils/tester/default.nix {inherit pkgs;} withTestFlatten;
        a =
          builtins.foldl' (
            acc: x: acc ++ x.languages
          ) []
          compilers.withTests;
        /*
        test = let
          # gplusplus = import ./compiler/g++ {inherit pkgs;};
          language-test = import ./utils/tester {inherit pkgs;};
        in
          language-test {
            language-name = "python3";
            testcase-name = "test1";
            compile-cmd = "cp $TRAOJUDGE_BUILD_SOURCE $TRAOJUDGE_BUILD_OUTPUT/main.py";
            run-cmd = "${pkgs.python3}/bin/python3 $TRAOJUDGE_BUILD_OUTPUT/main.py";
            source = "a = int(input())\nprint(a*2)";
            stdin = "\n5";
            expected-stdout = "10";
          };
        */
      };

      formatter = pkgs.alejandra;
    });
}
