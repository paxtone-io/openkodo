# Getting Started with OpenKodo

OpenKodo (古道 - "Ancient Path") is a context management CLI and self-learning system for AI coding tools. It captures patterns from your coding sessions, organizes project knowledge, and ensures every AI assistant you use has the right context.

**Tagline**: *Kodo it. Ship it. Remember it.*

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Core Workflows](#core-workflows)
  - [Standalone CLI](#standalone-cli-workflows)
  - [Claude Code Integration](#claude-code-integration)
- [Recommended User Flows](#recommended-user-flows)
- [Next Steps](#next-steps)

---

## Installation

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.ps1 | iex
```

### Manual Download

Download the appropriate binary from [Releases](https://github.com/paxtone-io/openkodo/releases):

| Platform | File |
|----------|------|
| macOS Intel | `kodo-v*-x86_64-apple-darwin.tar.gz` |
| macOS Apple Silicon | `kodo-v*-aarch64-apple-darwin.tar.gz` |
| Linux x64 | `kodo-v*-x86_64-unknown-linux-gnu.tar.gz` |
| Linux ARM64 | `kodo-v*-aarch64-unknown-linux-gnu.tar.gz` |
| Windows x64 | `kodo-v*-x86_64-pc-windows-msvc.zip` |
| Windows ARM64 | `kodo-v*-aarch64-pc-windows-msvc.zip` |

### Verify Installation

```bash
kodo --version
# kodo 0.1.8
```

---

## Quick Start

### 1. Initialize a Project

```bash
cd your-project
kodo init
```

The interactive wizard asks about your project and generates:

- `kodo.toml` - Project configuration
- `AGENTS.md` - Industry-standard AI agent instructions (source of truth)
- `.kodo/` directory with context tree, learnings, and logs
- Agent-specific documentation files based on your selection

You can also specify agents directly:

```bash
kodo init --agent claude-code,cursor,copilot
```

### 2. Analyze Your Codebase

Automatically detect your project's tech stack, architecture, and patterns:

```bash
kodo analyze
```

This runs 8 specialized analyzers (tech-stack, architecture, database, API, testing, documentation, devops, dependencies) and generates context entries.

For deeper analysis that extracts learnings from documentation:

```bash
kodo analyze --deep
```

### 3. Enable Auto-Reflection

```bash
kodo reflect on
```

This captures patterns and insights from your coding sessions automatically.

### 4. Install Claude Code Hooks (Optional)

If you use Claude Code, install lifecycle hooks for automatic context loading and learning capture:

```bash
kodo hooks install
```

### 5. Set Up Integrations (Optional)

Create a `.env` file for GitHub and Notion integrations:

```bash
# Create .env in project root or .kodo/.env
cp .env.example .env
# Edit with your API credentials
```

Check and verify credentials:

```bash
kodo auth status    # Show what's configured
kodo auth verify    # Test API connections
kodo auth setup     # Show setup instructions
```

---

## Project Structure

After initialization, your project will have:

```
your-project/
├── kodo.toml                  # Project configuration
├── AGENTS.md                  # AI agent instructions (source of truth)
├── .claude/                   # Claude Code specific (if selected)
│   └── CLAUDE.md              # Claude-specific instructions
├── .cursor/                   # Cursor specific (if selected)
│   └── rules/kodo.mdc         # Cursor rules
├── .github/                   # Copilot specific (if selected)
│   └── copilot-instructions.md
├── .windsurf/                 # Windsurf specific (if selected)
│   └── rules/kodo.md
├── .kodo/
│   ├── context-tree/          # Organized knowledge
│   │   ├── architecture/
│   │   ├── database/
│   │   ├── api/
│   │   └── ...
│   ├── learnings/             # Captured patterns
│   │   ├── rules.md           # Explicit rules (HIGH confidence)
│   │   ├── decisions.md       # Architecture decisions
│   │   ├── tech-stack.md      # Technology choices
│   │   ├── workflows.md       # Process sequences
│   │   ├── domain.md          # Business terms
│   │   └── conventions.md     # Code style patterns
│   └── logs/                  # Debug logs
└── ... (your project files)
```

### Supported AI Agents

| Agent | Config ID | File Generated |
|-------|-----------|----------------|
| Claude Code | `claude-code` | `.claude/CLAUDE.md` |
| Cursor | `cursor` | `.cursor/rules/kodo.mdc` |
| GitHub Copilot | `copilot` | `.github/copilot-instructions.md` |
| Windsurf | `windsurf` | `.windsurf/rules/kodo.md` |
| Warp | `warp` | Uses `AGENTS.md` directly |
| Aider | `aider` | Uses `AGENTS.md` directly |
| OpenAI Codex | `codex` | Uses `AGENTS.md` directly |

---

## Core Workflows

### Standalone CLI Workflows

#### Capture Context

Add important knowledge about your codebase:

```bash
# Add a context entry
kodo curate --domain auth --topic jwt "Always validate tokens server-side"

# Import from a file
kodo curate --from ./docs/architecture.md --domain architecture

# Import entire directory recursively
kodo import ./docs/ --recursive --auto-detect

# Interactive mode
kodo curate --interactive
```

#### Search Context

Find relevant information fast:

```bash
kodo query "authentication"
kodo query "error handling" --format json --full
kodo query --interactive
```

#### Review & Manage Learnings

```bash
kodo reflect --status           # Show learning statistics
kodo learn list                 # List all learnings
kodo learn review               # Interactive review of pending items
kodo learn promote <id>         # Promote to higher confidence
```

#### Sync Context

```bash
kodo sync                       # Sync to Git
kodo sync --push                # Sync and push to remote
kodo sync --cloud-only          # Sync to cloud (requires token)
```

#### Track Work (GitHub Integration)

```bash
kodo track issue "Fix auth bug" --label bug
kodo track list --open
kodo track board
```

#### Manage Documentation (Notion Integration)

```bash
kodo docs create "API Design" --type wiki
kodo docs adr "Use PostgreSQL"
kodo docs wiki --sync
```

#### Keep Agent Docs in Sync

```bash
kodo docs agent status          # Check all agent doc files
kodo docs agent sync            # Propagate changes from AGENTS.md
kodo docs agent regenerate      # Regenerate from kodo.toml
```

---

### Claude Code Integration

OpenKodo provides a rich plugin ecosystem for Claude Code with slash commands, specialized agents, and lifecycle hooks.

#### Install Plugins

In Claude Code, type `/plugin` and add the marketplace `paxtone-io/openkodo`. Or install specific plugins via CLI:

```bash
kodo plugin add design          # UI/UX design workflows
kodo plugin add supabase        # Supabase integration
kodo plugin add posthog         # PostHog analytics
kodo plugin add analyzer        # Advanced codebase analysis
```

#### Available Slash Commands

All kodo slash commands use the `/kodo-{name}` format in Claude Code.

**Core Plugin (`kodo`)**:

| Command | Description |
|---------|-------------|
| `/kodo-brainstorm` | Turn ideas into designs through collaborative questioning |
| `/kodo-plan` | Create implementation plans with TDD approach |
| `/kodo-execute` | Execute plans with checkpoints |
| `/kodo-review` | Code review with confidence-based filtering |
| `/kodo-debug` | Systematic debugging workflow |
| `/kodo-test` | Intelligent test runner - find affected tests, run coverage |
| `/kodo-refactor` | Guided safe refactoring with test verification |
| `/kodo-explore` | Deep codebase exploration and pattern discovery |
| `/kodo-curate` | Add and manage context entries |
| `/kodo-query` | Search accumulated context and learnings |
| `/kodo-sync` | Synchronize learnings via Git or cloud |
| `/kodo-track` | Track work in GitHub Projects |
| `/kodo-docs` | Manage Notion documentation |
| `/kodo-flow` | Route content to GitHub, Notion, or local |
| `/kodo-pr-context` | Summarize session learnings for PR descriptions |
| `/kodo-release-check` | Validate pre-release checklist |

**Design Plugin (`kodo-design`)**:

| Command | Description |
|---------|-------------|
| `/kodo-design` | Design a UI component with Design Bible principles |
| `/kodo-design-system` | Create/update project design foundation |
| `/kodo-design-audit` | Audit existing UI for consistency and a11y |
| `/kodo-design-theme` | Audit color theme for WCAG 2.2 AA/AAA |
| `/kodo-design-inspire` | Research design inspiration |

**Analyzer Plugin (`kodo-analyzer`)**:

| Command | Description |
|---------|-------------|
| `/kodo-analyze` | Comprehensive codebase analysis and health scoring |
| `/kodo-deep-analyze` | Deep analysis: extract content and learnings from docs |

**PostHog Plugin (`kodo-posthog`)**:

| Command | Description |
|---------|-------------|
| `/kodo-posthog` | PostHog analytics, feature flags, A/B experiments |
| `/kodo-ph-event` | Track custom events |
| `/kodo-ph-flag` | Manage feature flags |
| `/kodo-ph-experiment` | Create and analyze experiments |
| `/kodo-ph-dashboard` | Manage dashboards |
| `/kodo-ph-sync` | Sync PostHog config with Notion |

**Supabase Plugin (`kodo-supabase`)**:

| Command | Description |
|---------|-------------|
| `/kodo-supabase` | Architecture decision guide for Supabase apps |
| `/kodo-supa-db` | Database operations with ORM detection |
| `/kodo-supa-decide` | Architecture recommendations |
| `/kodo-supa-deploy` | Deploy Edge Functions and DB changes |
| `/kodo-supa-edge` | Manage Edge Functions |
| `/kodo-supa-migrate` | Database migrations with hybrid ORM |
| `/kodo-supa-schema` | Schema management |
| `/kodo-supa-status` | Check Supabase project health |

#### Lifecycle Hooks

When you install kodo hooks (`kodo hooks install`), these fire automatically:

| Event | What Happens |
|-------|-------------|
| **SessionStart** | Loads recent context and active learnings |
| **PreCompact** | Captures learnings before context compaction |
| **Stop** | Captures learnings when Claude stops responding |
| **SessionEnd** | Reminds you to run `kodo reflect` |

Additional safety hooks (installed via `.claude/settings.json`):

| Hook | Purpose |
|------|---------|
| **PostToolUse** (Edit/Write) | Auto-runs `cargo fmt` (Rust projects) |
| **PreToolUse** (Edit/Write) | Blocks direct `.env` file edits |
| **PreToolUse** (Bash) | Blocks force-push to main/master |

---

## Recommended User Flows

### Flow 1: New Project Setup

```bash
# 1. Initialize kodo in your project
kodo init

# 2. Auto-analyze the codebase
kodo analyze --auto

# 3. Deep-analyze any existing docs
kodo analyze --deep

# 4. Enable auto-reflection
kodo reflect on

# 5. Install Claude Code hooks (if using Claude)
kodo hooks install

# 6. Verify everything
kodo status
```

### Flow 2: Daily Development (Standalone CLI)

```bash
# Start of session: check status
kodo status

# During work: search for context
kodo query "how does auth work"

# Add new knowledge as you learn
kodo curate --domain api --topic auth "JWT tokens expire after 24h"

# End of session: capture learnings
kodo reflect

# Push context to Git
kodo sync --push
```

### Flow 3: Daily Development (Claude Code)

```
# Session starts automatically - hooks load context

# Brainstorm a feature
/kodo-brainstorm

# Create an implementation plan
/kodo-plan

# Execute the plan with checkpoints
/kodo-execute

# Run tests to verify
/kodo-test

# Review the code before committing
/kodo-review

# Generate PR context from session
/kodo-pr-context

# Session ends - hooks auto-capture learnings
```

### Flow 4: Code Review & Release

```
# Review code with confidence filtering
/kodo-review

# Check release readiness
/kodo-release-check

# Verify all tests pass
/kodo-test

# Generate PR description with context
/kodo-pr-context
```

### Flow 5: Debugging

```
# Systematic debugging
/kodo-debug

# Search existing context for similar issues
/kodo-query "error message or symptom"

# Explore codebase for related code
/kodo-explore
```

### Flow 6: Agent Documentation Management

When you update your project's tech stack, architecture, or conventions:

```bash
# 1. Edit AGENTS.md (the source of truth)
# 2. Sync changes to all agent-specific files
kodo docs agent sync

# Or regenerate everything from kodo.toml
kodo docs agent regenerate --force
```

---

## Next Steps

1. **Explore all CLI commands**: See [CLI Reference](CLI-REFERENCE.md)
2. **Claude Code integration details**: See [Claude Code Integration](CLAUDE-CODE-INTEGRATION.md)
3. **Build your own plugins**: See [Plugin Development](PLUGIN-DEVELOPMENT.md)
4. **Install domain plugins**: `kodo plugin list --available`
5. **Configure integrations**: Set up GitHub and Notion in `kodo.toml`
6. **Join the community**: Report issues at [GitHub](https://github.com/paxtone-io/openkodo/issues)

### Quick Reference

```bash
kodo status                     # Project overview
kodo --help                     # All commands
kodo <command> --help           # Command-specific help
kodo update check               # Check for updates
kodo update apply               # Apply update
```
