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
        mkdir -p $out/$keymaster
        set > $out/set
        find .. >$out/find
        find /nix/store >$out/store
      '';
    };
}
