---
name: docs
description: >
  Manage Notion documentation - sync agent docs, update wikis.
  Use for maintaining technical documentation and knowledge base.
---

# Managing Notion Documentation

## Overview

Synchronize documentation between local `.kodo/` context and Notion workspace.
Generate agent documentation, update wikis, and maintain technical knowledge base.
Routes architecture decisions, ADRs, and executive summaries to Notion.

**Core principle:** Single source of truth - `.kodo/` is authoritative, Notion is presentation layer.

**Announce at start:** "I'm using the docs skill to manage Notion documentation."

## When to Use

- After creating design documents
- After significant architecture changes
- When agent configurations change
- Syncing learnings to team knowledge base
- Generating executive summaries
- Updating API documentation

## CLI Commands

### Agent Documentation

```bash
kodo docs agent sync                    # Sync all agent docs to Notion
kodo docs agent status                  # Check sync status
kodo docs agent regenerate              # Regenerate from templates
kodo docs agent validate                # Verify all agents documented
```

### Notion Sync

```bash
kodo docs sync                          # Full sync to Notion
kodo docs sync --dry-run                # Preview changes
kodo docs sync --category architecture  # Sync specific category
kodo docs push                          # Push local changes to Notion
kodo docs pull                          # Pull Notion changes to local
```

### Documentation Management

```bash
kodo docs generate adr <topic>          # Generate ADR template
kodo docs generate wiki <topic>         # Generate wiki page
kodo docs validate                      # Check for broken links
kodo docs search "API design"           # Search Notion docs
```

## Integration with Kodo

**Before syncing:**
```bash
kodo query "architecture"               # Review local context
kodo learn list --category decisions    # Check recent ADRs
```

**After syncing:**
```bash
kodo reflect --signal "Synced architecture decisions to Notion"
kodo track link #123                    # Link related GitHub issue
```

**Design document workflow:**
```bash
# 1. Create design in docs/plans/
kodo extract docs/plans/2026-02-07-auth-redesign.md

# 2. Generate Notion pages
kodo docs generate adr "Authentication redesign"
kodo docs generate wiki "Auth System"

# 3. Sync to Notion
kodo docs sync --category architecture
```

## The Process

### Syncing Agent Documentation

When agent configurations change:

1. Update agent YAML files
2. Regenerate documentation: `kodo docs agent regenerate`
3. Review changes: `kodo docs agent status`
4. Sync to Notion: `kodo docs agent sync`
5. Validate: `kodo docs agent validate`

```bash
# After adding new agent
kodo docs agent regenerate --agent kodo-refactor
kodo docs agent sync
kodo reflect --signal "Added refactor agent documentation"
```

### Architecture Decision Records

After making architecture decisions:

1. Document decision in design doc
2. Extract learnings: `kodo extract <design-doc>`
3. Generate ADR: `kodo docs generate adr <topic>`
4. Review and enhance ADR content
5. Sync to Notion: `kodo docs sync --category decisions`

### Wiki Maintenance

For API docs, guides, and wikis:

1. Create markdown in `.kodo/context-tree/`
2. Curate content: `kodo curate add --category <category>`
3. Generate wiki page: `kodo docs generate wiki <topic>`
4. Sync to Notion: `kodo docs sync`
5. Validate links: `kodo docs validate`

## Routing Rules

**Auto-route to Notion:**
- Architecture Decision Records (ADRs)
- Design documents from `docs/plans/`
- API documentation
- Executive summaries
- Team wikis and guides

**Keep in GitHub:**
- Implementation plans
- Bug reports
- Feature specifications
- Sprint planning docs

Use `kodo flow route <content>` to auto-determine destination.

## Key Principles

- **Local first** - `.kodo/` is source of truth
- **Notion as presentation** - Team-facing documentation
- **Sync regularly** - Keep Notion up-to-date
- **Validate after changes** - Check for broken links
- **Extract before syncing** - Run `kodo extract` on design docs

## Red Flags

**You're doing it wrong if:**
- Editing Notion directly without syncing back
- Syncing without running `kodo extract` on design docs
- Creating duplicate wiki pages (didn't check with `kodo docs search`)
- Not validating agent docs after config changes
- Forgetting to capture sync operations in `kodo reflect`
