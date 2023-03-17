<!-- action-docs-description -->
## Description

'Check files to determine infrastructure deployment.'
'Useful when attempting to determine what changes will occur as the result of a pull request.'
<!-- action-docs-description -->

Example Workflow:

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
          provider: aws
          env: 'sbx|dev|stage|prod'
          region: 'us-west-1|us-east-1'
          resource_groups: 'cluster|lambdas'

  deploy:
    needs: test
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix: ${{ fromJson(needs.test.outputs.matrix) }}
    steps:
      - run: |
          echo "provider=${{ matrix.provider }}" >> $GITHUB_OUTPUT
          echo "env=${{ matrix.env }}" >> $GITHUB_OUTPUT
          echo "region=${{ matrix.region }}" >> $GITHUB_OUTPUT
          echo "resource_group=${{ matrix.resource_group }}" >> $GITHUB_OUTPUT
      - run: |
          echo "Planning ${{ format('{0}/{1}/{2}/{3}', matrix.provider, matrix.env, matrix.region, matrix.resource_group) }}" >> $GITHUB_STEP_SUMMARY
```

<!-- action-docs-inputs -->
## Inputs

| parameter | description | required | default |
| --- | --- | --- | --- |
| files | Files to inspect in order to make a decision on deployment | `true` |  |
| base-directory | The base directory relative to the repo root from which to capture paths | `true` | src/terraform |
| providers | Types of cloud providers to capture | `true` | aws |
| environments | What are the names of the environments to check for | `true` | sbx |
| regions | What are the available regions to deploy in | `true` | us-west-1 |
| resource_groups | Regex patterns to match that determines which directories terragrunt can be executed from | `true` | cluster |
| test | Trigger test function to search all files in base_directory and generate files list. | `false` |  |
<!-- action-docs-inputs -->

<!-- action-docs-outputs -->
## Outputs

| parameter | description |
| --- | --- |
| matrix | The include matrix that will be used to generate jobs. |
<!-- action-docs-outputs -->

<!-- action-docs-runs -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs -->
