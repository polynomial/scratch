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
        set -x
        set
        cd ${keymaster}
        find .
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure
      '';
    };
}
