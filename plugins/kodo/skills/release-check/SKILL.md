---
name: release-check
description: >
  Validate pre-release checklist before publishing a new version.
  Checks version bumps, plugin sync, CI status, and changelog completeness.
disable-model-invocation: true
---

# Release Validation Checklist

## Overview

Systematically validate that all pre-release requirements are met before
triggering a release. Catches common release issues early.

**Core principle:** Never release without passing all checks.

**Announce at start:** "I'm using the release-check skill to validate release readiness."

## When to Use

- Before running `cargo release`
- Before creating a release tag
- Before triggering the release CI pipeline
- When preparing a version bump

## The Checklist

### Step 1: Version Consistency

```bash
# Check Cargo.toml version
grep '^version' Cargo.toml

# Check plugin versions match
grep '"version"' plugins/kodo/plugin.json
grep '"version"' plugins/kodo-analyzer/.claude-plugin/plugin.json 2>/dev/null
grep '"version"' plugins/kodo-design/.claude-plugin/plugin.json 2>/dev/null

# Check if versions are in sync
scripts/sync-plugin-versions.sh --check 2>/dev/null || echo "Run: scripts/sync-plugin-versions.sh"
```

**Pass criteria:** All versions match Cargo.toml version.

### Step 2: Code Quality

```bash
# Format check
cargo fmt --check

# Lint check
cargo clippy -- -D warnings

# Test suite
cargo test

# Security audit
cargo audit
```

**Pass criteria:** All commands exit 0.

### Step 3: Git State

```bash
# Check for uncommitted changes
git status --porcelain

# Check branch is up to date with remote
git fetch origin main
git log HEAD..origin/main --oneline

# Check we're on main or a release branch
git branch --show-current
```

**Pass criteria:** Clean working tree, up to date with remote, on main branch.

### Step 4: Documentation

```bash
# Check README version references
grep -n "version" README.md | head -5

# Check changelog/release notes exist
ls CHANGELOG.md RELEASE_NOTES.md 2>/dev/null

# Check public-repo submodule is current
git submodule status public-repo
```

**Pass criteria:** Documentation reflects new version.

### Step 5: Build Verification

```bash
# Build release binary
cargo build --release

# Verify binary runs
./target/release/kodo --version

# Run pre-release check script
scripts/pre-release-check.sh
```

**Pass criteria:** Release binary builds and runs correctly.

## Output Format

```markdown
## Release Check: v{version}

| Check | Status | Details |
|-------|--------|---------|
| Version sync | PASS/FAIL | [details] |
| Format | PASS/FAIL | [details] |
| Clippy | PASS/FAIL | [details] |
| Tests | PASS/FAIL | [details] |
| Security | PASS/FAIL | [details] |
| Git state | PASS/FAIL | [details] |
| Documentation | PASS/FAIL | [details] |
| Build | PASS/FAIL | [details] |

**Overall: READY / NOT READY**

### Issues to Fix
- [Issue 1]: [how to fix]
```

## After All Checks Pass

Offer the release command:

```bash
cargo release patch  # or minor/major
```

## Integration with Kodo

**Capture release context:**
```bash
kodo reflect --signal "Released v{version} with: {summary of changes}"
```

## Key Principles

- **All checks must pass** - No exceptions, no "we'll fix it later"
- **Automated where possible** - Run scripts, don't trust memory
- **Version consistency** - All version references must match
- **Clean state** - No uncommitted changes, no behind remote
