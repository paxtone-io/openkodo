---
name: test
description: >
  Intelligent test runner - find affected tests, run coverage analysis.
  Use to run the RIGHT tests, not ALL tests. Analyze changes to target testing.
---

# Running Targeted Tests

## Overview

Smart test execution based on code changes. Analyze git diff to find affected
test paths, run only impacted tests, and verify coverage. Faster feedback loops
by avoiding unnecessary test runs.

**Core principle:** Run the RIGHT tests, not ALL tests. Time is valuable.

**Announce at start:** "I'm using the test skill to run targeted tests."

## When to Use

- After making code changes
- Before committing
- During TDD cycles
- After refactoring
- When CI is slow (identify specific tests)
- Debugging test failures

## CLI Commands

### Cargo Test Commands

```bash
cargo test                              # Run all tests
cargo test specific_test                # Run specific test
cargo test module::                     # Run module tests
cargo test -- --nocapture               # Show println! output
cargo test -- --ignored                 # Run ignored tests
cargo test -- --test-threads=1          # Run serially
```

### Targeted Testing

```bash
kodo test                               # Auto-detect affected tests
kodo test --file src/auth/mod.rs       # Tests for specific file
kodo test --changed                     # Tests for git diff
kodo test --module auth                 # All auth module tests
kodo test --verbose                     # Show test selection reasoning
```

### Coverage Analysis

```bash
kodo test coverage                      # Overall coverage
kodo test coverage --file src/auth.rs  # File-specific coverage
kodo test coverage --report            # Generate HTML report
kodo test coverage --threshold 80      # Enforce minimum coverage
```

### Test Discovery

```bash
kodo test list                          # List all tests
kodo test list --module auth            # List tests in module
kodo test find "authentication"         # Find tests by name
kodo test affected                      # Show affected tests (don't run)
```

## Integration with Kodo

**TDD workflow:**

```bash
# 1. Write failing test
kodo test specific_test -- --nocapture

# 2. Implement
# ... write code ...

# 3. Run test
kodo test specific_test

# 4. Capture learning
kodo reflect --signal "Test pattern: <pattern>"

# 5. Run affected tests
kodo test --changed
```

**Before commit:**

```bash
kodo test --changed                     # Run affected tests
kodo test coverage --threshold 80       # Verify coverage
kodo reflect                            # Capture learnings
git commit -m "feat: add feature"
```

**Check existing patterns:**

```bash
kodo query "testing patterns"           # Before writing tests
kodo query "test fixtures"              # Check setup patterns
```

## The Process

### Finding Affected Tests

**Automatic detection:**
```bash
kodo test --changed
```

Analysis steps:
1. Run `git diff` to find modified files
2. Parse imports and dependencies
3. Find test files that import modified modules
4. Identify test functions that call modified code
5. Run only affected tests

**Manual specification:**
```bash
kodo test --file src/auth/token.rs
# Runs: tests/auth/token_test.rs, tests/integration/auth_test.rs
```

### TDD Cycle

**Red phase (failing test):**
```bash
cargo test new_feature_test -- --nocapture
# Expected: FAIL with "cannot find function"
```

**Green phase (minimal implementation):**
```bash
cargo test new_feature_test
# Expected: PASS
```

**Refactor phase:**
```bash
kodo test --module <module>             # Run all module tests
kodo test coverage --module <module>    # Check coverage maintained
```

### Coverage Workflow

**Check current coverage:**
```bash
kodo test coverage
# Shows: 78% overall, identifies gaps
```

**Add tests for gaps:**
```bash
kodo test coverage --gaps               # Show uncovered code
# Write tests for uncovered paths
kodo test coverage --threshold 80       # Verify improvement
```

**Maintain coverage:**
```bash
# Before committing
kodo test coverage --changed            # Coverage of changed code
kodo test coverage --threshold 80       # Enforce minimum
```

### Debugging Test Failures

**Single test with output:**
```bash
cargo test failing_test -- --nocapture
```

**Related tests:**
```bash
kodo test --module <module>             # Run all related tests
kodo test find "similar"                # Find similar tests
```

**Check patterns:**
```bash
kodo query "test failures"              # Past failure patterns
kodo query "debugging tests"            # Debugging techniques
```

## Test Organization

### Test Types

**Unit tests** (in src/ files):
```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_specific_function() {
        assert_eq!(function(input), expected);
    }
}
```

**Integration tests** (in tests/ directory):
```rust
// tests/integration/auth_test.rs
#[test]
fn test_full_auth_flow() {
    // Test complete auth workflow
}
```

**Ignored tests** (slow or flaky):
```rust
#[test]
#[ignore]
fn expensive_test() {
    // Only run with: cargo test -- --ignored
}
```

### Running Strategies

**Fast feedback:**
```bash
kodo test --changed                     # Only affected (fastest)
```

**Module verification:**
```bash
kodo test --module auth                 # Specific module
```

**Full validation:**
```bash
cargo test                              # All tests (slowest)
```

**Pre-CI check:**
```bash
kodo test --changed && cargo test       # Fast then full
```

## Key Principles

- **Target tests** - Run affected tests first, full suite before push
- **Fast feedback** - Prioritize speed in TDD cycles
- **Maintain coverage** - Check coverage on changed code
- **Test first** - Write failing test before implementation
- **Capture patterns** - Use `kodo reflect` after discovering test patterns

## Red Flags

**You're doing it wrong if:**
- Always running full test suite (slow feedback)
- Skipping `kodo test --changed` before commit
- Writing tests after implementation (not TDD)
- Ignoring coverage gaps
- Not using `--nocapture` when debugging
- Running tests without understanding which are affected
- Forgetting to capture test patterns with `kodo reflect`
