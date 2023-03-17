#!/bin/bash

touch /tmp/ghoutput
touch /tmp/summary.md

export GITHUB_OUTPUT="/tmp/ghoutput"
export GITHUB_STEP_SUMMARY="/tmp/summary.md"
export TEST=true

echo "" > $GITHUB_OUTPUT
echo "" > $GITHUB_STEP_SUMMARY

./main.sh

cat $GITHUB_OUTPUT
cat $GITHUB_STEP_SUMMARY
