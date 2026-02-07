---
name: explore
description: >
  Deep codebase exploration and pattern discovery.
  Use for understanding unfamiliar code and discovering architectural patterns.
---

# Exploring Codebases

## Overview

Systematic codebase exploration for understanding architecture, discovering patterns,
and building context. Surface scan with Glob, deep dive with Read, recognize patterns,
document findings. Matches the kodo-explorer agent capabilities.

**Core principle:** Understand before acting. Surface scan, then deep dive. Document discoveries.

**Announce at start:** "I'm using the explore skill to understand the codebase."

## When to Use

- Joining new project
- Before major refactoring
- Understanding unfamiliar modules
- Discovering patterns and conventions
- Preparing architectural changes
- Before making design decisions
- Investigating complex bugs

## The Exploration Process

### Phase 1: Surface Scan

**Start broad, identify structure:**

```bash
# 1. Check existing context
kodo query "architecture"
kodo query "patterns"
kodo learn list

# 2. Explore file structure
glob "**/*.rs"                          # All Rust files
glob "src/**/*"                         # Source structure
glob "tests/**/*"                       # Test organization

# 3. Identify key files
glob "**/main.rs"                       # Entry points
glob "**/mod.rs"                        # Module definitions
glob "**/lib.rs"                        # Library roots
```

**Document structure:**
- Entry points
- Module hierarchy
- Test organization
- Configuration files
- Documentation locations

### Phase 2: Deep Dive

**Read key files for understanding:**

```bash
# Read in order of importance
Read main.rs                            # Entry point
Read lib.rs                             # Public API
Read key module files
Read configuration
Read tests
```

**For each file:**
1. Understand purpose
2. Identify dependencies
3. Note patterns used
4. Find related files
5. Document findings

**Example sequence:**
```bash
# 1. Entry point
Read src/main.rs
# Notes: Uses clap for CLI, async runtime, loads config

# 2. Core module
Read src/core/mod.rs
# Notes: Exports 5 submodules, public API surface

# 3. Key component
Read src/core/context.rs
# Notes: Uses serde for serialization, tree structure

# 4. Tests
Read tests/core/context_test.rs
# Notes: Test fixtures in tests/fixtures/, uses testcontainers
```

### Phase 3: Pattern Recognition

**Identify recurring patterns:**

- **Architecture patterns:**
  - Layered architecture?
  - Hexagonal/ports-adapters?
  - Microservices?
  - Monolith?

- **Code patterns:**
  - Error handling approach
  - Async/sync usage
  - Dependency injection
  - State management

- **Testing patterns:**
  - Unit test style
  - Integration test setup
  - Mock/stub approach
  - Test fixtures

- **Naming conventions:**
  - File naming
  - Function naming
  - Variable naming
  - Module organization

### Phase 4: Document Findings

**Capture discoveries in context:**

```bash
# 1. Curate architecture findings
kodo curate add --category architecture --title "Layered architecture pattern"

# 2. Curate code patterns
kodo curate add --category code-style --title "Error handling uses Result<T, E>"

# 3. Curate test patterns
kodo curate add --category testing --title "Integration tests use testcontainers"

# 4. Reflect on exploration
kodo reflect --signal "Explored auth module, uses JWT pattern"
```

**Create exploration report:**

Save to `docs/exploration/<date>-<component>-exploration.md`:

```markdown
# Component Exploration Report

## Overview
[High-level description]

## Architecture
[Structure and organization]

## Key Components
[Important modules and their roles]

## Patterns Observed
[Recurring patterns and conventions]

## Dependencies
[External and internal dependencies]

## Testing Strategy
[How tests are organized and run]

## Questions/Gaps
[Unclear areas needing clarification]

## Recommendations
[Suggested improvements or changes]
```

## Integration with Kodo

**Before exploration:**
```bash
kodo query "<component>"                # Check existing context
kodo learn list --category architecture # Review known patterns
```

**During exploration:**
```bash
kodo reflect --signal "Pattern found: <pattern>"
kodo curate add --category <category>   # Document as you go
```

**After exploration:**
```bash
kodo reflect                            # Capture all discoveries
kodo extract docs/exploration/report.md # Extract learnings from report
kodo docs sync                          # Share with team (optional)
```

## Exploration Strategies

### Top-Down (Start with high-level)

1. Read main entry points
2. Understand module structure
3. Dive into specific modules
4. Read implementation details

**Use when:**
- New to codebase
- Understanding overall architecture
- Planning large changes

### Bottom-Up (Start with details)

1. Read specific components
2. Understand local patterns
3. Build up to larger structure
4. Connect to overall architecture

**Use when:**
- Fixing specific bugs
- Understanding specific features
- Investigating local issues

### Dependency-Driven (Follow imports)

1. Start with target file
2. Read imported modules
3. Follow dependency chain
4. Map dependency graph

**Use when:**
- Understanding data flow
- Tracking feature implementation
- Investigating bugs across modules

### Test-Driven (Start with tests)

1. Read test files first
2. Understand expected behavior
3. Read implementation
4. Validate understanding

**Use when:**
- Understanding feature requirements
- Preparing for refactoring
- Verifying behavior

## Tools for Exploration

### Glob Patterns

```bash
glob "**/*.rs"                          # All Rust files
glob "src/**/test*.rs"                  # All test files
glob "src/core/**/*"                    # Core module files
glob "**/mod.rs"                        # Module definitions
```

### Grep Patterns

```bash
grep "fn main"                          # Find entry points
grep "struct.*User"                     # Find User structs
grep "impl.*Error"                      # Find error implementations
grep "pub fn" --glob "src/**/*.rs"      # Public functions
```

### Read Strategy

```bash
# Read with limits for large files
Read <file> --limit 100                 # First 100 lines
Read <file> --offset 100 --limit 50     # Lines 100-150

# Read related files in parallel
Read src/main.rs
Read src/lib.rs
Read Cargo.toml
```

## Key Principles

- **Query before exploring** - Check existing context with `kodo query`
- **Surface scan first** - Use Glob to understand structure
- **Deep dive strategically** - Read key files, not everything
- **Recognize patterns** - Look for recurring approaches
- **Document discoveries** - Use `kodo curate` as you go
- **Reflect after exploring** - Capture learnings with `kodo reflect`

## Red Flags

**You're doing it wrong if:**
- Exploring without checking existing context first (`kodo query`)
- Reading files randomly without strategy
- Not documenting patterns as you discover them
- Exploring entire codebase (too broad, focus on relevant parts)
- Not capturing findings with `kodo curate` or `kodo reflect`
- Making changes while exploring (explore and act are separate phases)
- Not creating exploration report for complex codebases
