{ dryRun ? true
, keymaster
, root
, nixpkgs
, pipeline
, officialRelease ? false
}:

let

  pkgs = import <nixpkgs> {};
  nix = pkgs.nix;
  bash = pkgs.bash;
  strace = pkgs.strace;
  openssh = pkgs.openssh;
  jq = pkgs.jq;
  nixops = pkgs.nixopsUnstable;
  awscli = pkgs.awscli;
  curl = pkgs.curl;

in rec {

  release =
    with import <nixpkgs> { };
  
  
    stdenv.mkDerivation {
      buildInputs = [
        nix
        bash
        strace
        openssh
        nixops
        awscli
        curl
        jq
      ];
      name = "keymaster-release";
      buildCommand = ''
        set -x
        mkdir -p $out
        cd ${root}
        find .
        date >$out/date
        source z/setup/env.sh
        declare -r -x Z_DEPLOYMENT_TMPDIR=/tmp/$$
        mkdir -p $Z_DEPLOYMENT_TMPDIR
        declare -x HOME=$Z_DEPLOYMENT_TMPDIR
        declare -r -x DD_AGENT_KEY=null
        declare -r -x NIX_REMOTE=daemon
        declare -r -x Z_DEPLOYMENT_ENV_TYPE="dev"
        declare -r -x Z_DEPLOYMENT_TARGET="ec2"
        declare -r -x Z_DEPLOYMENT_PROFILE="singlenode"
        declare -r -x USER=hydra
        declare -r -x NIX_PATH="nixpkgs=${nixpkgs}:lookout=${pipeline}/channels/lookout"
        declare -r -x NIXOPS_STATE="$Z_DEPLOYMENT_TMPDIR/state.nixops"
        source /etc/hydra/ec2.environment
        #declare -r -x AWS_ACCESS_KEY_ID="$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.AccessKeyId' |sed 's/"//g')"
        #declare -r -x AWS_SECRET_ACCESS_KEY="$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.SecretAccessKey' |sed 's/"//g')"
        #declare -r -x AWS_SECURITY_TOKEN="$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.Token' |sed 's/"//g')"
        set
        cd ${keymaster}
        find .
        echo "$AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY dev" >$HOME/.ec2-keys
        bash -x ./z/bin/nixops-provision | tee $out/nixops-provision.log
        ./z/bin/validate-infrastructure | tee $out/validate-infrastructure.log
      '';
    };
}
