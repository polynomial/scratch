{ dryRun ? true
, keymaster
, testVar ? "sometestvar"
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};
  nix = pkgs.nix;
  bash = pkgs.bash;
  jq = pkgs.jq;
  nixops = pkgs.nixopsUnstable;
  curl = pkgs.curl;

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
      buildInputs = [
        nix
        bash
        nixops
        curl
        jq
      ];
      name = "keymaster-release";
      buildCommand = ''
        export NIX_REMOTE=daemon
        set -x
        curl http://169.254.169.254/latest/meta-data
        curl http://169.254.169.254/latest/meta-data/iam/security-credentials
        curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy
        access_key_id=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.AccessKeyId' |sed 's/"//g')
        secret_access_key=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.SecretAccessKey' |sed 's/"//g')
        if [ -n "$access_key_id" -a -n "$secret_access_key" -a ! -f $HOME/.ec2-keys ]; then
          echo "$access_key_id $secret_access_key" >$HOME/.ec2-keys
        fi
        cat $HOME/.ec2-keys
        mkdir -p $out
        cd ${keymaster}
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure
      '';
    };
}
