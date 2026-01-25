# Getting Started with OpenKodo

OpenKodo (古道 - "Ancient Path") is a context management CLI and self-learning system for AI coding tools. It helps AI assistants remember your patterns, preferences, and project-specific knowledge across sessions.

## Installation

### Quick Install

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.ps1 | iex
```

### Manual Installation

1. Download the appropriate binary from [Releases](https://github.com/paxtone-io/openkodo/releases)
2. Extract the archive
3. Move `kodo` to a directory in your PATH (e.g., `/usr/local/bin/`)

### Verify Installation

```bash
kodo --version
```

## Initialize a Project

Navigate to your project directory and run:

```bash
cd your-project
kodo init
```

This creates a `.kodo/` directory with:
- `context-tree/` - Hierarchical knowledge storage
- `learnings/` - Captured patterns by confidence level
- `config.json` - Project configuration

## Basic Usage

### Add Context

Store project-specific knowledge:

```bash
# Add context with a topic
kodo curate --topic architecture "We use hexagonal architecture with ports and adapters"

# Add context from a file
kodo curate --topic testing --file ./docs/testing-guide.md
```

### Query Context

Search your accumulated knowledge:

```bash
kodo query "how do we handle authentication?"
kodo query "database migration patterns" --topic database
```

### Capture Learnings

After a coding session, capture what you learned:

```bash
kodo reflect
```

This analyzes your recent work and extracts:
- **HIGH confidence**: Corrections and explicit preferences → auto-applied
- **MEDIUM confidence**: Successful patterns → recommended
- **LOW confidence**: Observations → tracked for patterns

### Analyze Codebase

Auto-discover patterns and generate context:

```bash
kodo analyze                    # Run all analyzers
kodo analyze --tech-stack       # Detect technologies used
kodo analyze --architecture     # Identify architecture patterns
kodo analyze --auto             # Auto-import findings
```

## Claude Code Integration

### Install Plugin via Claude Code

In Claude Code, use the `/plugin` command:
1. Type `/plugin`
2. Select "Add Marketplace"
3. Enter: `paxtone-io/openkodo`
4. Select plugins to install

### Auto-Reflection Hooks

Enable automatic learning capture:

```bash
kodo hooks install
```

This sets up hooks that:
- Load context at session start
- Capture learnings before context compaction
- Prompt for reflection at session end

## Configuration

Edit `.kodo/config.json`:

```json
{
  "project_name": "my-project",
  "auto_inject": true,
  "confidence_threshold": "medium",
  "analyzers": {
    "enabled": ["tech-stack", "architecture", "database"]
  }
}
```

## Next Steps

- [CLI Reference](./CLI-REFERENCE.md) - Full command documentation
- [Plugin Development](./PLUGIN-DEVELOPMENT.md) - Create custom plugins
- Check `kodo --help` for all available commands
