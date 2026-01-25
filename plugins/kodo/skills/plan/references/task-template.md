# Task Documentation Template

Template for documenting implementation tasks following TDD approach.

---

## Task Frontmatter

Every task document should begin with YAML frontmatter:

```yaml
---
title: Short descriptive title
feature: Parent feature this task belongs to
status: pending | in_progress | completed | blocked
priority: high | medium | low
complexity: trivial | simple | moderate | complex
estimated_minutes: 10  # Should be 2-15 minutes for proper granularity
dependencies:
  - task-id-1
  - task-id-2
github_issue: "#123"  # Optional
---
```

### Status Definitions

| Status | Meaning |
|--------|---------|
| `pending` | Not started, ready to be picked up |
| `in_progress` | Currently being worked on |
| `completed` | All steps done, tests pass, committed |
| `blocked` | Cannot proceed, needs clarification |

### Complexity Guidelines

| Complexity | Time | Description |
|------------|------|-------------|
| `trivial` | 2-3 min | Single file change, obvious implementation |
| `simple` | 3-5 min | One function with test, clear requirements |
| `moderate` | 5-10 min | Multiple functions, some edge cases |
| `complex` | 10-15 min | Module-level work, integration needed |

**If complexity exceeds 15 minutes, break into smaller tasks.**

---

## Task Document Structure

### 1. Objective (1-2 sentences)

State what this task accomplishes. Be specific.

```markdown
## Objective

Add validation for configuration file paths, ensuring paths exist and are readable before proceeding with initialization.
```

### 2. Acceptance Criteria

List specific, testable criteria for completion.

```markdown
## Acceptance Criteria

- [ ] Function `validate_config_path` exists in `src/config/validation.rs`
- [ ] Returns `Ok(PathBuf)` for valid readable file paths
- [ ] Returns `Err(ConfigError::NotFound)` for non-existent paths
- [ ] Returns `Err(ConfigError::NotReadable)` for permission-denied paths
- [ ] All tests pass with `cargo test validate_config`
```

### 3. Test Scaffolding (TDD)

**Always start with failing tests.** Use `#[ignore]` and `todo!()` for scaffolding.

```rust
// tests/config/validation_test.rs

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    #[test]
    #[ignore] // Remove when implementing
    fn test_validate_config_path_with_valid_file() {
        todo!("Implement: create temp file, validate path, assert Ok")
    }

    #[test]
    #[ignore]
    fn test_validate_config_path_with_nonexistent_file() {
        todo!("Implement: use non-existent path, assert NotFound error")
    }

    #[test]
    #[ignore]
    fn test_validate_config_path_with_directory() {
        todo!("Implement: use directory path, assert appropriate error")
    }
}
```

**Test scaffolding workflow:**

1. Write all test signatures with `#[ignore]` and `todo!()`
2. Remove `#[ignore]` from first test
3. Implement test body
4. Run test, verify it fails for the right reason
5. Implement minimal code to pass
6. Repeat for remaining tests

### 4. Files to Create/Modify

List exact file paths with line ranges for modifications.

```markdown
## Files

### Create

- `src/config/validation.rs` - New validation module
- `tests/config/validation_test.rs` - Test file

### Modify

- `src/config/mod.rs:15-20` - Add `mod validation; pub use validation::*;`
- `src/lib.rs:8` - Add `pub mod config;` if not present

### Dependencies

- `tempfile = "3.10"` - For test fixtures (add to `Cargo.toml [dev-dependencies]`)
```

### 5. Implementation Steps

Each step is ONE atomic action (2-5 minutes).

```markdown
## Implementation Steps

### Step 1: Create test file with scaffolds

Create `tests/config/validation_test.rs` with ignored tests.

**Run:** `cargo test --test validation_test 2>&1 | head -20`
**Expected:** "running 0 tests" (all ignored)

### Step 2: Enable first test

Remove `#[ignore]` from `test_validate_config_path_with_valid_file`.
Implement test body.

**Run:** `cargo test test_validate_config_path_with_valid_file`
**Expected:** FAIL with "cannot find function `validate_config_path`"

### Step 3: Create validation module

Create `src/config/validation.rs` with function signature.

```rust
use std::path::{Path, PathBuf};
use crate::error::ConfigError;

pub fn validate_config_path(path: &Path) -> Result<PathBuf, ConfigError> {
    todo!()
}
```

**Run:** `cargo test test_validate_config_path_with_valid_file`
**Expected:** FAIL with "not yet implemented"

### Step 4: Implement validation logic

Replace `todo!()` with actual implementation.

**Run:** `cargo test test_validate_config_path_with_valid_file`
**Expected:** PASS

### Step 5: Commit

```bash
git add src/config/validation.rs tests/config/validation_test.rs
git commit -m "feat(config): add path validation for config files"
```

### Step 6: Enable and implement remaining tests

Repeat Steps 2-5 for each remaining test.
```

### 6. Dependencies Section

Document inter-task dependencies explicitly.

```markdown
## Dependencies

### Requires (blocking)

- **task-002**: Error types must be defined first
- **task-001**: Config module structure must exist

### Enables (unblocks)

- **task-005**: CLI init command needs this validation
- **task-006**: Config loading depends on validated paths

### Can Parallel

- **task-003**: Logging module (no shared code)
- **task-004**: CLI arg parsing (independent)
```

---

## Complete Example

```markdown
---
title: Add config path validation
feature: Configuration Management
status: pending
priority: high
complexity: simple
estimated_minutes: 5
dependencies:
  - task-002-error-types
github_issue: "#42"
---

# Task: Add Config Path Validation

## Objective

Add validation for configuration file paths, ensuring paths exist and are readable before proceeding with initialization.

## Acceptance Criteria

- [ ] Function `validate_config_path` exists in `src/config/validation.rs`
- [ ] Returns `Ok(PathBuf)` for valid readable file paths
- [ ] Returns `Err(ConfigError::NotFound)` for non-existent paths
- [ ] Returns `Err(ConfigError::NotReadable)` for permission-denied paths
- [ ] All tests pass with `cargo test validate_config`

## Files

### Create
- `src/config/validation.rs`
- `tests/config/validation_test.rs`

### Modify
- `src/config/mod.rs:15` - Add module declaration

## Implementation Steps

### Step 1: Write failing test
[...]

### Step 2: Implement minimal code
[...]

### Step 3: Verify and commit
[...]

## Dependencies

### Requires
- task-002-error-types

### Enables
- task-005-cli-init
```

---

## Integration with Kodo

**Before creating task:**

```bash
kodo query "similar implementation"  # Check existing patterns
kodo query "error handling"          # Check error conventions
```

**After task completion:**

```bash
kodo reflect --signal "Pattern: validation functions return Result<T, E>"
kodo track link #42                  # Update linked GitHub issue
```

---

## Anti-Patterns

**Avoid these in task documentation:**

| Problem | Example | Fix |
|---------|---------|-----|
| Vague objectives | "Add validation" | "Add path validation returning specific error types" |
| Missing file paths | "in the config module" | "src/config/validation.rs:15-30" |
| Bundled steps | "Write tests and implement" | Separate into distinct steps |
| No success criteria | "Should work" | "Returns Ok(PathBuf) for valid paths" |
| Placeholder code | "// add logic here" | Full implementation snippet |
| No time estimate | Missing | "estimated_minutes: 5" |
