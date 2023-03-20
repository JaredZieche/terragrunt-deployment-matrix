#!/bin/bash

touch /tmp/ghoutput
touch /tmp/summary.md

echo 'GITHUB_OUTPUT="/tmp/ghoutput"' >> .env
echo 'GITHUB_STEP_SUMMARY="/tmp/summary.md"' >> .env
echo 'INPUT_BASE_DIRECTORY="examples/src/terraform"' >> .env
echo 'INPUT_PROVIDERS="aws|azure"' >> .env
echo 'INPUT_ENVIRONMENTS="sbx|dev|stage|prod"' >> .env
echo 'INPUT_REGIONS="us-west-1|us-east-1|us-west-2|us-east-2"' >> .env
echo 'INPUT_RESOURCE_GROUPS="cluster|lambda"' >> .env
echo 'INPUT_GLOBAL_FILES='["examples/src/terraform/aws/terragrunt.hcl", "examples/src/terraform/aws/global.hcl"]'' >> .env

printf -v joined '"%s", ' $(cat examples/standard.txt)

echo 'INPUT_FILES=$(echo "[${joined%s,}\"ignore\"]")' >> .env

docker run -v src:/src/ --rm -it --platform=linux/arm64 tg-action:latest
