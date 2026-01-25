# Planning Session Checklist

Comprehensive checklist for creating implementation plans.

---

## Pre-Planning Phase

Complete before writing any tasks.

### 1. Gather Context

- [ ] **Run context query**
  ```bash
  kodo query "<feature topic>"
  kodo query "similar features"
  kodo query "testing patterns"
  ```

- [ ] **Review existing code**
  - Check for similar implementations
  - Identify reusable patterns
  - Note established conventions

- [ ] **Check project state**
  ```bash
  git status                    # Clean working directory?
  git log --oneline -5          # Recent changes
  cargo check                   # Codebase compiles?
  cargo test                    # Tests passing?
  ```

- [ ] **Review related documentation**
  - Architecture docs in `docs/`
  - Previous plans in `docs/plans/`
  - Design documents if applicable

### 2. Requirements Extraction

- [ ] **Clarify the goal**
  - What specific problem does this solve?
  - What does "done" look like?
  - Who is the user/consumer of this feature?

- [ ] **Identify inputs and outputs**
  - What data comes in?
  - What data goes out?
  - What side effects occur?

- [ ] **Define boundaries**
  - What is explicitly OUT of scope?
  - What are we NOT building?

- [ ] **List constraints**
  - Performance requirements?
  - Compatibility requirements?
  - Security considerations?

### 3. Discovery Questions

Ask these questions before planning. One at a time.

#### Functional Requirements

- "What is the primary use case for this feature?"
- "What happens when [edge case]?"
- "Should this integrate with [existing feature]?"
- "What error conditions need handling?"

#### Technical Constraints

- "What existing modules does this interact with?"
- "Are there performance requirements?"
- "What dependencies are acceptable?"
- "Should this be async or sync?"

#### Testing Requirements

- "What are the critical paths to test?"
- "Are there integration test requirements?"
- "What fixtures/test data are needed?"
- "Should this work offline?"

#### User Experience

- "What feedback should users receive?"
- "How are errors communicated?"
- "What's the CLI interface (if applicable)?"

---

## Planning Phase

### 4. Architecture Decision

- [ ] **Propose 2-3 approaches** with trade-offs
- [ ] **Recommend one** with clear reasoning
- [ ] **Get approval** before proceeding
- [ ] **Document decision** for future reference

### 5. Task Breakdown Validation

For each task, verify:

- [ ] **Single responsibility** - One thing only
- [ ] **Testable** - Can write a test for it
- [ ] **Time-boxed** - 2-5 minutes to complete
- [ ] **Dependencies clear** - Know what must come first
- [ ] **Complete code** - No placeholders like "add logic here"

### 6. Task Breakdown Formula

| Feature Size | Number of Tasks | Time Estimate |
|--------------|-----------------|---------------|
| Trivial | 1-3 tasks | 15-30 min |
| Small | 4-8 tasks | 1-2 hours |
| Medium | 8-15 tasks | 2-4 hours |
| Large | 15-30 tasks | 4-8 hours (consider splitting) |

**If > 30 tasks, split into multiple features/plans.**

### 7. Dependency Ordering

- [ ] **Create dependency graph** (even if mental)
- [ ] **Identify parallel tracks** - Tasks that can run simultaneously
- [ ] **Mark blocking tasks** - Must complete before others start
- [ ] **Order by dependency** - Earlier tasks enable later ones

```
Task 1: Error types (blocking)
    ├── Task 2: Validation module
    ├── Task 3: Parser module
    │       └── Task 5: Parser tests
    └── Task 4: CLI integration
            └── Task 6: Integration tests
```

---

## Post-Planning Phase

### 8. Plan Document Checklist

Before saving, verify the plan includes:

- [ ] **Header with goal** - One sentence summary
- [ ] **Architecture overview** - 2-3 sentences
- [ ] **Tech stack** - Key technologies/libraries
- [ ] **GitHub issue link** - Or note to create one
- [ ] **All tasks documented** with:
  - Exact file paths
  - Complete code snippets
  - Test expectations
  - Commit instructions
- [ ] **Dependency order** - Which tasks block others
- [ ] **Parallel opportunities** - Tasks that can run concurrently
- [ ] **Risk flags** - Complex or uncertain areas marked

### 9. Plan Validation

Ask yourself:

- [ ] Could someone with zero context execute this?
- [ ] Are all file paths absolute and unambiguous?
- [ ] Is all code copy-paste ready?
- [ ] Does every task start with a failing test?
- [ ] Are commit checkpoints defined?

### 10. Handoff Preparation

- [ ] **Save plan** to `docs/plans/YYYY-MM-DD-<feature-name>.md`
- [ ] **Commit plan** document
- [ ] **Create/link GitHub issue**
  ```bash
  kodo track issue "Implement <feature>"
  # or
  kodo track link #123
  ```
- [ ] **Offer execution choice**

---

## Quick Reference: Planning Patterns

### Good Task Examples

```
Task: Add validate_path function
Files: src/config/validation.rs (create)
Steps:
  1. Write failing test for valid path
  2. Run test, verify fail
  3. Implement function
  4. Run test, verify pass
  5. Commit
```

### Bad Task Examples

```
Task: Implement validation
Files: somewhere in config
Steps:
  1. Add validation logic and tests
  2. Make sure it works
```

### Good vs Bad File References

| Bad | Good |
|-----|------|
| "in the config module" | `src/config/validation.rs:15-30` |
| "tests folder" | `tests/config/validation_test.rs` |
| "where the other functions are" | `src/cli/commands.rs:42` |

### Good vs Bad Code Snippets

| Bad | Good |
|-----|------|
| `// add validation logic` | Full function implementation |
| `todo!()` in final code | Actual working code |
| "similar to existing function" | Complete copy-paste ready code |

---

## Red Flags Checklist

Stop and reconsider if:

- [ ] Any task takes > 5 minutes
- [ ] Any step says "implement" without code
- [ ] File paths are relative or vague
- [ ] Tests come after implementation
- [ ] No commit checkpoints
- [ ] Skipped `kodo query` for context
- [ ] More than 30 tasks in single plan
- [ ] Dependencies unclear or circular
- [ ] Risk areas not flagged
