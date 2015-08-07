{ dryRun ? true
, keymaster
, testVar ? "sometestvar"
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
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
