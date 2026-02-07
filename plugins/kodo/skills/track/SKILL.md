---
name: track
description: >
  Track work in GitHub Projects - manage issues, PRs, sprint planning.
  Use for bug tracking, feature requests, and coordinating development work.
---

# Tracking Work in GitHub Projects

## Overview

Manage development work through GitHub Projects integration. Create issues, link PRs,
track sprint progress, and coordinate team work. Routes bugs, features, and tasks
to GitHub while keeping documentation in Notion.

**Core principle:** GitHub for bugs/features/tasks. Notion for documentation/ADRs.

**Announce at start:** "I'm using the track skill to manage GitHub work."

## When to Use

- Creating bugs or feature requests
- Linking code changes to issues
- Checking sprint status and progress
- Planning upcoming work
- After implementing features (link commits/PRs)
- Before starting new work (check existing issues)

## CLI Commands

### Create Issues

```bash
kodo track issue "Fix authentication bug"
kodo track issue "Add user export" --type feature
kodo track issue "Refactor auth module" --type task
```

### Link to Code

```bash
kodo track link #123                    # Link current branch to issue
kodo track link #123 --pr 456           # Link specific PR
kodo track link #123 --commit abc123    # Link specific commit
```

### Check Status

```bash
kodo track status                       # Show all open issues
kodo track status --mine                # Your assigned issues
kodo track status --sprint current      # Current sprint progress
```

### Sprint Planning

```bash
kodo track sprint                       # Show current sprint
kodo track sprint plan                  # Interactive sprint planning
kodo track sprint close                 # Close current, start next
```

## Integration with Kodo

**Before creating issues:**
```bash
kodo query "similar bugs"               # Check for duplicates
kodo query "architecture decisions"     # Check if already documented
```

**After completing work:**
```bash
kodo track link #123                    # Link issue to PR
kodo reflect --signal "Fixed by using X approach"
```

**Workflow routing:**
```bash
kodo flow route "bug description"       # Auto-routes to GitHub
kodo flow route "architecture doc"      # Auto-routes to Notion
```

## The Process

### Creating Issues from Code

When you encounter a bug or missing feature during implementation:

1. Document the issue clearly
2. Create with appropriate type and priority
3. Link to related code locations
4. Continue current work or switch context

```bash
# Found a bug while implementing
kodo track issue "Auth tokens expire too quickly" --type bug --priority high

# Feature gap discovered
kodo track issue "Add bulk export functionality" --type feature
```

### Linking Work

After implementing a feature:

1. Commit changes with issue reference
2. Link commits/PR to issue
3. Update issue status
4. Capture learnings

```bash
git commit -m "feat: add user export (#123)"
kodo track link #123
kodo track status #123        # Verify link
kodo reflect --signal "Implemented using streaming approach for memory efficiency"
```

### Sprint Planning

Before starting a sprint:

1. Review backlog with `kodo track status`
2. Check related context: `kodo query "sprint goals"`
3. Plan sprint with `kodo track sprint plan`
4. Track progress throughout sprint

## Routing Rules

**Auto-route to GitHub:**
- Contains keywords: bug, error, crash, fails, broken
- Contains keywords: feature, enhancement, implement, add
- Contains keywords: task, TODO, refactor, cleanup

**Route to Notion instead:**
- Architecture decisions
- Design documents
- API documentation
- Executive summaries

Use `kodo flow route <content>` to auto-determine destination.

## Key Principles

- **GitHub for actionable work** - Bugs, features, tasks
- **Link code to issues** - Always reference issue numbers
- **Check existing issues** - Use `kodo query` before creating
- **Sprint discipline** - Close sprints, capture learnings
- **Reflect after completion** - Document what worked

## Red Flags

**You're doing it wrong if:**
- Creating duplicate issues (didn't run `kodo query`)
- Putting architecture docs in GitHub issues
- Not linking PRs to issues
- Bypassing `kodo flow` for routing decisions
- Forgetting to capture learnings after issue completion
