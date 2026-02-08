# Claude Code Integration

Comprehensive guide to using OpenKodo within Claude Code via plugins, slash commands, agents, and hooks.

## Table of Contents

- [Setup](#setup)
- [MCP Server](#mcp-server)
- [Plugin Ecosystem](#plugin-ecosystem)
- [Slash Commands Reference](#slash-commands-reference)
- [Agents Reference](#agents-reference)
- [Hook System](#hook-system)
- [Model Role Abstraction](#model-role-abstraction)
- [Recommended Workflows](#recommended-workflows)

---

## Setup

### Install the Marketplace

In Claude Code:

1. Type `/plugin`
2. Select "Add Marketplace"
3. Enter `paxtone-io/openkodo`

This installs the core `kodo` plugin. To add domain-specific plugins:

```bash
kodo plugin add design      # UI/UX design workflows
kodo plugin add analyzer    # Codebase analysis
kodo plugin add posthog     # PostHog analytics
kodo plugin add supabase    # Supabase integration
```

### Install Hooks

Enable automatic context loading and learning capture:

```bash
kodo hooks install
```

### Verify

```bash
kodo hooks status
kodo plugin list
```

---

## MCP Server

OpenKodo v0.2.0 introduces a built-in MCP (Model Context Protocol) server, allowing any MCP-compatible AI tool to access your project's context without plugins.

### Why Use MCP?

- **Universal**: Works with Claude Desktop, VS Code extensions, and any MCP client
- **No Plugin Required**: Direct access to kodo context outside of Claude Code
- **Token-Efficient**: Progressive disclosure via `kodo_query` tool minimizes token usage
- **Bidirectional**: AI tools can both read context and write observations

### Configuration

Add kodo as an MCP server in your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `kodo_query` | Search context with progressive detail levels (compact/timeline/full) |
| `kodo_status` | Show project status, learnings count, integrations, model config |
| `kodo_curate` | Add a new context entry to the knowledge base |
| `kodo_learn_list` | List accumulated learnings, optionally filtered by category |
| `kodo_observe` | Capture an observation from tool output |

### Available MCP Resources

Dynamic resources via `kodo://` URI scheme:

| URI | Description |
|-----|-------------|
| `kodo://context` | Project context file |
| `kodo://learnings/{category}` | Learning files (rules, decisions, tech-stack, etc.) |
| `kodo://context-tree/{domain}` | Context tree domain entries |

### Available MCP Prompts

| Prompt | Description |
|--------|-------------|
| `kodo-reflect` | Guided session reflection workflow |
| `kodo-query-guide` | Guided knowledge base search |

### MCP + Plugin Together

The MCP server and Claude Code plugins are complementary:
- **MCP**: Provides tools, resources, and prompts to any MCP client
- **Plugins**: Provide slash commands, agents, and lifecycle hooks specific to Claude Code

You can use both simultaneously for the richest experience.

---

## Plugin Ecosystem

OpenKodo provides 5 plugins, each with specialized skills, agents, and commands.

### Core Plugin: `kodo`

The foundation plugin providing universal development process skills.

**16 slash commands** | **12 agents** | **4 lifecycle hooks**

### Design Plugin: `kodo-design`

UI/UX design with Design Bible principles and WCAG accessibility compliance.

**5 slash commands** | **2 agents** | **5 reference docs**

### Analyzer Plugin: `kodo-analyzer`

Comprehensive codebase analysis with health scoring and gap detection.

**2 slash commands** | **9 agents** (1 orchestrator + 8 specialists) | **3 reference docs**

### PostHog Plugin: `kodo-posthog`

PostHog analytics integration for events, feature flags, and experiments.

**6 slash commands** | **3 agents** | **6 reference docs**

### Supabase Plugin: `kodo-supabase`

Supabase integration for databases, auth, Edge Functions, and hybrid ORM workflows.

**8 slash commands** | **3 agents** | **14 reference docs**

---

## Slash Commands Reference

All OpenKodo slash commands use the **`/kodo-{name}`** format (hyphen-separated).

### Core Development Skills

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-brainstorm` | Collaborative design questioning | Starting a new feature, exploring ideas |
| `/kodo-plan` | TDD-driven implementation planning | Before writing code for any feature |
| `/kodo-execute` | Plan execution with checkpoints | Implementing a plan step by step |
| `/kodo-review` | Confidence-based code review | Before committing, after feature work |
| `/kodo-debug` | Systematic debugging workflow | When facing bugs or test failures |
| `/kodo-test` | Intelligent test runner | Running affected tests, checking coverage |
| `/kodo-refactor` | Guided safe refactoring | Restructuring code with safety checks |
| `/kodo-explore` | Deep codebase exploration | Understanding unfamiliar code areas |

### Context & Knowledge

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-curate` | Manage context entries | Adding project knowledge |
| `/kodo-query` | Search context and learnings | Finding existing knowledge |
| `/kodo-sync` | Synchronize via Git/cloud | Persisting and sharing context |

### Integration Commands

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-track` | GitHub Projects management | Creating/tracking issues |
| `/kodo-docs` | Notion documentation | Managing docs and ADRs |
| `/kodo-flow` | Content routing | Routing content to the right place |

### Release & PR

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-pr-context` | PR description from session | Before creating a pull request |
| `/kodo-release-check` | Pre-release validation | Before publishing a release |

### Design Commands

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-design` | Design a UI component | Building new UI with design principles |
| `/kodo-design-system` | Create/update design foundation | Setting up or evolving design tokens |
| `/kodo-design-audit` | Audit existing UI | Reviewing UI consistency and a11y |
| `/kodo-design-theme` | WCAG color theme audit | Validating color accessibility |
| `/kodo-design-inspire` | Research design inspiration | Exploring design references |

### Analysis Commands

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-analyze` | Comprehensive codebase analysis | Health checks, gap detection |
| `/kodo-deep-analyze` | Deep doc extraction | Extracting learnings from documentation |

### PostHog Commands

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-posthog` | PostHog analytics guide | Analytics strategy and implementation |
| `/kodo-ph-event` | Track custom events | Adding event tracking |
| `/kodo-ph-flag` | Manage feature flags | Creating/updating feature flags |
| `/kodo-ph-experiment` | A/B experiments | Designing and analyzing experiments |
| `/kodo-ph-dashboard` | Manage dashboards | Creating analytics dashboards |
| `/kodo-ph-sync` | Sync with Notion | Keeping analytics docs updated |

### Supabase Commands

| Command | Description | When to Use |
|---------|-------------|------------|
| `/kodo-supabase` | Architecture guide | Deciding Supabase feature approaches |
| `/kodo-supa-db` | Database operations | Managing database with ORM |
| `/kodo-supa-decide` | Architecture decisions | Choosing between implementation strategies |
| `/kodo-supa-deploy` | Deploy changes | Pushing to production |
| `/kodo-supa-edge` | Edge Functions | Creating/managing Edge Functions |
| `/kodo-supa-migrate` | Database migrations | Running migrations with hybrid ORM |
| `/kodo-supa-schema` | Schema management | Evolving database schema |
| `/kodo-supa-status` | Project health check | Checking Supabase project status |

---

## Agents Reference

Agents are specialized AI assistants that Claude Code can delegate work to. They run as subagents with specific roles, tools, and model assignments.

### Core Agents (kodo plugin)

| Agent | Role | Description |
|-------|------|-------------|
| `kodo-explorer` | standard | Fast codebase exploration and file discovery |
| `kodo-architect` | premium | Architecture design and system-level decisions |
| `kodo-feature` | standard | Feature implementation with test-driven approach |
| `kodo-reviewer` | standard | Code review with confidence-based issue filtering |
| `kodo-debugger` | standard | Systematic bug investigation and root cause analysis |
| `kodo-refactor` | standard | Safe code restructuring with test verification |
| `kodo-tester` | fast | Test scaffolding and test file generation |
| `kodo-planner` | standard | Implementation planning with dependency mapping |
| `kodo-curator` | premium | Learning curation, dedup, and quality scoring |
| `kodo-sentinel` | standard | Security review, vulnerability detection, OWASP checks |
| `kodo-optimizer` | standard | Performance profiling and optimization recommendations |
| `kodo-documenter` | fast | Documentation generation and sync |

### Analyzer Agents (kodo-analyzer plugin)

| Agent | Role | Description |
|-------|------|-------------|
| `kodo-codebase-analyzer` | standard | Main orchestrator, spawns specialized sub-agents |
| `kodo-database-analyzer` | fast | Schema analysis, RLS, indexes |
| `kodo-api-analyzer` | fast | Endpoint coverage, auth, error handling |
| `kodo-frontend-analyzer` | fast | Component a11y, state management |
| `kodo-dependencies-analyzer` | fast | Outdated packages, vulnerabilities |
| `kodo-posthog-analyzer` | fast | Event coverage, feature flag completeness |
| `kodo-documentation-analyzer` | fast | Doc coverage, accuracy, staleness |
| `kodo-security-analyzer` | standard | Vulnerabilities, auth, secrets, CVSS |
| `kodo-performance-analyzer` | standard | Query bottlenecks, bundle size, caching |

### Design Agents (kodo-design plugin)

| Agent | Role | Description |
|-------|------|-------------|
| `kodo-design-agent` | standard | UI component design with Design Bible principles |
| `kodo-a11y-auditor` | standard | WCAG accessibility auditing |

### PostHog Agents (kodo-posthog plugin)

| Agent | Role | Description |
|-------|------|-------------|
| `kodo-ph-analyst` | standard | Product insights from PostHog data |
| `kodo-ph-experiment-agent` | standard | A/B experiment design and statistical analysis |
| `kodo-ph-sync-agent` | fast | PostHog-Notion configuration sync |

### Supabase Agents (kodo-supabase plugin)

| Agent | Role | Description |
|-------|------|-------------|
| `kodo-supa-architect` | standard | Architecture decisions for Supabase features |
| `kodo-supa-edge-agent` | standard | Edge Function implementation |
| `kodo-supa-migrator` | standard | Database migration and schema management |

### Model Strategy

As of v0.2.0, agents use abstract **model roles** instead of hardcoded model names. See [Model Role Abstraction](#model-role-abstraction) below.

| Role | Default Model | Use For |
|------|---------------|---------|
| **fast** | haiku | File scaffolding, boilerplate, test generation, simple sync tasks |
| **standard** | sonnet | Core implementation, analysis, debugging, feature work |
| **premium** | opus | Complex architecture decisions, learning curation, ambiguous specs |

---

## Hook System

Hooks fire automatically during Claude Code sessions to keep your context fresh and capture learnings.

### Plugin Hooks (installed via `kodo hooks install`)

| Event | Script | Description |
|-------|--------|-------------|
| **SessionStart** | `kodo-session-start.sh` | Load recent context and active learnings at session start |
| **UserPromptSubmit** | `kodo-message-count.sh` | Track message count for time/count-based auto-reflection |
| **PostToolUse** | `kodo-observe.sh` | Auto-capture observations from tool outputs into `.kodo/observations/` |
| **PreCompact** | `kodo-reflect.sh` | Capture learnings before context is compacted |
| **Stop** | `kodo-reflect.sh` | Capture learnings when Claude stops responding |
| **SubagentStop** | `kodo-reflect.sh` | Capture subagent-specific learnings |

The **PostToolUse observation hook** (new in v0.2.0) silently captures tool outputs in the background, compressing them to ~500 tokens and extracting file references and key concepts. These observations feed into the learning pipeline for richer context.

### Safety Hooks (installed via `.claude/settings.json`)

| Event | Matcher | Action |
|-------|---------|--------|
| **PostToolUse** | `Edit\|Write` | Auto-runs `cargo fmt` after file edits (Rust projects) |
| **PreToolUse** | `Edit\|Write` | Blocks direct edits to `.env` files |
| **PreToolUse** | `Bash` | Blocks `git push --force` to main/master and `git reset --hard` on protected branches |

### Custom Hooks

You can add project-specific hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": "your-formatter --quiet",
            "timeout": 15,
            "type": "command"
          }
        ]
      }
    ]
  }
}
```

Hook scripts receive JSON on stdin with tool input details. Exit code 0 allows the action; exit code 1 blocks it (PreToolUse only).

---

## Model Role Abstraction

New in v0.2.0, the **Model Role Abstraction Layer** decouples agent definitions from specific model names. Instead of hardcoding "haiku", "sonnet", or "opus", agents reference semantic roles.

### Roles

| Role | Description | Default Model |
|------|-------------|---------------|
| **fast** | Fastest, cheapest model for scaffolding and boilerplate | `haiku` |
| **standard** | Balanced model for core implementation work | `sonnet` |
| **premium** | Most capable model for complex analysis and architecture | `opus` |

### Configuration

Override default model mappings in `kodo.toml`:

```toml
[models]
fast = "haiku"          # Map fast role to haiku
standard = "sonnet"     # Map standard role to sonnet
premium = "opus"        # Map premium role to opus
```

This lets you:
- Swap models as new versions release (e.g., `standard = "sonnet-4.5"`)
- Use cheaper models during development and premium models for production
- Upgrade all agents at once by changing one config value

### Legacy Compatibility

Existing agent definitions using direct model names (`haiku`, `sonnet`, `opus`) are automatically mapped to the corresponding role via `ModelRole::from_legacy()`. No changes needed to existing plugins.

---

## Recommended Workflows

### Feature Development (Full Cycle)

```
/kodo-brainstorm              # Explore the idea collaboratively
/kodo-plan                    # Create a TDD implementation plan
/kodo-execute                 # Execute the plan step by step
/kodo-test                    # Verify with tests
/kodo-review                  # Review the implementation
/kodo-pr-context              # Generate PR description
```

### Bug Fix

```
/kodo-debug                   # Systematic investigation
/kodo-query "related error"   # Search existing knowledge
/kodo-test                    # Verify the fix
/kodo-review                  # Review changes
```

### Codebase Onboarding

```
/kodo-explore                 # Understand the codebase
/kodo-analyze                 # Get a health report
/kodo-query "architecture"    # Find documented patterns
```

### UI Development

```
/kodo-design-system           # Set up or review design foundation
/kodo-design                  # Design a specific component
/kodo-design-audit            # Audit existing UI
/kodo-design-theme            # Validate accessibility
/kodo-design-inspire          # Get design inspiration
```

### Release Preparation

```
/kodo-release-check           # Validate readiness
/kodo-test                    # Run full test suite
/kodo-review                  # Final code review
/kodo-pr-context              # Generate release notes context
```

### Analytics Implementation

```
/kodo-posthog                 # Plan analytics strategy
/kodo-ph-event                # Implement event tracking
/kodo-ph-flag                 # Set up feature flags
/kodo-ph-experiment           # Design A/B tests
/kodo-ph-dashboard            # Create dashboards
```

### Database Work (Supabase)

```
/kodo-supabase                # Architecture guidance
/kodo-supa-schema             # Design schema changes
/kodo-supa-migrate            # Run migrations
/kodo-supa-edge               # Create Edge Functions
/kodo-supa-deploy             # Deploy to production
```

---

## Tips

- **Session Start**: Hooks automatically load context - you start with full project knowledge
- **Session End**: Hooks auto-capture learnings, but running `kodo reflect` manually gives more thorough capture
- **Observations**: The PostToolUse hook silently captures tool outputs - these build up a rich observation history in `.kodo/observations/`
- **Search Before Asking**: Use `/kodo-query` to check if knowledge already exists before asking questions
- **Use Compact Detail**: When tokens are limited, use `--detail compact` in queries for ~50 tokens per result
- **Combine CLI and Slash Commands**: Use `kodo analyze` in terminal and `/kodo-brainstorm` in Claude Code - they share the same `.kodo/` knowledge base
- **MCP + Plugins**: Use `kodo mcp serve` for universal MCP access and plugins for Claude Code-specific features
- **Model Customization**: Override model mappings in `kodo.toml` `[models]` to swap models as new versions release
- **Review Learnings Periodically**: Run `kodo learn review` to promote good learnings and discard noise
