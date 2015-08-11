{ ... }:
import <nixpkgs> { inherit lib; }

stdenv.mkDerivation {
  name = "test.release";
  NIX_PATH="nixpkgs=${nixpkgs}";

  buildCommand = ''
    set
    access_key_id=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.AccessKeyId' |sed 's/"//g')
    secret_access_key=$(curl --silent http://169.254.169.254/latest/meta-data/iam/security-credentials/ci-deploy | jq '.SecretAccessKey' |sed 's/"//g')
    if [ -n "$access_key_id" -a -n "$secret_access_key" -a ! -f $HOME/.ec2-keys ]; then
      echo "$access_key_id $secret_access_key" >$HOME/.ec2-keys
    fi
  '';
  };
}
