# Phase: 09-datetime-handling-fix

## Overview

* Rename `jp-persona-*` to just `role-*`, leaving all other skills with `jp-` prefix
* Date/timestamps in `state.yml` and logs and other artifacts are just wrong, correct date, time appears random
  * started_at: "2026-03-01T08:14:19Z", finished_at: "2026-03-01T08:14:49Z"
  * time currently is 20:04, and no way that task took 30ms, enforce correct timestamps using $(date) or equivalent
