# GitHub Helper Skills (`jms-git-???`)

I want a set of Agent Skills for performing operations I commonly do after agentic development sessions, which Claude/Agent would be better at.

My usual workflow is:

* Work on something without realising I'm on a default (`main` or `master`) branch
* Sometimes committing to default branch
* Later realising I've enabled mandatory branching and pull requests so I cannot push
* Creating a new branch
* Moving my previous accidental commits to the new branch
* Committing with a message
* Pushing to the new branch
* Creating a PR
* Enabling Auto-Merge

Maybe a "jms-git-push" skill?

Steps:

* Check if on `main`/`master`
* Check if commits accidentally on that branch
* Offer to create new branch and ask for name (with suggestions)
* Relocate accidental commits to new branch
* Commit with concise but informative message (without authoring annotations)
* Push to branch
* Create a PR with suitable title and description detailing commit changes (without authoring annotations)
* Enable auto-merge
* Repos "CI/CD" processes will handle the rest
