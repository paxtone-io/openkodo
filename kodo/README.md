# Kodo Base Plugin

Core agents and skills for AI-assisted development workflows. The Kodo plugin provides a comprehensive toolkit for planning, implementation, debugging, and code review with built-in self-learning capabilities.

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| kodo-explorer | sonnet | Deep codebase analysis, architecture mapping, pattern discovery, and implementation tracing |
| kodo-architect | sonnet | Architecture design, feature planning, database schema design, and integration planning |
| kodo-feature | sonnet | Full-lifecycle feature implementation from planning through testing to code review |
| kodo-reviewer | sonnet | Code review with confidence-based filtering, security analysis, and quality assessment |
| kodo-planner | sonnet | Requirements analysis, task breakdown, discovery questions, and user story development |
| kodo-debugger | sonnet | Systematic debugging workflow, root cause analysis, and error diagnosis |
| kodo-refactor | sonnet | Safe code refactoring, module extraction, symbol renaming, and code organization |
| kodo-tester | haiku | Test scaffolding, coverage analysis, and Rust testing best practices |

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| plan | `/kodo plan` | TDD-based implementation planning with bite-sized tasks |
| debug | `/kodo debug` | 4-phase systematic debugging workflow |
| brainstorm | `/kodo brainstorm` | Ideas to designs through structured discovery dialogue |
| execute | `/kodo execute` | Execute implementation plans with batch checkpoints |
| review | `/kodo review` | Code review with ≥80% confidence filtering for signal quality |

## Reference Documentation

Quick access to templates, checklists, and patterns for consistent workflows:

### Planning & Design
- [Task Template](skills/plan/references/task-template.md) - Task documentation with TDD scaffolding
- [Planning Checklist](skills/plan/references/planning-checklist.md) - Pre-implementation planning requirements
- [Question Templates](skills/brainstorm/references/question-templates.md) - Discovery questions organized by domain
- [Design Document Template](skills/brainstorm/references/design-document-template.md) - Design output format and structure

### Implementation & Execution
- [Execution Checklist](skills/execute/references/execution-checklist.md) - Batch execution workflow and checkpoints
- [Blocker Handling](skills/execute/references/blocker-handling.md) - Strategies for handling implementation blockers

### Debugging
- [Debugging Patterns](skills/debug/references/debugging-patterns.md) - Rust-specific debugging techniques and patterns
- [Root Cause Categories](skills/debug/references/root-cause-categories.md) - Systematic categorization for diagnosis

### Review
- [Review Checklist](skills/review/references/review-checklist.md) - Comprehensive code review checklist
- [Confidence Guide](skills/review/references/confidence-guide.md) - Calibrating confidence levels for issue severity

## Getting Started

### Use a Skill
Run any of the five skills to begin a structured workflow:
```bash
/kodo plan              # Create an implementation plan
/kodo debug             # Debug an issue systematically
/kodo brainstorm       # Develop designs through dialogue
/kodo execute          # Execute a plan with checkpoints
/kodo review           # Review code with confidence filtering
```

### Spawn an Agent
Agents are useful for focused, specialized work:
- **kodo-explorer** - Understand existing code before making changes
- **kodo-architect** - Design complex features or refactorings
- **kodo-feature** - Implement features end-to-end
- **kodo-planner** - Break down requirements into tasks
- **kodo-debugger** - Diagnose tricky bugs
- **kodo-refactor** - Restructure code safely
- **kodo-tester** - Improve test coverage
- **kodo-reviewer** - Get a fresh review before submitting

### Self-Learning Integration
The Kodo plugin integrates with OpenKodo's self-learning system:
```bash
kodo reflect           # Capture learnings from this session
kodo curate add        # Add context entries
kodo query <search>    # Search accumulated context
```

## Architecture

The Kodo plugin provides a unified interface for development workflows while maintaining separation of concerns:

- **Agents**: Specialized workers optimized for specific tasks
- **Skills**: Interactive workflows that guide users through structured processes
- **References**: Templates, checklists, and pattern documentation
- **Integration**: Seamless integration with OpenKodo's context and learning systems
