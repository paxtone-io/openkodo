# Plugin Development Guide

Create custom plugins to extend OpenKodo and Claude Code with specialized workflows.

## Plugin Structure

A kodo plugin follows this structure:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # Claude Code metadata
├── plugin.json             # Kodo CLI metadata (skills, agents, commands, hooks)
├── README.md               # Plugin documentation
├── agents/                 # AI agent definitions
│   └── my-agent.md
├── skills/                 # Skill workflows
│   └── my-skill/
│       ├── SKILL.md        # Main skill file
│       └── references/     # Supporting documents
│           └── patterns.md
├── commands/               # Slash commands (optional)
│   └── my-command.md
└── hooks/                  # Hook configurations (optional)
    └── hooks.json
```

## Plugin Metadata

### `.claude-plugin/plugin.json` (Claude Code)

This file registers the plugin with Claude Code:

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "My awesome plugin for specialized workflows",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "homepage": "https://github.com/you/my-plugin",
  "repository": "https://github.com/you/my-plugin",
  "license": "MIT",
  "keywords": ["workflow", "automation", "my-domain"]
}
```

### `plugin.json` (Kodo CLI)

This file registers skills, agents, commands, and hooks:

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "My awesome plugin for specialized workflows",
  "skills": [
    {
      "name": "my-skill",
      "file": "skills/my-skill/SKILL.md",
      "command": "/my-plugin-my-skill",
      "description": "Skill description"
    }
  ],
  "agents": [
    {
      "name": "my-agent",
      "file": "agents/my-agent.md",
      "model": "sonnet",
      "description": "Agent description"
    }
  ],
  "commands": [
    {
      "name": "my-command",
      "file": "commands/my-command.md",
      "command": "/my-plugin-my-command",
      "description": "Command description"
    }
  ]
}
```

### Command Format

Slash commands use **hyphen-separated** format:

```
/kodo-brainstorm     ✓ Correct (hyphen)
/kodo brainstorm     ✗ Wrong (space)
/kodo:brainstorm     ✗ Wrong (colon)
```

For plugin-specific commands, prefix with the plugin name:

```
/kodo-design         # kodo-design plugin
/kodo-supa-db        # kodo-supabase plugin
/kodo-ph-event       # kodo-posthog plugin
/kodo-analyze        # kodo-analyzer plugin
```

## Creating Agents

Agents are specialized AI assistants defined in markdown files with YAML frontmatter.

### Agent Naming Convention

Follow the `kodo-{single-word-role}` pattern:

```
kodo-explorer     kodo-reviewer     kodo-tester
kodo-architect    kodo-debugger     kodo-planner
kodo-feature      kodo-refactor     kodo-sentinel
```

### `agents/my-agent.md`

```markdown
---
name: my-agent
description: Specialized agent for domain-specific tasks
model: sonnet
tools: [Read, Write, Edit, Bash, Glob, Grep]
color: cyan
---

# My Agent

You are a specialized agent for [domain].

## Capabilities

- Capability 1
- Capability 2

## Workflow

1. Step 1
2. Step 2
3. Step 3

## Guidelines

- Guideline 1
- Guideline 2
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Agent identifier (kodo-{role} pattern) |
| `description` | Yes | What the agent does (shown in agent list) |
| `model` | Yes | AI model: `haiku`, `sonnet`, or `opus` |
| `tools` | Yes | Available tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch, etc. |
| `color` | No | Terminal color for output: cyan, blue, magenta, green, red, orange, purple, yellow, bright_yellow, bright_red, bright_magenta, bright_white |

### Model Selection

| Model | Cost | Use For |
|-------|------|---------|
| `haiku` | Low | File scaffolding, boilerplate, simple sync, test generation |
| `sonnet` | Medium | Core implementation, analysis, feature work, debugging |
| `opus` | High | Complex architecture, learning curation, ambiguous specs |

## Creating Skills

Skills are reusable workflows invoked via slash commands.

### Skill Naming Convention

Plugin skills use simple verb/noun names in their directory:

```
skills/brainstorm/SKILL.md    # invoked as /kodo-brainstorm
skills/design/SKILL.md        # invoked as /kodo-design
skills/pr-context/SKILL.md    # invoked as /kodo-pr-context
```

### `skills/my-skill/SKILL.md`

```markdown
---
name: my-skill
description: Short description of what this skill does
command: /my-plugin-my-skill
---

# My Skill

## When to Use

Use this skill when you need to [purpose].

## Workflow

### Phase 1: Analysis
1. Analyze the current state
2. Identify requirements

### Phase 2: Implementation
1. Create necessary files
2. Implement logic
3. Verify correctness

### Phase 3: Verification
1. Run tests
2. Check for regressions

## References

- [patterns](./references/patterns.md) - Common patterns
- [checklist](./references/checklist.md) - Verification checklist
```

### Reference Files

Store supporting documentation in `references/`:

```markdown
<!-- skills/my-skill/references/patterns.md -->
# Common Patterns

## Pattern 1: Name
Description and example...

## Pattern 2: Name
Description and example...
```

### Special Frontmatter

| Field | Description |
|-------|-------------|
| `disable-model-invocation: true` | Skill runs without calling an AI model (for checklists, templates) |

## Creating Commands

Commands are quick slash-command actions with structured arguments.

### `commands/my-command.md`

```markdown
---
name: my-command
command: /my-plugin-my-command
description: Quick action for specific task
args:
  - name: target
    description: Target to operate on
    required: true
  - name: --dry-run
    description: Preview without changes
    required: false
---

# My Command

Execute this command to [purpose].

## Arguments

- `target` - The target to operate on
- `--dry-run` - Preview changes without applying

## Steps

1. Parse arguments
2. Validate target exists
3. Perform operation
4. Report results
```

## Hooks

Define plugin hooks for lifecycle events.

### Plugin Hooks (`hooks/hooks.json`)

```json
{
  "SessionStart": [
    {
      "type": "command",
      "command": "my-plugin context load",
      "description": "Load plugin-specific context"
    }
  ],
  "PreToolUse": [
    {
      "type": "prompt",
      "prompt": "Before using this tool, consider...",
      "tools": ["Write", "Edit"]
    }
  ]
}
```

### Inline Hooks (in `plugin.json`)

```json
{
  "name": "my-plugin",
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "kodo context load --quiet",
        "description": "Load context at session start"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "kodo reflect --hook stop --quiet",
        "description": "Capture learnings when Claude stops"
      }
    ]
  }
}
```

### Available Hook Events

| Event | Trigger | Use Case |
|-------|---------|----------|
| `SessionStart` | Claude Code session begins | Load context, check status |
| `SessionEnd` | Session ends | Prompt for reflection |
| `PreToolUse` | Before a tool is called | Block dangerous operations, validate inputs |
| `PostToolUse` | After a tool returns | Auto-format code, run linters |
| `PreCompact` | Before context compaction | Capture learnings before memory is trimmed |
| `Stop` | When Claude stops responding | Auto-capture learnings |
| `SubagentStop` | When a subagent finishes | Capture subagent-specific learnings |
| `UserPromptSubmit` | User sends a message | Count messages, track session activity |

### Hook Types

| Type | Description |
|------|-------------|
| `command` | Runs a shell command. Receives JSON on stdin. Exit 0 = allow, exit 1 = block (PreToolUse only). |
| `prompt` | Injects a prompt into the conversation. |

### Writing Shell Hook Scripts

Hook scripts receive JSON on stdin with tool input details:

```bash
#!/bin/bash
set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Your logic here
if echo "$FILE_PATH" | grep -qE '\.env$'; then
    echo "BLOCK: Cannot edit .env files directly"
    exit 1
fi

exit 0
```

## Testing Your Plugin

### Local Testing

1. Symlink your plugin to the plugins directory:
   ```bash
   ln -s ~/my-plugin ~/.claude/plugins/my-plugin
   ```

2. Restart Claude Code

3. Verify with `/plugin` command

### Validate Structure

```bash
# Check required files exist
ls -la my-plugin/.claude-plugin/plugin.json
ls -la my-plugin/plugin.json

# Validate JSON
cat my-plugin/plugin.json | jq .
cat my-plugin/.claude-plugin/plugin.json | jq .
```

### Checklist

- [ ] `plugin.json` and `.claude-plugin/plugin.json` have matching versions
- [ ] All skill files referenced in `plugin.json` exist
- [ ] All agent files referenced in `plugin.json` exist
- [ ] All commands use hyphen-separated format (`/prefix-name`)
- [ ] Agents have valid frontmatter (name, description, model, tools)
- [ ] Skills have valid frontmatter (name, description)

## Publishing

### To Marketplace

1. Create a public GitHub repository
2. Add `.claude-plugin/marketplace.json`:

```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "My plugin collection",
  "owner": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin",
      "description": "Plugin description",
      "category": "productivity"
    }
  ]
}
```

3. Users install via `/plugin` > Add Marketplace > `owner/repo`

### Version Management

- Keep versions in sync between `plugin.json` and `.claude-plugin/plugin.json`
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Document changes in CHANGELOG.md

## Best Practices

1. **Single Responsibility** - Each plugin should focus on one domain
2. **Clear Documentation** - Include README with usage examples
3. **Sensible Defaults** - Work out-of-the-box with minimal config
4. **Non-Destructive** - Don't modify user files without confirmation
5. **Testable** - Include examples that can be tested
6. **Consistent Naming** - Follow `kodo-{role}` for agents, hyphen-separated for commands
7. **Right-Sized Models** - Use haiku for simple tasks, sonnet for standard, opus for complex

## Example Plugins

See these official plugins for reference:

- [kodo](../plugins/kodo/) - Core development workflows (16 skills, 12 agents)
- [kodo-design](../plugins/kodo-design/) - UI/UX design (5 skills, 2 agents)
- [kodo-analyzer](../plugins/kodo-analyzer/) - Codebase analysis (2 skills, 9 agents)
- [kodo-posthog](../plugins/kodo-posthog/) - PostHog analytics (6 commands, 3 agents)
- [kodo-supabase](../plugins/kodo-supabase/) - Supabase integration (8 commands, 3 agents)
