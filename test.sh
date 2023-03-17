#!/bin/bash

touch /tmp/ghoutput
touch /tmp/summary.md

export GITHUB_OUTPUT="/tmp/ghoutput"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"
export TEST=true

export BASE_DIRECTORY="examples/src/terraform"
export PROVIDERS="aws|azure"
export ENVS="sbx|dev|stage|prod"
export REGIONS="us-west-1|us-east-1|us-west-2|us-east-2"
export RESOURCE_GROUPS="cluster|lambda"

echo "" > $GITHUB_OUTPUT
echo "" > $GITHUB_STEP_SUMMARY

./main.sh

cat $GITHUB_OUTPUT
cat $GITHUB_STEP_SUMMARY
