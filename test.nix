{ dryRun ? true
, keymaster
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
        mkdir -p $out
        set > $out/set
        find .. >$out/find
      '';
    };
}
