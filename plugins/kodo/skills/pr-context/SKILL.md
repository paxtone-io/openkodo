---
name: pr-context
description: >
  Summarize session learnings relevant to current branch changes for PR descriptions.
  Use before creating a PR to enrich it with context from your development session.
---

# Pre-PR Context Capture

## Overview

Gather accumulated learnings and session context relevant to the current branch diff,
then format them as a PR description section. This bridges the gap between what you
learned during development and what reviewers need to understand.

**Core principle:** Every PR should carry the context that informed its implementation.

**Announce at start:** "I'm using the pr-context skill to gather context for this PR."

## When to Use

- Before creating a pull request
- Before writing PR descriptions
- When summarizing what was learned during implementation
- After completing a feature branch

## The Process

### Step 1: Gather Branch Context

```bash
# Get the branch diff
BASE_SHA=$(git merge-base HEAD main)
git diff --stat $BASE_SHA..HEAD
git log --oneline $BASE_SHA..HEAD

# Check learnings captured during this work
kodo query "recent learnings"
kodo learn list --since "$(git log --format=%ai $BASE_SHA | head -1)"
```

### Step 2: Analyze Learnings Relevance

For each learning captured during the branch lifetime:
1. Check if it relates to files changed in the diff
2. Check if it captures a key decision about the implementation
3. Filter out noise - only include learnings that help reviewers

### Step 3: Generate PR Context Section

Format the relevant context as:

```markdown
## Context

### Key Decisions
- [Decision 1]: [rationale from learnings]
- [Decision 2]: [rationale from learnings]

### Patterns Applied
- [Pattern 1]: [why it was chosen]

### Known Trade-offs
- [Trade-off 1]: [what was considered]

### Testing Notes
- [What was tested and how]
```

### Step 4: Offer PR Creation

After generating the context section, offer:

**"Context ready. Create PR with `kodo:commit-push-pr` or copy the context above?"**

## Integration with Kodo

**Context gathering:**
```bash
kodo query "decisions made"       # Architecture decisions
kodo query "patterns applied"     # Implementation patterns
kodo query "trade-offs"           # Known compromises
kodo learn list                   # All recent learnings
```

**After PR creation:**
```bash
kodo reflect --signal "PR created with context from session learnings"
```

## Key Principles

- **Relevant context only** - Don't dump all learnings, filter for the branch
- **Reviewer-focused** - Write for someone who wasn't in the session
- **Decision rationale** - Explain WHY, not just WHAT
- **Concise** - Keep context section under 200 words

## Red Flags

**You're doing it wrong if:**
- Including learnings unrelated to the branch changes
- Writing implementation details instead of context
- Skipping the relevance filter step
- Not checking `kodo learn list` for captured insights
