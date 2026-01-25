# CLI Reference

Complete command reference for the `kodo` CLI.

## Global Options

```
-h, --help       Print help
-V, --version    Print version
-v, --verbose    Increase verbosity (can be repeated: -vv, -vvv)
-q, --quiet      Suppress non-essential output
```

## Commands

### `kodo init`

Initialize OpenKodo in the current directory.

```bash
kodo init [OPTIONS]
```

**Options:**
- `--force` - Overwrite existing `.kodo/` directory
- `--template <name>` - Use a project template (rust, typescript, python)

**Creates:**
```
.kodo/
├── config.json
├── context-tree/
├── learnings/
│   ├── high-confidence.md
│   ├── medium-confidence.md
│   └── pending-review.md
└── routing.yaml
```

---

### `kodo curate` (alias: `c`)

Add or manage context entries.

```bash
kodo curate [OPTIONS] [CONTENT]
```

**Options:**
- `--topic <topic>` - Context topic/category
- `--file <path>` - Read content from file
- `--title <title>` - Entry title
- `--edit` - Open in editor
- `--list` - List all context entries
- `--delete <id>` - Delete a context entry

**Examples:**
```bash
# Add inline context
kodo curate --topic auth "We use JWT with httpOnly cookies"

# Add from file
kodo curate --topic database --file ./docs/schema.md

# List entries
kodo curate --list

# Edit interactively
kodo curate --topic testing --edit
```

---

### `kodo query` (alias: `q`)

Search accumulated context.

```bash
kodo query <SEARCH_TERM> [OPTIONS]
```

**Options:**
- `--topic <topic>` - Filter by topic
- `--limit <n>` - Max results (default: 10)
- `--format <fmt>` - Output format: text, json, markdown
- `--include-learnings` - Also search learnings

**Examples:**
```bash
kodo query "authentication"
kodo query "error handling" --topic api
kodo query "migration" --format json
```

---

### `kodo reflect` (alias: `r`)

Capture learnings from a coding session.

```bash
kodo reflect [OPTIONS] [SESSION_NOTES]
```

**Options:**
- `--stdin` - Read session notes from stdin
- `--file <path>` - Read session notes from file
- `--hook <type>` - Called by hook (precompact, stop, sessionend)
- `--auto` - Auto-categorize without confirmation
- `--quiet` - Minimal output (for hooks)

**Examples:**
```bash
# Interactive reflection
kodo reflect

# With notes
kodo reflect "Fixed auth bug. Key insight: always validate tokens server-side"

# From pipe (useful for hooks)
echo "Session summary..." | kodo reflect --stdin --auto
```

---

### `kodo analyze`

Analyze codebase and generate context.

```bash
kodo analyze [OPTIONS]
```

**Analyzers:**
- `--tech-stack` - Detect languages, frameworks, dependencies
- `--architecture` - Identify patterns (MVC, hexagonal, etc.)
- `--database` - Scan schemas, migrations, models
- `--api` - Find API endpoints and patterns
- `--testing` - Analyze test structure and coverage
- `--documentation` - Find and assess docs
- `--security` - Basic security pattern scan
- `--dependencies` - Dependency analysis

**Options:**
- `--all` - Run all analyzers (default)
- `--auto` - Auto-import findings
- `--review` - Interactive review mode
- `--json` - Output as JSON
- `--dry-run` - Preview without changes

**Examples:**
```bash
kodo analyze                    # All analyzers
kodo analyze --tech-stack       # Just tech stack
kodo analyze --auto             # Auto-import all
kodo analyze --review           # Interactive review
```

---

### `kodo status`

Show project status and statistics.

```bash
kodo status [OPTIONS]
```

**Options:**
- `--json` - Output as JSON
- `--verbose` - Include detailed stats

**Shows:**
- Context entry count by topic
- Learning counts by confidence
- Last sync time
- Hook status

---

### `kodo learn`

Manage learned patterns.

```bash
kodo learn <SUBCOMMAND>
```

**Subcommands:**
- `list` - List learnings by confidence
- `promote <id>` - Promote learning to higher confidence
- `demote <id>` - Demote learning to lower confidence
- `delete <id>` - Delete a learning
- `export` - Export learnings as markdown

**Examples:**
```bash
kodo learn list --high          # High confidence only
kodo learn list --pending       # Pending review
kodo learn promote abc123       # Promote to higher confidence
kodo learn export > learnings.md
```

---

### `kodo hooks`

Manage Claude Code integration hooks.

```bash
kodo hooks <SUBCOMMAND>
```

**Subcommands:**
- `install` - Install hooks to `.claude/settings.json`
- `uninstall` - Remove hooks
- `status` - Check hook installation status

**Examples:**
```bash
kodo hooks install
kodo hooks status
```

---

### `kodo plugin`

Manage kodo plugins.

```bash
kodo plugin <SUBCOMMAND>
```

**Subcommands:**
- `list` - List installed plugins
- `list --available` - List available plugins
- `install <name>` - Install a plugin
- `uninstall <name>` - Uninstall a plugin
- `update [name]` - Update plugin(s)

**Examples:**
```bash
kodo plugin list --available
kodo plugin install kodo-design
kodo plugin update
```

---

### `kodo index`

Manage the search index.

```bash
kodo index <SUBCOMMAND>
```

**Subcommands:**
- `rebuild` - Rebuild search index
- `status` - Show index status
- `clear` - Clear index

---

### `kodo context`

Context injection utilities.

```bash
kodo context <SUBCOMMAND>
```

**Subcommands:**
- `load` - Load and output context for injection
- `export` - Export all context as markdown

**Options:**
- `--quiet` - Minimal output
- `--format <fmt>` - Output format

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `KODO_HOME` | Global kodo directory | `~/.kodo` |
| `KODO_LOG_LEVEL` | Logging level | `info` |
| `KODO_NO_COLOR` | Disable colored output | unset |
| `GITHUB_TOKEN` | GitHub API token | unset |
| `NOTION_TOKEN` | Notion API token | unset |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Configuration error |
| 4 | Not initialized (run `kodo init`) |
