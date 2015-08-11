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
        declare -r -x NIX_REMOTE=daemon
        declare -r -x Z_DEPLOYMENT_ENV_TYPE="dev"
        declare -r -x Z_DEPLOYMENT_TARGET="ec2"
        declare -r -x Z_DEPLOYMENT_PROFILE="singlenode"
        set -x
        curl http://169.254.169.254/latest/meta-data
        curl http://169.254.169.254/latest/meta-data/iam/security-credentials
        curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy
        declare -r -x AWS_ACCESS_KEY_ID=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.AccessKeyId' |sed 's/"//g')
        declare -r -x AWS_SECRET_ACCESS_KEY=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.SecretAccessKey' |sed 's/"//g')
        mkdir -p $out
        cd ${keymaster}
        ./z/bin/nixops-provision | tee $out/nixops-provision.log
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure.log
      '';
    };
}
