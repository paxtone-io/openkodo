# Getting Started with OpenKodo

OpenKodo (古道 - "Ancient Path") is a context management CLI and self-learning system for AI coding tools.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Core Workflows](#core-workflows)
- [Claude Code Integration](#claude-code-integration)
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
```

---

## Quick Start

### Initialize a Project

Navigate to your project directory and run:

```bash
cd your-project
kodo init
```

This creates:

- `kodo.toml` - Project configuration file (in project root)
- `AGENTS.md` - Industry-standard AI agent instructions
- `.kodo/` directory containing:
  - `context-tree/` - Hierarchical knowledge storage
  - `learnings/` - Captured patterns by confidence level
  - `logs/` - Debug and trace logs

During initialization, you'll be asked to select which AI coding assistants you use. Kodo generates appropriate documentation files for each:

| Agent | File Generated |
|-------|----------------|
| Claude Code | `.claude/CLAUDE.md` |
| Cursor | `.cursor/rules/kodo.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurf/rules/kodo.md` |
| Warp, Aider | Use `AGENTS.md` directly |

You can also specify agents via CLI:

```bash
kodo init --agent claude-code,cursor
```

### Analyze Your Codebase

Run the analyzer to automatically detect your project's structure:

```bash
kodo analyze
```

This scans for:
- Tech stack (languages, frameworks, dependencies)
- Architecture patterns (MVC, hexagonal, etc.)
- Database schemas and migrations
- API endpoints
- Test structure

### Enable Auto-Reflection

Set up automatic learning capture:

```bash
kodo reflect on
```

This enables kodo to capture patterns and insights from your coding sessions.

### Set Up Integrations (Optional)

To use GitHub and Notion integrations, create a `.env` file:

```bash
# Create .env in project root or .kodo/.env
cp .env.example .env
# Edit .env with your API credentials
```

Check your authentication status:

```bash
kodo auth status
```

Verify credentials work by testing API connections:

```bash
kodo auth verify
```

For detailed setup instructions:

```bash
kodo auth setup
```

See [CLI Reference - kodo auth](CLI-REFERENCE.md#kodo-auth) for full documentation.

---

## Project Structure

After initialization, your project will have:

```
your-project/
├── kodo.toml              # Project configuration
├── AGENTS.md              # Industry-standard AI instructions
├── .claude/               # Claude Code specific
│   ├── CLAUDE.md          # Claude instructions (superset of AGENTS.md)
│   └── skills/            # Custom skills
├── .cursor/               # Cursor specific (if selected)
│   └── rules/
│       └── kodo.mdc       # Cursor rules
├── .kodo/
│   ├── context-tree/      # Organized knowledge
│   │   ├── architecture/
│   │   ├── database/
│   │   └── ...
│   ├── learnings/         # Captured patterns
│   │   ├── high-confidence.md
│   │   ├── medium-confidence.md
│   │   └── pending-review.md
│   └── logs/              # Debug logs
└── ... (your project files)
```

### kodo.toml Configuration

The main configuration file:

```toml
[project]
name = "your-project"
description = "A brief description"
version = "0.1.0"

[tech_stack]
languages = ["rust"]
frameworks = ["axum"]
package_managers = ["cargo"]
test_frameworks = ["cargo-test"]

[agents]
primary = "claude-code"
enabled = ["claude-code", "cursor"]

[learning]
auto_reflect = true
confidence_threshold = "medium"

[sync]
remote = "origin"
branch = "main"

[integrations]
github = false
notion = false
```

See [CLI Reference - Configuration](CLI-REFERENCE.md#configuration) for all options.

---

## Core Workflows

### 1. Capture Context Manually

Add important knowledge about your codebase:

```bash
# Add a context entry
kodo curate --domain auth --topic jwt "Always validate tokens server-side"

# Import from a file
kodo curate --from ./docs/architecture.md --domain architecture

# Interactive mode
kodo curate --interactive
```

### 2. Search Context

Find relevant information:

```bash
# Simple search
kodo query "authentication"

# With format options
kodo query "error handling" --format json --full

# Interactive search
kodo query --interactive
```

### 3. Review Learnings

Manage captured patterns:

```bash
# Show learning statistics
kodo reflect --status

# List all learnings
kodo learn list

# Review pending learnings
kodo learn review

# Promote a learning to higher confidence
kodo learn promote <id>
```

### 4. Sync Your Context

Keep your context synchronized:

```bash
# Sync to Git
kodo sync

# Sync and push
kodo sync --push

# Sync to cloud (requires token)
kodo sync --cloud-only
```

### 5. Manage Agent Documentation

Keep your AI agent documentation in sync:

```bash
# Check status of agent doc files
kodo docs agent status

# Sync all files from AGENTS.md (source of truth)
kodo docs agent sync

# Regenerate all agent docs from kodo.toml
kodo docs agent regenerate
```

When you update project information in `AGENTS.md`, run `kodo docs agent sync` to propagate changes to all tool-specific files.

---

## Claude Code Integration

### Install as Plugin

In Claude Code:
1. Type `/plugin`
2. Select "Add Marketplace"
3. Enter `paxtone-io/openkodo`

Or install specific plugins via CLI:

```bash
kodo plugin add design      # UI/UX design workflows
kodo plugin add supabase    # Supabase integration
kodo plugin add posthog     # PostHog analytics
kodo plugin add analyzer    # Advanced analysis
```

### Install Hooks

Enable automatic reflection during Claude Code sessions:

```bash
kodo hooks install
```

This installs hooks that:
- Load context at session start
- Capture learnings during coding
- Sync learnings at session end

Check hook status:

```bash
kodo hooks status
```

---

## Next Steps

1. **Explore Commands**: See [CLI Reference](CLI-REFERENCE.md) for all commands
2. **Install Plugins**: Add domain-specific capabilities with `kodo plugin list --available`
3. **Set Up Integrations**: Configure GitHub and Notion in `kodo.toml`
4. **Join the Community**: Report issues at [GitHub](https://github.com/paxtone-io/openkodo/issues)

### Useful Commands

```bash
# Check project status
kodo status

# Update kodo
kodo update check
kodo update apply

# Get help
kodo --help
kodo <command> --help
```
