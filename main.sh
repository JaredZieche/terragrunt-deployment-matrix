#!/bin/bash

set -o pipefail
function main() {
  FILES="${FILES}"

  base_directory="${BASE_DIRECTORY:=src/terraform}"
  providers="${PROVIDERS:=aws}"
  envs="${ENVS:=sbx}"
  regions="${REGIONS:=us-west-1|us-east-1}"
  resource_groups="${RESOURCE_GROUPS:=cluster|tenured.*}"

  query="$base_directory/(?<provider>$providers)/(?<env>$envs)/(?<region>$regions)/(?<resource_group>$resource_groups)/"
  matrix=$(echo "${FILES}" | jq --arg query "${query}" '{include: map(select(values) | capture($query))|unique}')
  paths=$(echo "${matrix}" | jq --raw-output '.include[] | "| " + .["provider"] + " | " + .["env"] + " | " + .["region"] + " | " + .["resource_group"] + " |"')

  echo ${matrix}
  echo "matrix=$(echo ${matrix[@]} | jq -s -c -r .[])" >> $GITHUB_OUTPUT
  echo "# Builds" >> $GITHUB_STEP_SUMMARY
  echo "| Provider | Env | Region | Resource Group |" >> $GITHUB_STEP_SUMMARY
  echo "| -------- | --- | ------ | -------------- |" >> $GITHUB_STEP_SUMMARY
  echo "${paths}" >> $GITHUB_STEP_SUMMARY
}

function testit() {
  files=($(cd examples && find src/terraform -type f))
  touch /tmp/ghoutput
  touch /tmp/summary.md
  printf -v joined '"%s", ' "${files[@]}"

  export FILES=$(echo "[${joined%,}\"test\"]")

  echo $FILES
}

if $TEST; then
  testit
  main
else
  main
fi

