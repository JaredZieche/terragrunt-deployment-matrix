#!/bin/bash

files=($(cd ../../.. && find src/terraform -type f))
touch /tmp/ghoutput
touch /tmp/summary.md
printf -v joined '"%s", ' "${files[@]}"

export FILES=$(echo "[${joined%,}\"test\"]")
export GITHUB_OUTPUT="/tmp/ghoutput"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"

echo "" > $GITHUB_OUTPUT
echo "" > $GITHUB_STEP_SUMMARY

./main.sh
