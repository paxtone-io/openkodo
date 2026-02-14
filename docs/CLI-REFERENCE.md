# CLI Reference

Complete command reference for the `kodo` CLI v0.2.4.

## Table of Contents

- [Global Options](#global-options)
- [Commands](#commands)
  - [kodo init](#kodo-init)
  - [kodo analyze](#kodo-analyze)
  - [kodo extract](#kodo-extract)
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
  - [kodo migrate](#kodo-migrate)
  - [kodo ports](#kodo-ports)
  - [kodo auth](#kodo-auth)
  - [kodo mcp](#kodo-mcp)
  - [kodo observe](#kodo-observe)
- [Configuration](#configuration)
  - [kodo.toml Reference](#kodotoml-reference)
  - [Environment Variables](#environment-variables)
  - [Credentials Setup](#credentials-setup)
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
| `--agent <TOOLS>` | Specify AI coding assistant(s) to generate docs for (comma-separated) |

**Supported Agent Values:** `claude-code`, `cursor`, `warp`, `copilot`, `windsurf`, `aider`, `codex`

**Creates:**

- `kodo.toml` - Project configuration with `kodo_version` tracking (in project root)
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
kodo init --agent claude-code,copilot,codex  # Multiple agents
kodo init --no-agent-doc                     # Skip agent docs
kodo init --add-only                         # Preserve existing content
kodo init --force                            # Backup and overwrite
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
| `--json` | Output in JSON format for scripting |
| `--deep` | Deep analysis - extract full content and learnings from documentation |

**Available Analyzers:**

| Analyzer | Description |
|----------|-------------|
| `tech-stack` | Detect languages, frameworks, dependencies |
| `architecture` | Identify patterns (MVC, hexagonal, clean, etc.) |
| `database` | Scan schemas, migrations, models, ORMs |
| `api` | Find API endpoints and patterns (REST, GraphQL, gRPC) |
| `testing` | Analyze test structure and coverage |
| `documentation` | Find and assess documentation quality |
| `devops` | CI/CD, Docker, deployment configs |
| `dependencies` | Dependency analysis, outdated packages |

**Examples:**

```bash
kodo analyze                          # Run all analyzers interactively
kodo analyze --auto                   # Auto-import all findings
kodo analyze --only tech-stack,api    # Run specific analyzers
kodo analyze --skip testing --auto    # Skip testing analyzer
kodo analyze --dry-run                # Preview without changes
kodo analyze --deep                   # Deep analysis with learning extraction
kodo analyze --deep --auto            # Deep analysis, auto-accept all
```

---

### `kodo extract`

Extract learnings from a single file. Alias: `x`.

```bash
kodo extract <FILE>
```

**Arguments:**

| Argument | Description |
|----------|-------------|
| `<FILE>` | Path to file to extract learnings from |

Learnings are stored in `.kodo/learnings/` grouped by category:
- `rules.md` - Explicit rules (always/never/must patterns)
- `decisions.md` - Architecture decisions
- `tech-stack.md` - Technology choices
- `workflows.md` - Process sequences
- `domain.md` - Business terms and entities
- `conventions.md` - Code style and naming patterns

**Examples:**

```bash
kodo extract ./docs/architecture.md
kodo x ./CONTRIBUTING.md              # Short alias
```

---

### `kodo reflect`

Capture learnings from coding sessions. Alias: `r`.

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
kodo reflect off                # Disable auto-reflection
kodo reflect --status           # Show statistics
kodo reflect --history          # Show history
kodo r                          # Short alias
```

---

### `kodo curate`

Add or manage context entries manually. Alias: `c`.

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
kodo c -d api -t rest "Use pagination for all list endpoints"
```

---

### `kodo import`

Import raw markdown files into the context tree. Alias: `i`.

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
kodo i ./CONTRIBUTING.md -d conventions
```

---

### `kodo query`

Search accumulated context. Alias: `q`.

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
| `-d, --detail <LEVEL>` | Detail level: `compact` (~50 tokens/result), `timeline` (~200 tokens, default), `full` (complete) |
| `--id <PATH>` | Lookup a specific entry by ID or path |
| `-f, --format <FORMAT>` | Output format: json, markdown, plain (default: plain) |
| `-i, --interactive` | Interactive search mode |
| `--full` | Show full content (overrides `--detail` to `full`) |
| `-l, --limit <N>` | Maximum number of results (default: 10) |

**Detail Levels:**

| Level | Aliases | Tokens/Result | Shows |
|-------|---------|---------------|-------|
| `compact` | `c`, `1` | ~50 | Title, domain, score |
| `timeline` | `t`, `2` | ~200 | + tags, match reasons, 100-char preview |
| `full` | `f`, `3` | Unlimited | Complete entry with all metadata |

**Examples:**

```bash
kodo query "authentication"                          # Default: timeline detail
kodo query "authentication" --detail compact          # Minimal output
kodo query "authentication" -d full                   # Complete entries
kodo query --id architecture/api/rest-conventions     # Direct entry lookup
kodo query "error handling" --format json
kodo query --interactive
kodo query "api" --full --limit 5
kodo q "database migrations"
```

---

### `kodo status`

Show project status and statistics.

```bash
kodo status [OPTIONS]
```

**Displays:**

- Context entry count by domain/topic
- Learning counts by confidence level
- Sync status
- Hook status
- Plugin status

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

Track items in GitHub Projects. Alias: `t`.

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
kodo track issue "Add dark mode" --feature
kodo track link 123
kodo track status 123 --done
kodo track list --open
kodo track board
kodo t issue "Quick bug fix" --bug
```

---

### `kodo docs`

Manage documentation - both AI agent documentation and Notion documentation. Alias: `d`.

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

```bash
kodo docs create "API Design" --type wiki
kodo docs adr "Use PostgreSQL for persistence"
kodo docs wiki --sync
kodo docs summary --last-week
kodo docs search "authentication"
```

---

### `kodo flow`

Intelligent content routing. Alias: `f`.

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
- **GitHub**: Bugs, features, tasks, PRs, sprint planning
- **Notion**: Architecture docs, ADRs, wikis, executive summaries
- **Local (.kodo/)**: Learned patterns, code preferences, conventions

---

### `kodo plugin`

Manage domain plugins. Alias: `p`.

```bash
kodo plugin <COMMAND> [OPTIONS]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `add` | Install a plugin |
| `list` | List installed and available plugins |
| `remove` | Remove an installed plugin |

**Available Plugins:**

| Plugin | Description |
|--------|-------------|
| `kodo` | Core workflows (brainstorm, plan, execute, review, debug) |
| `kodo-design` | UI/UX design with Design Bible principles |
| `kodo-analyzer` | Comprehensive codebase analysis and health scoring |
| `kodo-posthog` | PostHog analytics, feature flags, experiments |
| `kodo-supabase` | Supabase integration for databases, auth, Edge Functions |

**Examples:**

```bash
kodo plugin list                    # List installed plugins
kodo plugin list --available        # List available plugins
kodo plugin add design              # Install kodo-design plugin
kodo plugin add analyzer            # Install kodo-analyzer plugin
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

**Options (generate):**

| Option | Description |
|--------|-------------|
| `--session-id <ID>` | Session ID |
| `--prompt <TEXT>` | Current prompt for relevance matching |
| `--files <PATHS>` | Active files for relevance matching |
| `--max-learnings <N>` | Max learnings to include |
| `--min-score <SCORE>` | Minimum relevance score |
| `--quiet` | Minimal output |

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

**Options (install):**

| Option | Description |
|--------|-------------|
| `--global` | Install hooks globally |
| `--force` | Overwrite existing hooks |

**Installed Hooks:**

| Event | Script | Description |
|-------|--------|-------------|
| **SessionStart** | `kodo-session-start.sh` | Load context and active learnings |
| **UserPromptSubmit** | `kodo-message-count.sh` | Track message count for auto-reflection |
| **PostToolUse** | `kodo-observe.sh` | Auto-capture observations from tool outputs |
| **PreCompact** | `kodo-reflect.sh` | Capture learnings before context compaction |
| **Stop** | `kodo-reflect.sh` | Capture learnings when Claude stops |
| **SubagentStop** | `kodo-reflect.sh` | Capture subagent-specific learnings |

**Examples:**

```bash
kodo hooks install              # Install project-level hooks
kodo hooks install --global     # Install globally
kodo hooks status               # Check status
kodo hooks uninstall            # Remove hooks
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

**Confidence Levels:**

| Level | Description | Auto-applied? |
|-------|-------------|---------------|
| **HIGH** | Direct corrections ("Never use X") | Yes |
| **MEDIUM** | Successful patterns ("That works") | Recommended |
| **LOW** | Observations ("Might consider") | Review first |

**Examples:**

```bash
kodo learn list                     # List all learnings
kodo learn list --pending           # List pending review
kodo learn list --filter high       # Filter by confidence
kodo learn review                   # Interactive review
kodo learn review --auto-approve    # Auto-approve all
kodo learn promote abc123           # Promote by ID
kodo learn demote abc123            # Demote by ID
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
| `embeddings` | Configure embedding providers |

**Examples:**

```bash
kodo index rebuild                  # Rebuild index
kodo index rebuild --force          # Force full rebuild
kodo index status                   # Show stats
kodo index embeddings --show        # Show current config
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
kodo update check                   # Check for updates
kodo update apply                   # Install update
kodo update config --channel beta   # Switch to beta channel
kodo update config --show           # Show current config
```

---

### `kodo migrate`

Update project files to match the current CLI version. When you update the kodo binary, your project files (kodo.toml, CLAUDE.md) may become stale. This command detects drift and applies updates safely.

```bash
kodo migrate [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would change without modifying files |
| `-y, --yes` | Skip confirmation prompt (auto-confirm) |
| `--resume` | Resume an interrupted migration |

**Behavior:**

1. Computes a diff of what needs to change (missing sections in kodo.toml, template updates in CLAUDE.md, missing `.kodo/` subdirectories)
2. Shows the diff with change types: `CREATE`, `MODIFY`, `UPDATE`, `OK`
3. Prompts for confirmation (unless `--yes`)
4. Creates a timestamped backup in `.kodo/backups/migration_YYYYMMDD_HHMMSS/`
5. Applies changes step by step with state persistence
6. Stamps `kodo_version` in kodo.toml to record the current CLI version

If interrupted (e.g., power loss), the migration can be resumed with `--resume`.

**Version Drift Detection:**

On startup, kodo checks if the project's `kodo_version` differs from the CLI version. If drift is detected, a notice is printed to stderr:

```
Notice: Project files from kodo v0.2.0 (current: v0.2.3). Run kodo migrate to update.
```

This notice is suppressed for `kodo mcp serve` and `kodo migrate` commands.

**Examples:**

```bash
kodo migrate --dry-run          # Preview changes
kodo migrate                    # Interactive migration with confirmation
kodo migrate --yes              # Auto-confirm, create backup, apply
kodo migrate --resume           # Resume interrupted migration
```

---

### `kodo ports`

Manage centralized port configuration for local development. Assigns unique port ranges per project to avoid conflicts when running multiple projects simultaneously.

```bash
kodo ports [COMMAND]
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| *(none)* | Show current port configuration (default) |
| `set <N>` | Set project number (1-99) and auto-assign ports |
| `scan` | Scan codebase for port references |
| `apply` | Apply port changes to config files |

#### `kodo ports set`

Detects your tech stack, identifies which components need ports, and assigns them within the range `N*100` to `N*100+99`.

```bash
kodo ports set <NUMBER>
```

| Argument | Description |
|----------|-------------|
| `<NUMBER>` | Project number (1-99). E.g., 37 assigns ports 3700-3799 |

**What it does:**
1. Detects frameworks, databases, message brokers, and infrastructure from your tech stack
2. Assigns ports using category-based offsets (XX00 primary app, XX01-XX09 platform, XX10-XX19 databases, etc.)
3. Writes `[ports]` section to `kodo.toml`
4. Generates `.env.ports` file with environment variable mappings

#### `kodo ports scan`

Scans the entire codebase for port references in `.env` files and source code.

```bash
kodo ports scan
```

Reports config port references and hardcoded ports with confidence levels.

#### `kodo ports apply`

Apply port configuration changes.

```bash
kodo ports apply [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--auto` | Auto-rewrite config files (not yet implemented) |
| `--manual` | Print detailed manual report |
| `--prompt` | Generate structured prompt for AI coding agents |
| `-y, --yes` | Skip per-file confirmation |

**Examples:**

```bash
kodo ports                      # Show current port config
kodo ports set 37               # Assign project number 37 (ports 3700-3799)
kodo ports scan                 # Find all port references
kodo ports apply --prompt       # Generate agent prompt for port rewrites
kodo ports apply --manual       # Print manual change report
```

**Port Categories:**

| Range | Category | Example |
|-------|----------|---------|
| XX00 | Primary app | Express, Next.js, Django |
| XX01-XX09 | Platform services | Supabase, Firebase, Hasura |
| XX10-XX19 | Databases | PostgreSQL, Redis, MongoDB |
| XX20-XX29 | Message brokers | Kafka, RabbitMQ, NATS |
| XX30-XX39 | Search engines | Elasticsearch, Meilisearch |
| XX40-XX49 | Infrastructure | Grafana, Prometheus, Temporal |
| XX50-XX59 | Auth services | Keycloak, Vault |
| XX60-XX69 | Frontend tools | Storybook, Vite |
| XX70-XX79 | Testing tools | Mailhog, Mailpit |
| XX80-XX89 | Admin tools | pgAdmin, RedisInsight |
| XX90-XX99 | Misc | Jupyter, Verdaccio |

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

```bash
kodo auth verify
```

Tests each configured credential by making an API call and reporting success/failure.

#### `kodo auth setup`

```bash
kodo auth setup
```

Displays step-by-step instructions for obtaining API tokens, finding Notion database IDs, and configuring credentials.

---

### `kodo mcp`

MCP (Model Context Protocol) server for exposing kodo context to AI tools.

```bash
kodo mcp <COMMAND>
```

**Subcommands:**

| Command | Description |
|---------|-------------|
| `serve` | Start the MCP server (stdio transport, JSON-RPC 2.0) |

#### `kodo mcp serve`

Starts a Model Context Protocol server over stdio, allowing any MCP-compatible client (Claude Desktop, VS Code extensions, etc.) to access your project's context.

```bash
kodo mcp serve
```

**Protocol:** MCP version `2025-11-25` over JSON-RPC 2.0 (stdio transport)

**Exposed Tools:**

| Tool | Description | Parameters |
|------|-------------|------------|
| `kodo_query` | Search the context knowledge base | `query`, `detail` (compact/timeline/full), `limit`, `id` |
| `kodo_status` | Show project status and configuration | (none) |
| `kodo_curate` | Add a new context entry | `domain`, `topic`, `title`, `content`, `tags`, `confidence` |
| `kodo_learn_list` | List accumulated learnings | `category` (optional filter) |
| `kodo_observe` | Capture an observation from tool output | `tool_name`, `content`, `session_id` |

**Dynamic Resources (kodo:// URI scheme):**

| URI | Description |
|-----|-------------|
| `kodo://context` | Project context file (`.kodo/context.md`) |
| `kodo://learnings/{name}` | Individual learning category files |
| `kodo://context-tree/{domain}` | Context tree domain entries |

**Prompts:**

| Prompt | Description | Arguments |
|--------|-------------|-----------|
| `kodo-reflect` | Guided session reflection | `session_summary` (optional) |
| `kodo-query-guide` | Guided knowledge base search | `topic` (required) |

**Client Configuration Example (Claude Desktop):**

```json
{
  "mcpServers": {
    "kodo": {
      "command": "kodo",
      "args": ["mcp", "serve"]
    }
  }
}
```

---

### `kodo observe`

Capture an observation from tool output. This command is hidden from `--help` and is designed to be called by PostToolUse hooks.

```bash
kodo observe [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--tool <NAME>` | Name of the tool that produced the output |
| `--session-id <ID>` | Session ID for grouping observations |
| `-q, --quiet` | Suppress output |

**Behavior:**

- Reads tool output from stdin
- Compresses output to ~500 tokens (~2000 characters)
- Extracts file references and key concepts (functions, types, errors)
- Stores observations as YAML-frontmatter Markdown in `.kodo/observations/`
- 30-second deduplication window prevents duplicate captures
- Filename pattern: `YYYYMMDD-HHMMSS-toolname.md`

**Example (used by hooks, not typically called manually):**

```bash
echo "tool output here" | kodo observe --tool Bash --session-id abc123 --quiet
```

---

## Configuration

### kodo.toml Reference

The `kodo.toml` file is created in your project root by `kodo init`:

```toml
# OpenKodo Configuration
# 古道 - Your code path, remembered

[project]
name = "my-project"       # Project name (used in cloud sync)
description = "A brief description of your project"
version = "0.1.0"         # Project version
kodo_version = "0.2.4"    # CLI version that last generated/updated these files (auto-managed)

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
confidence_threshold = "medium"  # Minimum confidence for auto-apply

[sync]
remote = "origin"         # Git remote name
branch = "main"           # Git branch for sync

[models]
fast = "haiku"            # Model for fast/cheap tasks (scaffolding, boilerplate)
standard = "sonnet"       # Model for standard tasks (implementation, analysis)
premium = "opus"          # Model for complex tasks (architecture, curation)

[integrations]
github = false            # Enable GitHub integration
notion = false            # Enable Notion integration

[cloud]
api_url = "https://app.openkodo.com/api/cli"  # Cloud API URL
sync_scope = "all"        # What to sync: all, context, learnings
exclude = [".env", "*.tmp"]  # Patterns to exclude

# Port Configuration (auto-generated by kodo ports set)
# Project number: 37 -> ports 3700-3799
[ports]
project_number = 37
main_app = 3700           # Express server / Next.js dev server
supabase_api = 3701       # Supabase REST API
supabase_db = 3702        # PostgreSQL database
redis = 3710              # Redis
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
| `codex` | OpenAI Codex |

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

Credentials are stored in `.env` files. Create one in your project root or `.kodo/.env`:

```bash
# .env or .kodo/.env
# NEVER commit this file to git!

# GitHub Integration (for kodo track)
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GITHUB_OWNER=your-org-or-username
GITHUB_REPO=your-repo  # optional

# Notion Integration (for kodo docs)
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NOTION_DATABASE_ID=2f48f7779a3580228070f4e903621655

# Anthropic API (for kodo reflect --assess)
ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# OpenAI API (optional, for embeddings)
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Configuration Precedence (highest to lowest):**
1. Project `.env` (`.kodo/.env` takes precedence over `./.env`)
2. Environment variables
3. Defaults

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Configuration error |
| 4 | Not initialized (run `kodo init`) |

## All Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `kodo init` | -- | Initialize a new kodo project |
| `kodo analyze` | `kodo a` | Analyze codebase and generate context |
| `kodo extract` | `kodo x` | Extract learnings from a single file |
| `kodo reflect` | `kodo r` | Capture learnings from coding sessions |
| `kodo curate` | `kodo c` | Add or manage context entries |
| `kodo import` | `kodo i` | Import markdown files into context tree |
| `kodo query` | `kodo q` | Search accumulated context |
| `kodo status` | -- | Show project status |
| `kodo sync` | -- | Synchronize context with Git/cloud |
| `kodo track` | `kodo t` | Track items in GitHub Projects |
| `kodo docs` | `kodo d` | Manage documentation |
| `kodo flow` | `kodo f` | Intelligent content routing |
| `kodo plugin` | `kodo p` | Manage domain plugins |
| `kodo context` | -- | Context management for session hooks |
| `kodo hooks` | -- | Manage Claude Code hooks |
| `kodo learn` | -- | Manage learnings |
| `kodo index` | -- | Manage relevance index |
| `kodo update` | -- | Manage kodo updates |
| `kodo migrate` | -- | Update project files to match current CLI version |
| `kodo ports` | -- | Manage centralized port configuration |
| `kodo auth` | -- | Manage authentication |
| `kodo mcp serve` | -- | Start MCP server (stdio transport) |
| `kodo observe` | -- | Capture observation from tool output (hidden) |
