---
name: pq-init
description: Initialize the .plans directory structure for a project
allowed-tools: Bash, Glob
---

# pq-init

Initialize the plans directory structure for a project.

## Usage

```
/pq-init
```

No arguments required.

## Instructions

### Step 1: Determine Repository Root

Run `git rev-parse --show-toplevel` to get the absolute path of the repository root. The `.plans` directory MUST be created at the repository root — never in the current working directory or any subdirectory.

### Step 2: Create Plans Directory

Create a `.plans` directory at the repository root (e.g. `<repo-root>/.plans`) if it does not already exist.

### Step 3: Create .gitkeep

Create an empty `.plans/.gitkeep` file so the directory is tracked by git.

### Step 4: Report

Confirm to the user that `.plans/` has been initialized at the repository root, showing the absolute path.

If the directory already exists, inform the user and take no action.
