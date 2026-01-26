# CLI Reference

Complete command reference for the `kodo` CLI.

## Table of Contents

- [Global Options](#global-options)
- [Commands](#commands)
  - [kodo init](#kodo-init)
  - [kodo analyze](#kodo-analyze)
  - [kodo reflect](#kodo-reflect)
  - [kodo curate](#kodo-curate)
  - [kodo import](#kodo-import)
  - [kodo query](#kodo-query)
  - [kodo status](#kodo-status)
  - [kodo sync](#kodo-sync)
  - [kodo track](#kodo-track)
  - [kodo docs](#kodo-docs)
  - [kodo flow](#kodo-flow)
  - [kodo plugin](#kodo-plugin)
  - [kodo context](#kodo-context)
  - [kodo hooks](#kodo-hooks)
  - [kodo learn](#kodo-learn)
  - [kodo index](#kodo-index)
  - [kodo update](#kodo-update)
  - [kodo auth](#kodo-auth)
- [Configuration](#configuration)
  - [kodo.toml Reference](#kodotoml-reference)
  - [Environment Variables](#environment-variables)
  - [Credentials File](#credentials-file)
- [Exit Codes](#exit-codes)

---

## Global Options

These options are available for all commands:

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Enable verbose output (INFO level) |
| `--debug` | Enable debug output (DEBUG level) |
| `--trace` | Enable trace output (TRACE level, very verbose) |
| `--log-file <PATH>` | Custom log file path (default: `.kodo/logs/YYYY-MM-DD.log`) |
| `--no-log-file` | Disable file logging entirely |
| `-h, --help` | Print help |
| `-V, --version` | Print version |

---

## Commands

### `kodo init`

Initialize a new kodo project.

```bash
kodo init [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--hooks` | Generate hooks.json for lifecycle events |
| `--add-only` | Merge with existing setup, preserving user content. Only adds/updates kodo-managed sections |
| `--force` | Backup existing setup and overwrite. Creates timestamped backup in `.kodo.backup/` |
| `--no-agent-doc` | Skip agent documentation generation (AGENTS.md, CLAUDE.md, etc.) |
| `--agent <TOOLS>` | Specify AI coding assistant(s) to generate docs for (comma-separated). Values: claude-code, cursor, warp, copilot, windsurf, aider |

**Creates:**

- `kodo.toml` - Project configuration (in project root)
- `AGENTS.md` - Industry-standard AI agent instructions
- `.kodo/` directory containing:
  - `context-tree/` - Hierarchical knowledge storage
  - `learnings/` - Captured patterns by confidence level
  - `logs/` - Debug and trace logs
  - `routing.yaml.example` - Example routing rules
- Tool-specific agent documentation (based on selected agents):
  - `.claude/CLAUDE.md` - Claude Code instructions
  - `.cursor/rules/kodo.mdc` - Cursor rules
  - `.github/copilot-instructions.md` - GitHub Copilot instructions
  - `.windsurf/rules/kodo.md` - Windsurf/Codeium rules

**Examples:**

```bash
kodo init                                    # Interactive mode
kodo init --agent claude-code,cursor         # Specific agents
kodo init --no-agent-doc                     # Skip agent docs
kodo init --add-only                         # Preserve existing content
```

---

### `kodo analyze`

Analyze codebase and generate context entries automatically.

```bash
kodo analyze [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--auto` | Auto mode - automatically accept all suggestions |
| `--dry-run` | Show what would be imported without making changes |
| `--only <ANALYZERS>` | Only run specific analyzers (comma-separated) |
| `--skip <ANALYZERS>` | Skip specific analyzers (comma-separated) |
| `--json` | Output in JSON format for Claude Code CLI integration |

**Available Analyzers:**

- `tech-stack` - Detect languages, frameworks, dependencies
- `architecture` - Identify patterns (MVC, hexagonal, etc.)
- `database` - Scan schemas, migrations, models
- `api` - Find API endpoints and patterns
- `testing` - Analyze test structure and coverage
- `documentation` - Find and assess docs
- `devops` - CI/CD, Docker, deployment configs
- `dependencies` - Dependency analysis

**Examples:**

```bash
kodo analyze                          # Run all analyzers interactively
kodo analyze --auto                   # Auto-import all findings
kodo analyze --only tech-stack,api    # Run specific analyzers
kodo analyze --skip testing --auto    # Skip testing analyzer
kodo analyze --dry-run                # Preview without changes
```

---

### `kodo reflect`

Capture learnings from coding sessions.

```bash
kodo reflect [OPTIONS] [COMMAND]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `on` | Enable automatic reflection |
| `off` | Disable automatic reflection |

**Options:**

| Option | Description |
|--------|-------------|
| `--auto` | Enable automatic reflection |
| `--status` | Show learning statistics |
| `--history` | Show learning history |
| `--revert <HASH>` | Revert a specific learning by commit hash |
| `--hook <EVENT>` | Hook event that triggered this reflection (precompact, subagent, stop, task) |
| `--agent-id <ID>` | Agent ID for subagent-scoped learnings |
| `-q, --quiet` | Quiet mode - minimal output for background hooks |
| `--agent-assess` | Request agent self-assessment (outputs prompt for Claude) |
| `--parse-agent-response [YAML]` | Parse agent's YAML response |
| `--extract-agent-yaml` | Extract and parse agent YAML from transcript |
| `--check-threshold` | Check threshold only (for MessageBatch/TimeInterval hooks) |
| `--transcript <PATH>` | Path to transcript.jsonl file for hook-based reflection |
| `--session-id <ID>` | Session ID for transcript position tracking |

**Examples:**

```bash
kodo reflect                    # Interactive reflection
kodo reflect on                 # Enable auto-reflection
kodo reflect --status           # Show statistics
kodo reflect --history          # Show history
```

---

### `kodo curate`

Add or manage context entries manually.

```bash
kodo curate [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `-d, --domain <DOMAIN>` | Domain for the entry |
| `-t, --topic <TOPIC>` | Topic for the entry |
| `--subtopic <SUBTOPIC>` | Subtopic within the topic |
| `--title <TITLE>` | Entry title (auto-detected from # heading if not provided) |
| `--tags <TAGS>` | Tags (comma-separated) |
| `--confidence <LEVEL>` | Confidence level: high, medium, low |
| `-i, --interactive` | Interactive mode |
| `-l, --list` | List existing entries |
| `--from <FILE>` | Create entry from file (non-interactive) |

**Examples:**

```bash
kodo curate --domain auth --topic jwt "Always validate tokens server-side"
kodo curate --from ./docs/architecture.md --domain architecture
kodo curate --list
kodo curate --interactive
```

---

### `kodo import`

Import raw markdown files into the context tree.

```bash
kodo import [OPTIONS] <PATH>
```

**Arguments:**

| Argument | Description |
|----------|-------------|
| `<PATH>` | Source file or directory to import |

**Options:**

| Option | Description |
|--------|-------------|
| `-d, --domain <DOMAIN>` | Domain for the imported entry |
| `-t, --topic <TOPIC>` | Topic for the imported entry |
| `--subtopic <SUBTOPIC>` | Subtopic within the topic |
| `--title <TITLE>` | Override title (otherwise extracted from # heading) |
| `--tags <TAGS>` | Tags (comma-separated) |
| `--confidence <LEVEL>` | Confidence level: high, medium, low |
| `-r, --recursive` | Recursively import from directory |
| `--dry-run` | Show what would be imported |
| `--auto-detect` | Auto-detect domain from directory path |

**Examples:**

```bash
kodo import ./docs/api.md --domain api
kodo import ./docs/ --recursive --auto-detect
kodo import ./notes.md --domain notes --tags "review,draft"
```

---

### `kodo query`

Search accumulated context.

```bash
kodo query [OPTIONS] [QUERY]
```

**Arguments:**

| Argument | Description |
|----------|-------------|
| `[QUERY]` | Search query |

**Options:**

| Option | Description |
|--------|-------------|
| `-f, --format <FORMAT>` | Output format: json, markdown, plain (default: plain) |
| `-i, --interactive` | Interactive search mode |
| `--full` | Show full content |
| `-l, --limit <N>` | Maximum number of results (default: 10) |

**Examples:**

```bash
kodo query "authentication"
kodo query "error handling" --format json
kodo query --interactive
kodo query "api" --full --limit 5
```

---

### `kodo status`

Show project status and statistics.

```bash
kodo status [OPTIONS]
```

**Shows:**

- Context entry count by domain/topic
- Learning counts by confidence level
- Sync status
- Hook status

---

### `kodo sync`

Synchronize context with Git and cloud.

```bash
kodo sync [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `-p, --push` | Push to remote after commit |
| `--cloud-only` | Only sync to cloud (skip Git) |
| `--git-only` | Only sync to Git (skip cloud) |
| `--force` | Force full sync (ignore hash cache) |
| `--migrate` | Migrate: merge nested .kodo folders into project root |

**Examples:**

```bash
kodo sync                  # Sync to both Git and cloud
kodo sync --push           # Sync and push to remote
kodo sync --git-only       # Only sync to Git
kodo sync --cloud-only     # Only sync to cloud
```

---

### `kodo track`

Track items in GitHub Projects.

```bash
kodo track <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `issue` | Create a new issue |
| `link` | Link current work to an existing issue |
| `status` | Update issue status |
| `list` | List issues |
| `board` | Show project board |
| `sync` | Sync local state with GitHub |

**Examples:**

```bash
kodo track issue "Fix authentication bug" --label bug
kodo track link 123
kodo track status 123 --done
kodo track list --open
kodo track board
```

---

### `kodo docs`

Manage documentation - both AI agent documentation and Notion documentation.

```bash
kodo docs <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `agent` | Manage AI agent documentation files |
| `create` | Create a new documentation page in Notion |
| `adr` | Create an Architecture Decision Record |
| `update` | Update existing documentation |
| `wiki` | Sync wiki from local .kodo/ context |
| `summary` | Generate executive summary from learnings |
| `search` | Search documentation |

#### `kodo docs agent`

Manage AI coding assistant documentation files (AGENTS.md, CLAUDE.md, etc.).

```bash
kodo docs agent <ACTION>
```

**Actions:**

| Action | Description |
|--------|-------------|
| `status` | Show status of all agent documentation files |
| `sync` | Synchronize all agent doc files from AGENTS.md |
| `regenerate` | Regenerate docs from kodo.toml |
| `regenerate --force` | Force regeneration even if files exist |

**Files Managed:**

| File | Agent | Purpose |
|------|-------|---------|
| `AGENTS.md` | All | Industry standard (source of truth) |
| `.claude/CLAUDE.md` | Claude Code | Claude-specific instructions |
| `.cursor/rules/kodo.mdc` | Cursor | Cursor rules (MDC format) |
| `.github/copilot-instructions.md` | GitHub Copilot | Copilot instructions |
| `.windsurf/rules/kodo.md` | Windsurf | Windsurf/Codeium rules |

**Examples:**

```bash
kodo docs agent status              # Show status of agent doc files
kodo docs agent sync                # Sync all files from AGENTS.md
kodo docs agent regenerate          # Regenerate from kodo.toml
kodo docs agent regenerate --force  # Force regenerate
```

#### Notion Documentation

**Examples:**

```bash
kodo docs create "API Design" --type wiki
kodo docs adr "Use PostgreSQL for persistence"
kodo docs wiki --sync
kodo docs summary --last-week
```

---

### `kodo flow`

Intelligent content routing.

```bash
kodo flow [OPTIONS] [CONTENT]
```

**Arguments:**

| Argument | Description |
|----------|-------------|
| `[CONTENT]` | Content to analyze and route |

**Options:**

| Option | Description |
|--------|-------------|
| `--dry-run` | Show routing decision without taking action |

Routes content to the appropriate destination:
- **GitHub**: Bugs, features, tasks, PRs
- **Notion**: Architecture docs, ADRs, wikis
- **Local (.kodo/)**: Learned patterns, code preferences

---

### `kodo plugin`

Manage domain plugins.

```bash
kodo plugin <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `add` | Install a plugin |
| `list` | List installed and available plugins |
| `remove` | Remove an installed plugin |

**Examples:**

```bash
kodo plugin list                    # List installed plugins
kodo plugin list --available        # List available plugins
kodo plugin add design              # Install kodo-design plugin
kodo plugin remove supabase         # Remove a plugin
```

---

### `kodo context`

Context management for session hooks.

```bash
kodo context <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `load` | Load context at session start |
| `generate` | Generate .kodo/context.md with relevant learnings |

---

### `kodo hooks`

Manage Claude Code hooks for automatic reflection.

```bash
kodo hooks <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `install` | Install Claude Code hooks for automatic reflection |
| `uninstall` | Uninstall Claude Code hooks |
| `status` | Check hook installation status |

**Examples:**

```bash
kodo hooks install
kodo hooks status
kodo hooks uninstall
```

---

### `kodo learn`

Manage learnings (review, promote, demote).

```bash
kodo learn <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `review` | Review pending learnings interactively |
| `promote` | Promote a learning to higher confidence |
| `demote` | Demote a learning to lower confidence |
| `list` | List all learnings |

**Examples:**

```bash
kodo learn list                     # List all learnings
kodo learn list --pending           # List pending review
kodo learn review                   # Interactive review
kodo learn promote abc123           # Promote by ID
```

---

### `kodo index`

Manage relevance index for context generation.

```bash
kodo index <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `rebuild` | Rebuild the relevance index from learnings |
| `status` | Show index status and statistics |
| `embeddings` | Configure embedding providers (Pro feature) |

**Examples:**

```bash
kodo index rebuild
kodo index status
```

---

### `kodo update`

Manage kodo updates.

```bash
kodo update <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `check` | Check for available updates |
| `apply` | Apply pending update now |
| `config` | Configure update settings |

**Examples:**

```bash
kodo update check
kodo update apply
kodo update config --channel beta
```

---

### `kodo auth`

Manage authentication for integrations.

```bash
kodo auth <COMMAND>
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `status` | Show authentication status for all integrations |
| `verify` | Verify credentials by testing API connections |
| `setup` | Show setup instructions for credentials |

#### `kodo auth status`

Show which credentials are configured:

```bash
kodo auth status
```

**Output:**

```
Authentication Status

GitHub:
  ✓ GITHUB_TOKEN: configured
  ✓ GITHUB_OWNER: configured
  ○ GITHUB_REPO: not set (optional)

Notion:
  ✗ NOTION_API_KEY: not configured
  ○ NOTION_DATABASE_ID: not set (optional)

Anthropic:
  ✓ ANTHROPIC_API_KEY: configured

OpenAI:
  ○ OPENAI_API_KEY: not set (optional)

Tip: Add missing credentials to .env or .kodo/.env
   See: kodo auth setup
```

#### `kodo auth verify`

Test credentials by making API calls:

```bash
kodo auth verify
```

**Output:**

```
Verifying credentials...

GitHub:
  → Testing API access... ✓ authenticated as @username

Notion:
  ○ credentials not configured - skipped

Anthropic:
  → Testing API access... ✓ API key valid

OpenAI:
  → Testing API access... ✓ API key valid
```

#### `kodo auth setup`

Show setup instructions for credentials:

```bash
kodo auth setup
```

Displays:
- Required environment variables for each integration
- Links to obtain API tokens
- Instructions for finding Notion database IDs from URLs

---

## Configuration

### kodo.toml Reference

The `kodo.toml` file is created in your project root by `kodo init`. Here's the complete reference:

```toml
# OpenKodo Configuration
# 古道 - Your code path, remembered

[project]
name = "my-project"       # Project name (used in cloud sync)
description = "A brief description of your project"
version = "0.1.0"         # Project version

[tech_stack]
languages = ["rust", "typescript"]
frameworks = ["axum", "react"]
package_managers = ["cargo", "pnpm"]
test_frameworks = ["cargo-test", "vitest"]
deployment = "docker"     # local, docker, aws, gcp, azure, vercel, etc.

[code_style]
indent = "spaces"         # "spaces" or "tabs"
indent_size = 4           # 2, 4, etc.
quotes = "double"         # "single" or "double" (for JS/TS)
semicolons = true         # For JS/TS
line_length = 100         # 80, 100, 120, etc.

[agents]
primary = "claude-code"   # Primary AI coding assistant
enabled = ["claude-code", "cursor"]  # All enabled agents

[learning]
auto_reflect = true       # Enable automatic reflection
confidence_threshold = "medium"  # Minimum confidence for auto-apply: high, medium, low

[sync]
remote = "origin"         # Git remote name
branch = "main"           # Git branch for sync

[integrations]
github = false            # Enable GitHub integration
notion = false            # Enable Notion integration

[cloud]
api_url = "https://app.openkodo.com/api/cli"  # Cloud API URL (can be overridden)
sync_scope = "all"        # What to sync: all, context, learnings
exclude = [".env", "*.tmp"]  # Patterns to exclude from cloud sync
```

**Supported Agents:**

| Agent ID | Tool |
|----------|------|
| `claude-code` | Claude Code (Anthropic) |
| `cursor` | Cursor |
| `warp` | Warp |
| `copilot` | GitHub Copilot |
| `windsurf` | Windsurf/Codeium |
| `aider` | Aider |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude (agent assessment) | - |
| `OPENAI_API_KEY` | OpenAI API key (for embeddings) | - |
| `GITHUB_TOKEN` | GitHub personal access token | - |
| `GITHUB_OWNER` | GitHub owner (org or username) | - |
| `GITHUB_REPO` | GitHub default repository | - |
| `NOTION_API_KEY` | Notion API key | - |
| `NOTION_DATABASE_ID` | Notion default database ID | - |
| `KODO_CLOUD_TOKEN` | Cloud sync authentication token | - |
| `KODO_CLOUD_API_URL` | Override cloud API URL | `https://app.openkodo.com/api/cli` |
| `KODO_MESSAGE_BATCH_THRESHOLD` | Message count before auto-reflect | `10` |
| `KODO_INTERVAL_MINUTES` | Minutes between time-based reflections | `15` |
| `KODO_ENABLE_EMBEDDINGS` | Enable embedding-based similarity | `false` |

### Credentials Setup

Credentials are stored in `.env` files. Create a `.env` file in your project root or `.kodo/.env`:

```bash
# .env or .kodo/.env
# NEVER commit this file to git!

# GitHub Integration (for kodo track)
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GITHUB_OWNER=your-org-or-username
GITHUB_REPO=your-repo  # optional

# Notion Integration (for kodo docs)
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# To find database ID from URL: https://www.notion.so/2f48f7779a358...?v=...
#                                         ^^^^^^^^^^^^^^^^^^^^^^^^
NOTION_DATABASE_ID=2f48f7779a3580228070f4e903621655

# Anthropic API (for kodo reflect --assess)
ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# OpenAI API (optional, for embeddings)
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Check and verify your credentials:

```bash
kodo auth status   # Show which credentials are configured
kodo auth verify   # Test credentials by calling APIs
kodo auth setup    # Show detailed setup instructions
```

**Configuration Precedence (highest to lowest):**
1. Project `.env` (`.kodo/.env` takes precedence over `./.env`)
2. Environment variables
3. Defaults

> **Note:** The `credentials.toml` file is deprecated. If you have an existing `~/.config/kodo/credentials.toml`, migrate your credentials to `.env` files and delete the old file.

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Configuration error |
| 4 | Not initialized (run `kodo init`) |
