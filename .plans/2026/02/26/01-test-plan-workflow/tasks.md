# Task List

> Source: `.plans/20260226/01-testing-the-plan-workflow/plan.md`

## README Content

### Project Header and Overview

- [x] **Write the project title and overview section in `README.md`** -- Add a top-level heading `# agent-resources` followed by a brief description introducing the repository as a collection of Claude Code plugins (skills and agents) distributed as a plugin marketplace. State that the repository currently contains the `plan-quick` plugin for planning workflows. Do not echo the aspirational marketplace description from `marketplace.json`. Note that the repo is designed to host multiple plugins. Include a line stating the project is licensed under GPL-3.0. Write this at the top of `README.md`, replacing the current empty file. Verify by reading the file and confirming the heading and description are present.

### Directory Structure

- [x] **Write the directory structure section in `README.md`** -- Add a `## Directory Structure` section after the overview. Include a Markdown code block showing the repository tree with the following paths and annotations:
  - `marketplace.json` -- marketplace metadata listing available plugins
  - `plugins/` -- directory containing all plugins
  - `plugins/plan-quick/` -- the plan-quick plugin directory
  - `plugins/plan-quick/plugin.json` -- plugin metadata (name, version, skills, agents)
  - `plugins/plan-quick/install.sh` -- installation script
  - `plugins/plan-quick/skills/` -- skill definitions
  - `plugins/plan-quick/agents/` -- agent definitions
  - `LICENSE` -- GPL-3.0 license
  - `README.md` -- this file

  Do not include the `.plans/` directory as it is a working artifact. Do not include `.git/` or `.claude/`. Verify the tree accurately reflects the actual repository contents.

### Plugin Documentation

- [x] **Write the plugins section in `README.md`** -- Add a `## Plugins` section. Structure it so additional plugins can be added later without restructuring. For the current plugin, add a `### plan-quick` subsection containing:
  - A brief description: "Quick and simple Plan, Review, Taskify and Execute skills" (from `plugins/plan-quick/plugin.json`)
  - Version: `0.1.0`
  - A list of the 6 skills provided: `pq-init`, `pq-phase-new`, `pq-plan`, `pq-review`, `pq-taskify`, `pq-execute`, each with a one-line description of what it does (derived from the skill names: init initializes the plans directory, phase-new creates a new planning phase, plan generates a plan from a prompt, review resolves plan issues, taskify generates a task list from a plan, execute runs implementation from a task list)
  - The agent provided: `pq-planner` -- a planner agent that guides through the full planning workflow
  - Verify the skill and agent lists match `plugins/plan-quick/plugin.json` exactly.

### Setup and Installation

- [x] **Write the setup and usage section in `README.md`** -- Add a `## Installation` section with step-by-step instructions:
  1. Clone the repository: `git clone <repo-url>` (use a placeholder URL since the remote is not configured)
  2. Navigate to the plugin directory: `cd plugins/plan-quick`
  3. Run the install script: `bash install.sh`
  4. Explain that this copies skills into `~/.claude/skills/` and agents into `~/.claude/agents/`
  5. Document the `CLAUDE_DIR` environment variable override: users can set `CLAUDE_DIR` to install to a custom location instead of `~/.claude/`
  - Verify the instructions match the actual behavior of `plugins/plan-quick/install.sh`.

### Configuration

- [x] **Write the configuration section in `README.md`** -- Add a `## Configuration` section. Document that:
  - Plugins may include their own `.claude/settings.local.json` with plugin-specific settings
  - The `plan-quick` plugin includes a `.claude/settings.local.json` at `plugins/plan-quick/.claude/settings.local.json`
  - The `install.sh` script copies skill and agent files but users may need to configure settings separately depending on their environment
  - Verify by reading `plugins/plan-quick/.claude/settings.local.json` to confirm what settings it contains and document them accurately.

### License Footer

- [x] **Add a license section at the bottom of `README.md`** -- Add a `## License` section as the final section of the README. State that the project is licensed under the GNU General Public License v3.0 and link to the `LICENSE` file in the repository. Keep this brief -- one or two sentences.

## Verification

- [x] **Review the complete `README.md` for accuracy and consistency** -- Read the entire `README.md` from top to bottom. Verify that: all file paths referenced actually exist in the repository, the plugin skill/agent lists match `plugins/plan-quick/plugin.json`, the installation instructions match `plugins/plan-quick/install.sh`, the directory structure matches the actual repo layout, and there are no references to the aspirational marketplace description. Confirm the document reads well as a whole and sections flow logically.
