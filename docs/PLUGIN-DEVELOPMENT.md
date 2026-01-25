# Plugin Development Guide

Create custom plugins to extend OpenKodo and Claude Code with specialized workflows.

## Plugin Structure

A kodo plugin follows this structure:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # Claude Code metadata
├── plugin.json             # Kodo CLI metadata
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

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "My awesome plugin for specialized workflows",
  "agents": [
    {
      "name": "my-agent",
      "file": "agents/my-agent.md",
      "model": "sonnet",
      "description": "Agent description"
    }
  ],
  "skills": [
    {
      "name": "my-skill",
      "file": "skills/my-skill/SKILL.md",
      "command": "/my-skill",
      "description": "Skill description"
    }
  ],
  "commands": [
    {
      "name": "my-command",
      "file": "commands/my-command.md",
      "command": "/my-command",
      "description": "Command description"
    }
  ]
}
```

## Creating Agents

Agents are specialized AI assistants defined in markdown files.

### `agents/my-agent.md`

```markdown
---
name: my-agent
description: Specialized agent for domain-specific tasks
model: sonnet
tools: [Read, Write, Edit, Bash, Glob, Grep]
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

### Model Selection

| Model | Use For |
|-------|---------|
| `haiku` | Fast, simple tasks (file scaffolding, boilerplate) |
| `sonnet` | Standard tasks (implementation, analysis) |
| `opus` | Complex tasks (architecture, algorithms) |

## Creating Skills

Skills are reusable workflows that can be invoked via `/skill-name`.

### `skills/my-skill/SKILL.md`

```markdown
---
name: my-skill
description: Short description of what this skill does
command: /my-skill
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

## Examples

### Example 1: Basic Usage
```
/my-skill create a new component
```

### Example 2: With Options
```
/my-skill --verbose refactor authentication
```
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

## Creating Commands

Commands are quick actions invoked via slash commands.

### `commands/my-command.md`

```markdown
---
name: my-command
command: /my-command
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

Define plugin-specific hooks in `hooks/hooks.json`:

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

### Available Hook Events

| Event | Trigger |
|-------|---------|
| `SessionStart` | Claude Code session begins |
| `SessionEnd` | Session ends |
| `PreToolUse` | Before a tool is called |
| `PostToolUse` | After a tool returns |
| `PreCompact` | Before context compaction |
| `Stop` | When Claude stops responding |

## Testing Your Plugin

### Local Testing

1. Clone your plugin to the plugins directory:
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
```

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

3. Users can install via `/plugin` → Add Marketplace → `owner/repo`

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

## Example Plugins

See these official plugins for reference:

- [kodo](../plugins/kodo/) - Core workflows
- [kodo-design](../plugins/kodo-design/) - UI/UX design
- [kodo-supabase](../plugins/kodo-supabase/) - Supabase integration
- [kodo-posthog](../plugins/kodo-posthog/) - PostHog analytics
- [kodo-analyzer](../plugins/kodo-analyzer/) - Codebase analysis
