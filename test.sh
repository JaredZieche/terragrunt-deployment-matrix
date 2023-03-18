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

files=($(find ${INPUT_BASE_DIRECTORY} -type f))
printf -v joined '"%s", ' "${files[@]}"

export INPUT_FILES=$(echo "[${joined%s,}\"ignore\"]")

echo "" > $GITHUB_OUTPUT
echo "" > $GITHUB_STEP_SUMMARY

./main.sh

cat $GITHUB_OUTPUT
cat $GITHUB_STEP_SUMMARY
