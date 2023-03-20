[![build](https://github.com/JaredZieche/terragrunt-deployment-matrix/actions/workflows/test.yml/badge.svg)](https://github.com/JaredZieche/terragrunt-deployment-matrix/actions/workflows/test.yml)

This action is useful when attempting to determine what changes will occur as the result of a pull request. Currently modeled after a typical infrastructure layout using [Terragrunt](https://terragrunt.gruntwork.io/) and [Terraform](https://www.terraform.io/). Resulting output is generated in the form of an [include matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#example-expanding-configurations). This matrix can then be passed to a subsequent job using the matrix strategy to generate a job for each environment. Inputs are combined into a jq query and can use [jq regex syntax](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE) to generate the matrix.

This is written as a docker action mainly out of the need for simplicity and not having to manage package dependencies. That may change in the future. The current limitations of this action reside mainly around the strict ordering of the directories. Right now it expects a repository to be structured as provider/env/region/resource_group.

The `global_files` input allows you to define files that may be included by several descendant files through a terragrunt include block. If one of these files is detected in your list of files the action will find all descendant resource groups and pass them to the matrix output. The global change will only go as far as the definitions in your inputs. For example, if sbx and dev directories exist in a repo, but only sbx was defined in the `environments` input; that would result in all sbx resource groups being added to the matrix, but none for dev.

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

      - uses: jitterbit/get-changed-files@v1
        id: files
        with:
          format: 'json'

      - uses: JaredZieche/terragrunt-deployment-matrix@v2.0
        id: test
        with:
          files: ${{ steps.files.outputs.matrix }}
          base_directory: 'src/terraform'
          providers: aws|azure
          environments: 'sbx|dev|stage|prod'
          regions: 'us-west-1|us-east-1|us-central'
          resource_groups: 'cluster|lambdas'
          global_files: |
            'src/terraform/aws/global.hcl'
            'src/terraform/aws/terragrunt.hcl'

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

<!-- action-docs-description -->
## Description

Check files to determine paths for running infrastructure deployments via Terragrunt.
<!-- action-docs-description -->

<!-- action-docs-inputs -->
## Inputs

| parameter | description | required | default |
| --- | --- | --- | --- |
| files | Files to inspect in order to make a decision on deployment. ulti-line input, or string ["item1", "item2"] formats. | `true` |  |
| base-directory | The base directory relative to the repo root from which to capture paths | `true` | src/terraform |
| base_directory | The base directory relative to the repo root from which to capture paths | `true` | src/terraform |
| providers | Types of terraform providers to capture | `true` | aws |
| environments | What are the names of the environments to check for | `true` | sbx |
| regions | What are the available regions to deploy in | `true` | us-west-1 |
| resource_groups | Regex patterns to match that determines which directories terragrunt can be executed from | `true` | cluster |
| global_files | List of paths to files that effect all environments. Can be written as ["item1", "item2"] or as a multi-line input using | `false` |  |
<!-- action-docs-inputs -->

<!-- action-docs-outputs -->
## Outputs

| parameter | description |
| --- | --- |
| matrix | JSON formatted string for an include matrix that will be used to generate jobs. |
<!-- action-docs-outputs -->

<!-- action-docs-runs -->
## Runs

This action is a `docker` action.
<!-- action-docs-runs -->
