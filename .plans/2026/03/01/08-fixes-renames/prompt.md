# Phase: 08-fixes-renames

## Overview

* Move `jms-role-*` skills into `jplan`, e.g. (`jp-role-devops`), and update all references
* Rename roles to personas `jp-persona-devops`
* Rename `jp-developer` to `jp-worker-dev`, and update all references
* At the end of the execution loop after all items have been completed, but before presenting Push/PR options, run the `jp-persona-docs` skill to ensure documentation is up-to-date
* Generate an example Claude "settings.local.json" file that includes all the Allow permissions to use all the skills/agents in this repo as well as any tools and bash commands that are used by the skills/agents
* Rename `jp` skills as follows and update all references and docs:
  * `jp-plan-code-review` -> `jp-codereview`
  * `jp-plan-execute` -> `jp-execute`
  * `jp-plan-fix` -> `jp-codereview-fix`
  * `jp-plan-init` -> `jp-setup`
  * `jp-plan-new` -> `jp-plan`
  * `jp-plan-prd` -> `jp-prd`
  * `jp-plan-prd-review` -> `jp-prd-review`
  * `jp-plan-summary` -> `jp-summary`
  * `jp-plan-task-breakdown` -> `jp-task-list`
  * `jp-plan-task-review` -> `jp-task-review`
  * `jp-plan-task-validate` -> `jp-task-validate`
  * `jp-plan-workflow` -> `jp-quick`
