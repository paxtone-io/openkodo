---
name: curate
description: >
  Add and manage context entries in the .kodo/ knowledge base.
  Use to capture patterns, decisions, and learnings for future sessions.
---

# Curating Context Entries

## Overview

Build your project's knowledge base by curating context entries. Add patterns,
decisions, code preferences, and architectural notes. Context is automatically
loaded in future sessions, ensuring consistency and reducing repeated explanations.

**Core principle:** Capture once, use forever. Build institutional memory.

**Announce at start:** "I'm using the curate skill to add context."

## When to Use

- After establishing new patterns or conventions
- When making architecture decisions
- After discovering useful techniques
- When documenting code preferences
- After solving tricky problems
- Setting up new projects (capture team standards)

## CLI Commands

### Add Context

```bash
kodo curate add --category architecture --title "Service layer pattern"
kodo curate add --category testing --title "Integration test setup"
kodo curate add --category style --title "Error handling conventions"
kodo curate add --file docs/decision.md --category decisions
```

### List and Search

```bash
kodo curate list                        # Show all context entries
kodo curate list --category architecture
kodo curate search "error handling"
kodo curate search --recent             # Last 7 days
```

### Manage Entries

```bash
kodo curate edit <id>                   # Edit existing entry
kodo curate remove <id>                 # Remove entry
kodo curate validate                    # Check for stale/outdated entries
kodo curate export                      # Export to markdown
```

### Categories

```bash
kodo curate categories                  # List all categories
kodo curate stats                       # Show category statistics
```

## Integration with Kodo

**Before curating:**
```bash
kodo query "similar patterns"           # Check for duplicates
kodo learn list --category <category>   # Check related learnings
```

**After curating:**
```bash
kodo reflect --signal "Added new pattern: <description>"
kodo index rebuild                      # Update search index
```

**Workflow:**
```bash
# 1. Make architecture decision
# 2. Document in design doc
kodo extract docs/plans/2026-02-07-auth-design.md

# 3. Curate key points
kodo curate add --category architecture --title "Auth uses JWT"

# 4. Sync to team
kodo docs sync
```

## Context Categories

### architecture
High-level design patterns, service boundaries, system architecture

**Examples:**
- "Use hexagonal architecture with ports/adapters"
- "Services communicate via message queue"
- "Frontend uses micro-frontend pattern"

### testing
Test strategies, fixtures, mocking patterns

**Examples:**
- "Integration tests use testcontainers"
- "Mock external APIs in unit tests"
- "E2E tests run in isolated environments"

### code-style
Naming conventions, formatting, code organization

**Examples:**
- "Use descriptive variable names, avoid abbreviations"
- "Prefix private methods with underscore"
- "Group imports: stdlib, external, internal"

### database
Schema design, migration patterns, query optimization

**Examples:**
- "Use UUIDs for primary keys"
- "Always add indexes for foreign keys"
- "Migrations are immutable, never edit"

### api
Endpoint design, versioning, authentication

**Examples:**
- "REST endpoints follow /api/v1/{resource} pattern"
- "Use Bearer tokens for authentication"
- "Return 404 for missing resources, not 400"

### decisions
Architecture Decision Records (ADRs), technical choices

**Examples:**
- "Chose PostgreSQL over MySQL for JSON support"
- "Decided on microservices over monolith for scalability"
- "Using GraphQL for flexible client queries"

### workflows
Development processes, CI/CD, deployment

**Examples:**
- "Feature branches merge to main via PRs"
- "Run full test suite before deploying"
- "Deploy to staging first, then production"

### domain
Business logic, domain models, terminology

**Examples:**
- "User vs Customer distinction: Users are internal, Customers are external"
- "Order lifecycle: Draft → Submitted → Processing → Completed"
- "Subscription tiers: Free, Pro, Enterprise"

## The Process

### Adding New Context

1. Identify reusable pattern or decision
2. Check for existing similar entries: `kodo curate search`
3. Choose appropriate category
4. Write clear, actionable description
5. Add entry: `kodo curate add`
6. Verify with `kodo query`

### Interactive Curation

```bash
kodo curate add --category architecture --title "Service boundaries"
# Opens editor with template:

# Service boundaries

## Context
[Describe the pattern or decision]

## Rationale
[Why this approach?]

## Examples
[Show usage examples]

## Related
[Link to other context entries]
```

### Batch Curation

After design doc creation:

```bash
# Extract learnings
kodo extract docs/plans/design.md

# Review generated entries
kodo learn list --recent

# Curate selected patterns
kodo curate add --from-learning <learning-id>
```

## Best Practices

### Write Clear Descriptions

**Good:**
```
Always use async/await for database operations.
Never block the event loop with synchronous I/O.
```

**Bad:**
```
Database stuff should be async.
```

### Provide Examples

**Good:**
```
Error handling uses Result<T, E> pattern:

fn get_user(id: Uuid) -> Result<User, DatabaseError> {
    db.query_one("SELECT * FROM users WHERE id = $1", &[&id])
}
```

**Bad:**
```
Use Result for error handling.
```

### Link Related Context

```
Related context:
- See: architecture/service-layer.md
- See: database/connection-pooling.md
- ADR: docs/decisions/0003-error-handling.md
```

## Key Principles

- **Actionable content** - Clear what to do, not just theory
- **Examples included** - Show don't tell
- **Right category** - Easy to find later
- **Check duplicates** - Use `kodo curate search` first
- **Update index** - Run `kodo index rebuild` after bulk changes

## Red Flags

**You're doing it wrong if:**
- Adding vague descriptions without examples
- Not checking for duplicates first
- Mixing multiple topics in one entry
- Using wrong category (makes search harder)
- Not linking related context entries
- Forgetting to run `kodo reflect` after curating
