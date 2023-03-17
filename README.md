[![build](https://github.com/JaredZieche/terragrunt-deployment-matrix/actions/workflows/test.yml/badge.svg)](https://github.com/JaredZieche/terragrunt-deployment-matrix/actions/workflows/test.yml)

<!-- action-docs-description -->

## Description

Check files to determine infrastructure deployment. Useful when attempting to determine what changes will occur as the result of a pull request. Currently modeled after a typical infrastructure layout using [Terragrunt](https://terragrunt.gruntwork.io/) and [Terraform](https://www.terraform.io/). Resulting output is generated in the form of an [include matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#example-expanding-configurations). This matrix can then be passed to a subsequent job using the matrix strategy to generate a job for each environment. Inputs are combined into a jq query and can use [jq regex syntax](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE)

<!-- action-docs-description -->

This is written as a composite action mainly out of the need for simplicity and not having to manage package dependencies. That may change in the future. The current limitations of this action reside mainly around the strict ordering of the directories. Right now it expects a repository to be structured as provider/env/region/resource_group.

## Example Workflow:

```

name: "deploy infrastructure"
on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main

jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.test.outputs.matrix }}
    steps:
      - uses: actions/checkout@v3
      - uses: zorg/terragrunt-deployment-matrix@v1.0
        id: test
        with:
          provider: aws|azure
          env: 'sbx|dev|stage|prod'
          region: 'us-west-1|us-east-1|us-central'
          resource_groups: 'cluster|lambdas'

  plan:
    if: github.event_name == 'pull_request'
    needs: setup
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix: ${{ fromJson(needs.setup.outputs.matrix) }}
    steps:
      - run: |
          echo "provider=${{ matrix.provider }}" >> $GITHUB_OUTPUT
          echo "env=${{ matrix.env }}" >> $GITHUB_OUTPUT
          echo "region=${{ matrix.region }}" >> $GITHUB_OUTPUT
          echo "resource_group=${{ matrix.resource_group }}" >> $GITHUB_OUTPUT
      - name: plan infrastructure changes
        env:
          DIR: ${{ format('{0}/{1}/{2}/{3}', matrix.provider, matrix.env, matrix.region, matrix.resource_group) }}
        run: |
          echo "Planning $DIR" >> $GITHUB_STEP_SUMMARY
          terragrunt run-all plan --terragrunt-working-dir $DIR

  apply:
    if: github.event_name == 'push'
    needs: setup
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix: ${{ fromJson(needs.setup.outputs.matrix) }}
    steps:
      - run: |
          echo "provider=${{ matrix.provider }}" >> $GITHUB_OUTPUT
          echo "env=${{ matrix.env }}" >> $GITHUB_OUTPUT
          echo "region=${{ matrix.region }}" >> $GITHUB_OUTPUT
          echo "resource_group=${{ matrix.resource_group }}" >> $GITHUB_OUTPUT
      - name: apply infrastructure changes
        env:
          DIR: ${{ format('{0}/{1}/{2}/{3}', matrix.provider, matrix.env, matrix.region, matrix.resource_group) }}
        run: |
          echo "Planning $DIR" >> $GITHUB_STEP_SUMMARY
          terragrunt run-all apply --terragrunt-working-dir $DIR
```

## Local testing:

Sets TEST environment variable to true. Exports GITHUB_OUTPUT and GITHUB_STEP_SUMMARY variables to tmp file paths.

```
./test.sh
```

<!-- action-docs-inputs -->

## Inputs

| parameter       | description                                                                               | required | default       |
| --------------- | ----------------------------------------------------------------------------------------- | -------- | ------------- |
| files           | Files to inspect in order to make a decision on deployment                                | `true`   |               |
| base-directory  | The base directory relative to the repo root from which to capture paths                  | `true`   | src/terraform |
| providers       | Types of terraform providers to capture                                                   | `true`   | aws           |
| environments    | What are the names of the environments to check for                                       | `true`   | sbx           |
| regions         | What are the available regions to deploy in                                               | `true`   | us-west-1     |
| resource_groups | Regex patterns to match that determines which directories terragrunt can be executed from | `true`   | cluster       |
| test            | Trigger test function to search all files in base_directory and generate files list.      | `false`  |               |

<!-- action-docs-inputs -->

<!-- action-docs-outputs -->

## Outputs

| parameter | description                                            |
| --------- | ------------------------------------------------------ |
| matrix    | The include matrix that will be used to generate jobs. |

<!-- action-docs-outputs -->

<!-- action-docs-runs -->

## Runs

This action is a `composite` action.

<!-- action-docs-runs -->
