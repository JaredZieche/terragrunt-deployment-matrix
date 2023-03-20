#!/bin/bash

touch /tmp/ghoutput
touch /tmp/summary.md

export GITHUB_OUTPUT="/tmp/ghoutput"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"
export TEST=true

export INPUT_BASE_DIRECTORY="examples/src/terraform"
export INPUT_PROVIDERS="aws|azure"
export INPUT_ENVIRONMENTS="sbx|dev|stage|prod"
export INPUT_REGIONS="us-west-1|us-east-1|us-west-2|us-east-2"
export INPUT_RESOURCE_GROUPS="cluster|lambda"
export INPUT_GLOBAL_FILES='["examples/src/terraform/aws/terragrunt.hcl", "examples/src/terraform/aws/global.hcl"]'

printf -v joined '"%s", ' $(cat examples/standard.txt)

export INPUT_FILES=$(echo "[${joined%s,}\"ignore\"]")

docker run -v src:/src/ --rm -it --platform=linux/arm64 tg-action:latest

cat $GITHUB_OUTPUT
cat $GITHUB_STEP_SUMMARY
