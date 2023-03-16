<!-- action-docs-description -->
## Description

Check a list of changed files to determine where to execute a terragrunt command
<!-- action-docs-description -->

<!-- action-docs-inputs -->
## Inputs

| parameter | description | required | default |
| --- | --- | --- | --- |
| files | Files to inspect in order to make a decision on deployment | `true` |  |
| base-directory | The base directory relative to the repo root from which to capture paths | `true` | src/terraform |
| providers | Types of cloud providers to capture | `true` | aws|azure |
| environments | What are the names of the environments to check for | `true` | sbx|dev|stage|preprod|prod |
| regions | What are the available regions to deploy in | `true` | us-west-1|us-east-1 |
| resource_groups | Regex patterns to match that determines which directories terragrunt can be executed from | `true` | cluster|tenured/.* |
| test | if action should be run as a test only | `false` |  |
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
