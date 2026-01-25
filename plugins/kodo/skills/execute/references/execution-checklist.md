# Execution Checklist

Comprehensive checklist for executing implementation plans.

---

## Pre-Execution Validation

Complete before starting any task execution.

### Plan Readiness

- [ ] **Plan file exists and is readable**
  ```bash
  cat docs/plans/<plan-file>.md
  ```

- [ ] **All tasks have required elements:**
  - [ ] Exact file paths (not "in the config folder")
  - [ ] Complete code snippets (not "add logic here")
  - [ ] Expected test output
  - [ ] Commit instructions

- [ ] **Dependencies are clear:**
  - [ ] Blocking tasks identified
  - [ ] Parallel tasks marked
  - [ ] Order makes sense

- [ ] **Questions resolved:**
  - [ ] No TODOs or placeholders in plan
  - [ ] All unclear items clarified with user
  - [ ] Technical decisions documented

### Environment Readiness

- [ ] **Clean working directory**
  ```bash
  git status  # Should show clean or only plan file
  ```

- [ ] **All tests passing**
  ```bash
  cargo test  # No pre-existing failures
  ```

- [ ] **Dependencies installed**
  ```bash
  cargo build  # Should compile
  ```

- [ ] **Correct branch**
  ```bash
  git branch --show-current  # Should be feature branch or main
  ```

### Context Loaded

- [ ] **Check relevant patterns**
  ```bash
  kodo query "<feature topic>"
  kodo query "similar implementation"
  ```

- [ ] **Review related code**
  - [ ] Similar modules examined
  - [ ] Conventions understood
  - [ ] Import patterns noted

---

## Per-Task Checklist

Complete for EACH task in the batch.

### Before Starting Task

- [ ] **Mark task in progress**
  - Update TodoWrite status to `in_progress`

- [ ] **Read full task description**
  - [ ] Understand the objective
  - [ ] Note all files involved
  - [ ] Review expected behavior

- [ ] **Verify dependencies complete**
  - [ ] Blocking tasks are done
  - [ ] Required files exist
  - [ ] Required functions available

### During Task Execution

- [ ] **Follow steps EXACTLY as written**
  - Don't improvise
  - Don't skip steps
  - Don't combine steps

- [ ] **For each test step:**
  - [ ] Write test exactly as specified
  - [ ] Run test command exactly as specified
  - [ ] Verify output matches expectation

- [ ] **For each implementation step:**
  - [ ] Use exact code from plan
  - [ ] Place in exact file location
  - [ ] Maintain existing code style

### After Completing Task

- [ ] **Run verification**
  ```bash
  cargo test <specific_test>  # Task-specific test
  cargo check                  # Compilation check
  ```

- [ ] **Commit if specified**
  ```bash
  git add <specified files>
  git commit -m "<specified message>"
  ```

- [ ] **Update progress**
  - Mark task as `completed` in TodoWrite
  - Note any learnings for later

---

## Verification Steps

### After Each Task

| Check | Command | Expected |
|-------|---------|----------|
| Test passes | `cargo test <test_name>` | All pass |
| Compiles | `cargo check` | No errors |
| No warnings | `cargo clippy` | Clean or acceptable |
| Formatting | `cargo fmt --check` | No diff |

### After Each Batch (3 tasks)

- [ ] **All batch tests pass**
  ```bash
  cargo test
  ```

- [ ] **No regressions**
  - All previously passing tests still pass

- [ ] **Commits are clean**
  ```bash
  git log --oneline -5  # Review recent commits
  ```

- [ ] **Report to user**
  ```
  Completed tasks X-Y:
  - Task X: [summary] - PASS
  - Task Y: [summary] - PASS
  - Task Z: [summary] - PASS

  Verification:
  [Test output summary]

  Ready for feedback before continuing.
  ```

- [ ] **Wait for user response**
  - Do NOT continue without acknowledgment

### After All Tasks Complete

- [ ] **Full test suite**
  ```bash
  cargo test
  ```

- [ ] **Full lint check**
  ```bash
  cargo clippy -- -W clippy::all
  ```

- [ ] **Format check**
  ```bash
  cargo fmt --check
  ```

- [ ] **All commits present**
  ```bash
  git log --oneline <start-sha>..HEAD
  ```

---

## Progress Reporting Format

### During Batch

```markdown
## Task X: [Title]

Status: IN PROGRESS

Step 1: [description] - DONE
Step 2: [description] - DONE
Step 3: [description] - IN PROGRESS
```

### After Batch

```markdown
## Batch N Complete

### Tasks Completed

| Task | Title | Status | Notes |
|------|-------|--------|-------|
| 1 | Add config struct | PASS | - |
| 2 | Implement parser | PASS | - |
| 3 | Add validation | PASS | Used existing pattern from X |

### Verification Output

```
running 5 tests
test config::tests::test_parse ... ok
test config::tests::test_validate ... ok
...
test result: ok. 5 passed; 0 failed
```

### Commits

```
abc1234 feat: add config struct
def5678 feat: implement config parser
ghi9012 feat: add config validation
```

### Next Batch

Tasks 4-6 ready. Continue?
```

---

## Completion Criteria

### Task Complete When

- [ ] All steps executed exactly as specified
- [ ] All verifications pass
- [ ] Commit made (if specified)
- [ ] TodoWrite updated

### Batch Complete When

- [ ] All tasks in batch complete
- [ ] No test regressions
- [ ] User acknowledged progress

### Plan Complete When

- [ ] All tasks complete
- [ ] Full test suite passes
- [ ] All commits clean
- [ ] User acknowledges completion
- [ ] Learnings captured

---

## Quick Reference: Batch Sizes

| Context | Batch Size | Checkpoint |
|---------|------------|------------|
| Default | 3 tasks | After each batch |
| Complex tasks | 1-2 tasks | After each task |
| Simple tasks | 3-5 tasks | After each batch |
| User requests | As specified | As specified |

---

## Kodo Integration

**During execution:**
```bash
kodo reflect --signal "Pattern that worked: <description>"
kodo query "<topic>"  # When stuck on implementation
```

**After completion:**
```bash
kodo reflect                  # Capture session learnings
kodo track link #123          # Update GitHub issue
```
