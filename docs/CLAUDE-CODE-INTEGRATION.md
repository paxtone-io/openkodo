# Claude Code Integration

Comprehensive guide to using OpenKodo within Claude Code via plugins, slash commands, agents, and hooks.

## Table of Contents

- [Setup](#setup)
- [Plugin Ecosystem](#plugin-ecosystem)
- [Slash Commands Reference](#slash-commands-reference)
- [Agents Reference](#agents-reference)
- [Hook System](#hook-system)
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

| Agent | Model | Role |
|-------|-------|------|
| `kodo-explorer` | sonnet | Fast codebase exploration and file discovery |
| `kodo-architect` | opus | Architecture design and system-level decisions |
| `kodo-feature` | sonnet | Feature implementation with test-driven approach |
| `kodo-reviewer` | sonnet | Code review with confidence-based issue filtering |
| `kodo-debugger` | sonnet | Systematic bug investigation and root cause analysis |
| `kodo-refactor` | sonnet | Safe code restructuring with test verification |
| `kodo-tester` | haiku | Test scaffolding and test file generation |
| `kodo-planner` | sonnet | Implementation planning with dependency mapping |
| `kodo-curator` | opus | Learning curation, dedup, and quality scoring |
| `kodo-sentinel` | sonnet | Security review, vulnerability detection, OWASP checks |
| `kodo-optimizer` | sonnet | Performance profiling and optimization recommendations |
| `kodo-documenter` | haiku | Documentation generation and sync |

### Analyzer Agents (kodo-analyzer plugin)

| Agent | Model | Role |
|-------|-------|------|
| `kodo-codebase-analyzer` | sonnet | Main orchestrator, spawns specialized sub-agents |
| `kodo-database-analyzer` | haiku | Schema analysis, RLS, indexes |
| `kodo-api-analyzer` | haiku | Endpoint coverage, auth, error handling |
| `kodo-frontend-analyzer` | haiku | Component a11y, state management |
| `kodo-dependencies-analyzer` | haiku | Outdated packages, vulnerabilities |
| `kodo-posthog-analyzer` | haiku | Event coverage, feature flag completeness |
| `kodo-documentation-analyzer` | haiku | Doc coverage, accuracy, staleness |
| `kodo-security-analyzer` | sonnet | Vulnerabilities, auth, secrets, CVSS |
| `kodo-performance-analyzer` | sonnet | Query bottlenecks, bundle size, caching |

### Design Agents (kodo-design plugin)

| Agent | Model | Role |
|-------|-------|------|
| `kodo-design-agent` | sonnet | UI component design with Design Bible principles |
| `kodo-a11y-auditor` | sonnet | WCAG accessibility auditing |

### PostHog Agents (kodo-posthog plugin)

| Agent | Model | Role |
|-------|-------|------|
| `kodo-ph-analyst` | sonnet | Product insights from PostHog data |
| `kodo-ph-experiment-agent` | sonnet | A/B experiment design and statistical analysis |
| `kodo-ph-sync-agent` | haiku | PostHog-Notion configuration sync |

### Supabase Agents (kodo-supabase plugin)

| Agent | Model | Role |
|-------|-------|------|
| `kodo-supa-architect` | sonnet | Architecture decisions for Supabase features |
| `kodo-supa-edge-agent` | sonnet | Edge Function implementation |
| `kodo-supa-migrator` | sonnet | Database migration and schema management |

### Model Strategy

| Model | Cost | Use For |
|-------|------|---------|
| **haiku** | Low | File scaffolding, boilerplate, test generation, simple sync tasks |
| **sonnet** | Medium | Core implementation, analysis, debugging, feature work |
| **opus** | High | Complex architecture decisions, learning curation, ambiguous specs |

---

## Hook System

Hooks fire automatically during Claude Code sessions to keep your context fresh and capture learnings.

### Plugin Hooks (installed via `kodo hooks install`)

| Event | Action | Description |
|-------|--------|-------------|
| **SessionStart** | `kodo context load --quiet` | Load recent context and active learnings at session start |
| **PreCompact** | `kodo reflect --hook precompact --quiet` | Capture learnings before context is compacted |
| **Stop** | `kodo reflect --hook stop --quiet` | Capture learnings when Claude stops responding |
| **SessionEnd** | Prompt reminder | Reminds you to run `kodo reflect` |

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
- **Search Before Asking**: Use `/kodo-query` to check if knowledge already exists before asking questions
- **Combine CLI and Slash Commands**: Use `kodo analyze` in terminal and `/kodo-brainstorm` in Claude Code - they share the same `.kodo/` knowledge base
- **Review Learnings Periodically**: Run `kodo learn review` to promote good learnings and discard noise
