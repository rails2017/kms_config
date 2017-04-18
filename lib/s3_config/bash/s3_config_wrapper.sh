#!/bin/bash

# Check that the environment variable has been set correctly
if [ -z "$S3_CONFIG_BUCKET" ]; then
  echo >&2 'error: missing S3_CONFIG_BUCKET environment variable'
  exit 1
fi
if [ -z "$S3_CONFIG_ENVIRONMENT" ]; then
  echo >&2 'error: missing S3_CONFIG_ENVIRONMENT environment variable'
  exit 1
fi
if [ -z "$S3_CONFIG_REVISION" ]; then
  echo >&2 'error: missing S3_CONFIG_REVISION environment variable'
  exit 1
fi

# Load the S3 secrets file contents into the environment variables
function load_config {
  local prefix=""
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  aws s3 cp s3://${S3_CONFIG_BUCKET}/${S3_CONFIG_ENVIRONMENT}/${S3_CONFIG_REVISION}.yml - |
  sed -ne "s|^\($s\):|\1|" \
      -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
       vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
       printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }' |
  sed 's/^/export /'
}
eval $(load_config)

# Run the entrypoint
eval "$@"
