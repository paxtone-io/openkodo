---
name: sync
description: >
  Synchronize learnings and context via Git or cloud.
  Use to share knowledge across team and keep workstations in sync.
---

# Synchronizing Context and Learnings

## Overview

Keep `.kodo/` directory synchronized across team members and workstations.
Push learnings to Git, pull team updates, and optionally sync to cloud storage.
Ensures team consistency and shared institutional memory.

**Core principle:** Knowledge is shared. Everyone benefits from accumulated learnings.

**Announce at start:** "I'm using the sync skill to synchronize context."

## When to Use

- After completing significant work (push learnings)
- At session start (pull team updates)
- Before major decisions (ensure latest context)
- After curating important patterns
- When switching workstations
- Setting up new team members

## CLI Commands

### Basic Sync

```bash
kodo sync                               # Full sync (pull then push)
kodo sync --pull                        # Pull only (get team updates)
kodo sync --push                        # Push only (share your learnings)
```

### Git Sync

```bash
kodo sync --git-only                    # Git sync only (no cloud)
kodo sync --branch feature/auth         # Sync specific branch
kodo sync --force                       # Force push (use carefully)
```

### Cloud Sync

```bash
kodo sync --cloud                       # Sync to configured cloud
kodo sync --cloud s3                    # Specific cloud provider
kodo sync --cloud-only                  # Skip Git sync
```

### Conflict Resolution

```bash
kodo sync --strategy merge              # Merge conflicts (default)
kodo sync --strategy theirs             # Take remote version
kodo sync --strategy ours               # Keep local version
kodo sync --resolve                     # Interactive conflict resolution
```

## Integration with Kodo

**Typical workflow:**

```bash
# Start of session
kodo sync --pull                        # Get team updates
kodo query --recent                     # Check what changed

# During work
kodo reflect --signal "New pattern"
kodo curate add --category architecture

# End of session
kodo reflect                            # Capture session learnings
kodo sync                               # Share with team
```

**After significant work:**

```bash
# Major feature completed
git commit -m "feat: add authentication"
kodo reflect                            # Capture learnings
kodo curate add --category architecture --title "Auth pattern"
kodo sync --push                        # Share learnings
```

## The Process

### Daily Workflow

**Morning (start of session):**
```bash
kodo sync --pull                        # Get overnight updates
kodo query --recent                     # Review recent changes
kodo learn list --recent                # Check team learnings
```

**Evening (end of session):**
```bash
kodo reflect                            # Capture today's learnings
kodo sync                               # Push to team
```

### Collaboration Workflow

**Before making decision:**
```bash
kodo sync --pull                        # Ensure latest context
kodo query "decision topic"             # Check existing decisions
# Make decision
kodo curate add --category decisions
kodo sync --push                        # Share immediately
```

**After discovering pattern:**
```bash
kodo curate add --category <category>
kodo sync --push                        # Share with team
kodo docs sync                          # Update Notion if needed
```

### Conflict Resolution

When conflicts occur:

1. **Review conflict:**
   ```bash
   kodo sync --status                   # Show conflicts
   ```

2. **Choose strategy:**
   ```bash
   kodo sync --strategy merge           # Merge both versions
   kodo sync --strategy theirs          # Use team version
   kodo sync --strategy ours            # Use your version
   ```

3. **Interactive resolution:**
   ```bash
   kodo sync --resolve                  # Step through conflicts
   ```

4. **Validate:**
   ```bash
   kodo query "conflicted topic"        # Verify resolution
   kodo sync --push                     # Share resolution
   ```

## Sync Strategies

### Git Sync (Default)

Commits `.kodo/` directory to Git:
- Learnings in `.kodo/learnings/`
- Context in `.kodo/context-tree/`
- Config in `.kodo/config.json`

**Advantages:**
- Version controlled
- Auditable history
- Built-in conflict resolution
- No external dependencies

**Use when:**
- Team uses Git already
- Want version history
- Need audit trail

### Cloud Sync (Optional)

Syncs to cloud storage (S3, GCS, Azure Blob):
- Faster for large teams
- Cross-repository sync
- Centralized knowledge base

**Advantages:**
- Single source of truth
- Cross-project patterns
- Faster sync for large teams

**Use when:**
- Multiple repositories share patterns
- Need centralized knowledge base
- Large distributed team

### Hybrid Approach

```bash
kodo sync --git-only                    # Local repo sync
kodo sync --cloud                       # Cross-repo patterns
```

Use Git for repo-specific context, cloud for organization-wide patterns.

## Configuration

**Set sync preferences:**

```bash
kodo sync config                        # View current config
kodo sync config --strategy merge       # Set default strategy
kodo sync config --auto-sync true       # Enable auto-sync
kodo sync config --cloud s3             # Configure cloud provider
```

**Auto-sync configuration:**

```yaml
# .kodo/config.json
{
  "sync": {
    "auto": true,
    "strategy": "merge",
    "on_reflect": true,
    "on_curate": true,
    "cloud": {
      "enabled": true,
      "provider": "s3",
      "bucket": "team-kodo-context"
    }
  }
}
```

## Key Principles

- **Sync regularly** - Pull at session start, push at session end
- **Share immediately** - Push after important discoveries
- **Pull before decisions** - Ensure latest team context
- **Resolve conflicts quickly** - Don't let them accumulate
- **Validate after sync** - Query to verify sync worked

## Red Flags

**You're doing it wrong if:**
- Going days without syncing
- Using `--force` regularly (indicates conflicts)
- Not pulling before making architecture decisions
- Syncing without running `kodo reflect` first
- Ignoring sync conflicts
- Not validating sync with `kodo query` after pulling
