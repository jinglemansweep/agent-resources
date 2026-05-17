* Fix issue where agent reports ".plans" directory doesn't exist, and IT ALWAYS DOES
* Prefix all Plan/CRD/Execute skills as "jms-plan", e.g. "jms-plan-execute", "jms-plan-fix". Rename "jms-plan" skill to "jms-plan-prd"
* Add a new "Git" skill based on: https://github.com/openclaw/openclaw/blob/main/skills/github/SKILL.md
* Add a new workflow skill that wraps the entire plan/CRD/task/execute/summary pipeline/c
* Run all the Agent Skills through Anthropic's Skill Creator skill to ensure high quality
* Have a general purpose "Developer" agent that can use specific skills (Python, Node)?
  * I presume Agents get their own context window, and then call call reusable skills
  * Rewrite current language/skill specifc agents as skills and force "Developer" agent to call those skill
