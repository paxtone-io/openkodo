---
name: flow
description: >
  Route content to right destination - GitHub for bugs/features, Notion for docs.
  Use for intelligent content routing and workflow automation.
---

# Routing Content with Flow

## Overview

Automatically route content to the right destination based on content analysis.
GitHub for actionable work (bugs, features, tasks). Notion for documentation
(ADRs, wikis, guides). Local `.kodo/` for learnings and patterns.

**Core principle:** Content goes where it's most useful. No manual routing decisions.

**Announce at start:** "I'm using the flow skill to route this content."

## When to Use

- Unsure whether content belongs in GitHub or Notion
- Creating mixed content (bug + design notes)
- Building automated workflows
- Configuring routing rules
- Auditing where content lives

## CLI Commands

### Route Content

```bash
kodo flow route "user authentication fails"     # Auto-routes to GitHub
kodo flow route "architecture decision on..."   # Auto-routes to Notion
kodo flow route --preview "content..."          # Preview without executing
kodo flow route --file docs/plan.md             # Route entire file
```

### Check Status

```bash
kodo flow status                        # Show routing statistics
kodo flow status --recent               # Recent routing decisions
kodo flow status --errors               # Failed routings
```

### Configure Rules

```bash
kodo flow config                        # View current rules
kodo flow config edit                   # Edit routing.yaml
kodo flow config validate               # Validate rules
kodo flow config reset                  # Reset to defaults
```

## Integration with Kodo

**Before routing:**
```bash
kodo query "similar content"            # Check existing locations
kodo flow status --recent               # Check recent routing patterns
```

**After routing:**
```bash
kodo reflect --signal "Routed bug to GitHub, design notes to Notion"
```

**Complex routing:**
```bash
# Route different parts to different places
kodo flow route --split "Bug: auth fails. Design: use JWT tokens"
# Creates GitHub issue for bug, Notion page for design
```

## Routing Rules

### GitHub Routes

Content routes to GitHub when containing:
- **Bug keywords:** error, crash, fails, broken, bug, regression
- **Feature keywords:** add, implement, enhance, feature, enhancement
- **Task keywords:** refactor, cleanup, TODO, tech debt, task
- **Code references:** Line numbers, file paths, function names

Examples:
```bash
kodo flow route "Login button crashes on Safari"          # → GitHub issue
kodo flow route "Add user export feature"                 # → GitHub issue
kodo flow route "Refactor authentication module"          # → GitHub issue
```

### Notion Routes

Content routes to Notion when containing:
- **Decision keywords:** decided, chosen, ADR, decision, rationale
- **Architecture keywords:** architecture, design, pattern, system
- **Documentation keywords:** guide, wiki, documentation, API docs
- **Executive keywords:** summary, overview, roadmap, strategy

Examples:
```bash
kodo flow route "Architecture decision: use microservices"  # → Notion ADR
kodo flow route "API authentication guide"                  # → Notion wiki
kodo flow route "Q1 roadmap summary"                        # → Notion page
```

### Local Routes

Content routes to `.kodo/` when containing:
- **Learning keywords:** learned, pattern, always, never, rule
- **Preference keywords:** prefer, convention, style, standard
- **Team keywords:** team decided, we use, our approach

Examples:
```bash
kodo flow route "Always use async/await for I/O"           # → .kodo/learnings/
kodo flow route "Team prefers functional style"            # → .kodo/learnings/
```

## The Process

### Single Content Piece

For straightforward content:

1. Run `kodo flow route "content"`
2. Review routing decision
3. Confirm or override
4. Content created at destination

### Mixed Content

For content with multiple destinations:

1. Run `kodo flow route --split "content"`
2. Review split analysis
3. Adjust splits if needed
4. Confirm routing
5. Content created at all destinations with cross-links

Example:
```bash
kodo flow route --split "Bug: auth token expires too fast.
Design: increase TTL to 24h.
Learning: always set tokens to 24h minimum."

# Creates:
# - GitHub issue: "Auth token expires too fast"
# - Notion ADR: "Token TTL increased to 24h"
# - .kodo/learnings/: "Auth tokens: 24h minimum TTL"
```

### Workflow Automation

Configure automatic routing for common patterns:

1. Edit routing rules: `kodo flow config edit`
2. Add custom patterns
3. Validate: `kodo flow config validate`
4. Test with preview: `kodo flow route --preview`

## Configuration

**Default routing.yaml structure:**

```yaml
github:
  keywords: [bug, error, crash, feature, task, TODO]
  patterns:
    - "(?i)(fix|add|implement|enhance)"
    - "(?i)(broken|fails|doesn't work)"

notion:
  keywords: [architecture, ADR, design, guide, wiki]
  patterns:
    - "(?i)(decision|decided|chose)"
    - "(?i)(documentation|guide|overview)"

local:
  keywords: [learned, pattern, always, never, prefer]
  patterns:
    - "(?i)(always|never) (use|do)"
    - "(?i)(team|we) (use|prefer)"
```

## Key Principles

- **Analyze don't guess** - Use keyword/pattern matching
- **Preview before routing** - Use `--preview` flag
- **Split mixed content** - Use `--split` for complex content
- **Cross-link destinations** - Link GitHub issues to Notion docs
- **Validate rules regularly** - Check routing accuracy

## Red Flags

**You're doing it wrong if:**
- Manually deciding "this goes in GitHub" without running `kodo flow`
- Routing bugs to Notion or ADRs to GitHub
- Not using `--preview` for uncertain content
- Ignoring mixed content that needs splitting
- Not reviewing routing statistics with `kodo flow status`
