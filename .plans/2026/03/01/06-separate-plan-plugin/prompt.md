# Phase: 06-separate-plan-plugin

## Overview

* At the end of the execution loop after code review iterations, ensure all quality gates pass before offering to create a PR.
* When offering to create push and create a PR, enable "auto-merge" if enabled (assuming required status checks configured)
* Separate "jms-plan" skills/agents into a separate plugin called "jplan", and change all agent/skill prefixes to "jp-*"
* "phase-new" should just be "plan-new", e.g. "jp-plan-new"
* Remove the "jms-git-push" skill, its mostly unncessary now
