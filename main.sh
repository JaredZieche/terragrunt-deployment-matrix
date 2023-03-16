#!/bin/bash

set -o pipefail

FILES="${FILES}"
GITHUB_OUTPUT="${GITHUB_OUTPUT}"
GITHUB_STEP_SUMMARY="${GITHUB_STEP_SUMMARY}"

base_directory="${BASE_DIRECTORY:=src/terraform}"
providers="${PROVIDERS:=aws|azure}"
envs="${ENVS:=sbx|dev|stage|prod}"
regions="${REGIONS:=us-gov-west-1|us-gov-east-1}"
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
