{ dryRun ? true
, keymaster
, testVar ? "sometestvar"
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};
  nix = pkgs.nix;

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
      buildInputs = [
        nix
      ];
      name = "keymaster-release";
      buildCommand = ''
        export NIX_REMOTE=daemon
        set -x
        whoami
        mkdir -p $out
        cd ${keymaster}
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure
      '';
    };
}
