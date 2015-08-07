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
      keymasterPath = keymaster;
      buildCommand = ''
        set -x
        mkdir -p $out
        mkdir -p $out/$keymaster
        set > $out/set
        find .. >$out/find
        find $keymasterPath >$out/keymaster-FILES
      '';
    };
}
