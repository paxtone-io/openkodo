---
name: query
description: >
  Search accumulated context and learnings using fuzzy matching.
  Use to find patterns, decisions, and knowledge from past sessions.
---

# Querying Context and Learnings

## Overview

Search your project's accumulated knowledge base using fuzzy matching. Find patterns,
decisions, code preferences, and architectural notes from past sessions. Essential
before making decisions or implementing features to ensure consistency.

**Core principle:** Check context before acting. Avoid reinventing solutions.

**Announce at start:** "I'm using the query skill to search context."

## When to Use

- Before making architecture decisions
- Before implementing new features
- When stuck or unsure of approach
- Before creating new patterns
- After joining project (learn existing conventions)
- Starting new sessions (get up to speed)

## CLI Commands

### Basic Search

```bash
kodo query "error handling"             # Fuzzy search all content
kodo query "authentication"             # Search specific topic
kodo query "database migrations"        # Multi-word search
```

### Filtered Search

```bash
kodo query "testing" --category testing
kodo query "API" --category api,architecture
kodo query "patterns" --recent          # Last 30 days
kodo query "decisions" --since 2026-01-01
```

### Advanced Search

```bash
kodo query "auth" --type learnings      # Search learnings only
kodo query "auth" --type context        # Search context only
kodo query "auth" --confidence high     # High-confidence results
kodo query "auth" --format json         # JSON output for scripting
```

### List Categories

```bash
kodo query --categories                 # List all categories
kodo query --stats                      # Show statistics
```

## Integration with Kodo

**Common workflows:**

```bash
# Before implementing feature
kodo query "similar features"
kodo query "architecture patterns"

# Before making decision
kodo query "past decisions"
kodo learn list --category decisions

# After query (if no results)
kodo curate add --category <category>   # Add new context

# After implementation
kodo reflect --signal "Used pattern from query results"
```

## Query Syntax

### Simple Terms

```bash
kodo query "database"                   # Single term
kodo query "error handling"             # Phrase
kodo query "JWT tokens"                 # Specific technology
```

### Category Filtering

```bash
kodo query "patterns" --category architecture
kodo query "tests" --category testing,workflows
```

### Time-Based

```bash
kodo query "changes" --recent           # Last 30 days
kodo query "decisions" --since 2026-01-01
kodo query "patterns" --before 2026-02-01
```

### Confidence Filtering

```bash
kodo query "rules" --confidence high    # Established patterns
kodo query "ideas" --confidence medium  # Potential patterns
kodo query "notes" --confidence low     # Observations
```

## Understanding Results

### Result Format

```
[ARCHITECTURE] Service Layer Pattern (HIGH confidence)
Last updated: 2026-01-15
Location: .kodo/context-tree/architecture/service-layer.md

Use service layer to separate business logic from controllers.
Each service handles one domain entity.

Related: database/repositories.md, api/controllers.md
```

### Confidence Levels

**HIGH** - Established rules and decisions
- Design docs you created
- Explicit team decisions
- Validated patterns with multiple uses

**MEDIUM** - Likely patterns
- Observed from successful implementations
- Inherited documentation
- Patterns used 2-3 times

**LOW** - Observations and ideas
- Single-use patterns
- Experimental approaches
- Notes for further validation

### Search Ranking

Results ranked by:
1. **Exact matches** - Title or heading exact match
2. **Fuzzy matches** - Similar terms (typos, plurals)
3. **Content matches** - Term appears in body
4. **Recent updates** - More recent = higher rank
5. **Confidence** - High confidence ranked higher

## The Process

### Before Implementation

1. Query relevant topics: `kodo query "<feature>"`
2. Review results for existing patterns
3. Check related context (follow links)
4. Apply patterns or document new approach
5. After implementation: `kodo reflect`

### When Stuck

1. Query problem domain: `kodo query "<error>" --recent`
2. Check similar issues: `kodo query "<technology>"`
3. Review learnings: `kodo learn list`
4. If no results: `kodo track issue` or ask team
5. After solving: `kodo curate add`

### Regular Context Checks

Start each session:
```bash
kodo query --recent                     # What changed recently?
kodo query "<current-work>"             # Relevant patterns?
kodo learn list --recent                # Recent learnings?
```

## Query Patterns

### Feature Implementation

```bash
kodo query "authentication"             # Existing auth patterns
kodo query "user management"            # User handling approach
kodo query "API design"                 # API conventions
```

### Bug Investigation

```bash
kodo query "similar bugs"               # Has this happened before?
kodo query "<error-message>"            # Known error?
kodo query "debugging" --category workflows
```

### Refactoring

```bash
kodo query "refactoring patterns"       # Safe refactor approaches
kodo query "<component-name>"           # Component context
kodo query "test coverage"              # Testing requirements
```

### Architecture Decisions

```bash
kodo query "decisions" --category decisions
kodo query "<technology>" --confidence high
kodo query "architecture patterns"
```

## Key Principles

- **Query before acting** - Check context first, avoid duplicating work
- **Use categories** - Narrow results with `--category`
- **Follow related links** - Context is interconnected
- **Update after gaps** - If query returns nothing, curate after solving
- **Check confidence** - HIGH confidence = established rules

## Red Flags

**You're doing it wrong if:**
- Implementing without querying first
- Ignoring high-confidence results
- Not following related links
- Creating new patterns without checking for existing ones
- Not curating when query returns empty results
- Forgetting to reflect after using query results
