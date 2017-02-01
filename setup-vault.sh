#!/usr/bin/env bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
    project_dir=$(greadlink -f "$(dirname $0)/..")
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    project_dir=$(readlink -f "$(dirname $0)/..")
else
    echo "Error: Unknown platform - $(uname -a)"
    exit 1
fi

if [[ -z $BOSH_CA_CERT || -z $BOSH_CLIENT_SECRET \
      -z $VAULT_ADDR || -z $VAULT_TOKEN || \
      -z $FOUNDATION_NAME ]]; then
  echo "one the following environment variables is not set: "
  echo
  echo "                 BOSH_CA_CERT"
  echo "                 BOSH_CLIENT_SECRET"
  echo "                 VAULT_ADDR"
  echo "                 VAULT_TOKEN"
  echo "                 FOUNDATION_NAME"
  echo
  exit 1
fi

export VAULT_HASH=secret/pmysql-$FOUNDATION_NAME-props

echo "requires files (rootCA.pem, director.pwd, deployment-props.json)"
vault write ${VAULT_HASH} \
  bosh-cacert=@$BOSH_CA_CERT \
  bosh-pass=$BOSH_CLIENT_SECRET \
  bosh-client-secret=$BOSH_CLIENT_SECRET \
  @deployment-props.json

vault read ${VAULT_HASH}