# Blocker Handling Guide

How to handle blockers during plan execution.

---

## When to Stop and Report

### Immediate Stop Triggers

Stop execution immediately when:

- [ ] **Missing dependency** - Required file/function doesn't exist
- [ ] **Unclear instruction** - Don't understand what a step means
- [ ] **Unexpected failure** - Test fails for wrong reason
- [ ] **Plan gap** - Critical information missing
- [ ] **Two verification failures** - Same step failed twice

### DO NOT Continue When

- Guessing might work
- "Just one small fix" seems obvious
- Under time pressure
- Previous workaround "might" work

**The rule: When in doubt, STOP and ASK.**

---

## Blocker Report Template

Use this format when reporting blockers:

```markdown
## BLOCKED on Task [N], Step [M]

### What the plan says

[Quote exact instruction from plan]

### What I found

[Describe the actual situation]

### Why I'm blocked

[Specific reason for the blocker]

### Options

**A) [First option]**
- Pros: [advantages]
- Cons: [disadvantages]
- Effort: [Low/Medium/High]

**B) [Second option]**
- Pros: [advantages]
- Cons: [disadvantages]
- Effort: [Low/Medium/High]

**C) [Third option - often "Abort and revise plan"]**
- Pros: [advantages]
- Cons: [disadvantages]
- Effort: [Low/Medium/High]

### My recommendation

[Which option and why]

### What I need from you

[Specific decision or information needed]
```

---

## Common Blocker Types

### Missing Dependency

**Example:**
```markdown
## BLOCKED on Task 3, Step 2

### What the plan says

"Call `validate_config()` from the `config` module"

### What I found

The `config` module exists, but there is no `validate_config()` function.

### Why I'm blocked

The function the plan references doesn't exist. Either:
- It should have been created in an earlier task
- The plan has an error

### Options

**A) Create the function now**
- Pros: Unblocks immediately
- Cons: May not match plan's intent
- Effort: Medium

**B) Check if different function works**
- Looking at `config.rs`, there's `validate_path()` - might be what was meant
- Pros: Uses existing code
- Cons: May not be correct function
- Effort: Low

**C) Pause and clarify plan**
- Pros: Get correct answer
- Cons: Delays progress
- Effort: Low

### My recommendation

Option B - the naming suggests `validate_path()` is what was intended.

### What I need from you

Confirm `validate_path()` is correct, or specify what validation is needed.
```

### Unclear Instruction

**Example:**
```markdown
## BLOCKED on Task 5, Step 3

### What the plan says

"Add appropriate error handling"

### What I found

The code runs but has no error handling. I don't know what "appropriate" means here.

### Why I'm blocked

Need specific error handling strategy:
- What errors should be caught?
- Should they be logged, returned, or both?
- What error types to use?

### Options

**A) Use pattern from similar function**
- `process_file()` uses `Result<T, ProcessError>` with logging
- Pros: Consistent with codebase
- Cons: May not be right for this context
- Effort: Low

**B) Ask for specification**
- Get exact error handling requirements
- Pros: Definitely correct
- Cons: Delays progress
- Effort: Low

**C) Minimal error handling**
- Just propagate with `?`
- Pros: Simple, fast
- Cons: May need revision later
- Effort: Low

### My recommendation

Option A - consistency with existing patterns is usually right.

### What I need from you

Confirm using the `process_file()` error pattern is acceptable.
```

### Unexpected Test Failure

**Example:**
```markdown
## BLOCKED on Task 2, Step 4

### What the plan says

"Run test, expected: PASS"

### What I found

Test fails with different error than expected:

```
running 1 test
test config::tests::test_parse ... FAILED

failures:
    thread 'config::tests::test_parse' panicked at 'assertion failed:
    expected "value1", got "VALUE1"'
```

### Why I'm blocked

Plan expected test to pass, but there's a case sensitivity issue.
This might be:
- Bug in implementation
- Bug in test
- Bug in plan expectations

### Options

**A) Fix implementation (lowercase output)**
- Change `to_uppercase()` to `to_lowercase()`
- Pros: Test passes
- Cons: May change intended behavior
- Effort: Low

**B) Fix test (accept uppercase)**
- Change expected value to "VALUE1"
- Pros: Matches current behavior
- Cons: May mask real bug
- Effort: Low

**C) Investigate intent**
- Check what other similar functions do
- Pros: Correct solution
- Cons: Takes more time
- Effort: Medium

### My recommendation

Option C - the case sensitivity might be intentional somewhere.

### What I need from you

Should output be lowercase, uppercase, or preserve original case?
```

### Plan Gap

**Example:**
```markdown
## BLOCKED on Task 4, Step 1

### What the plan says

"Create file at `src/utils/helpers.rs`"

### What I found

The `src/utils/` directory doesn't exist, and `src/lib.rs` has no `mod utils` declaration.

### Why I'm blocked

Plan assumes directory structure exists but it doesn't. Need to:
1. Create `src/utils/` directory
2. Create `src/utils/mod.rs`
3. Add `mod utils;` to `src/lib.rs`
4. Then create the planned file

### Options

**A) Add missing setup steps**
- Create directory and module structure
- Pros: Unblocks immediately
- Cons: Adds unplanned work
- Effort: Low

**B) Use existing directory**
- Put file in `src/core/` instead
- Pros: No new structure needed
- Cons: May not match intended organization
- Effort: Low

**C) Revise plan to include setup**
- Add explicit setup task
- Pros: Plan becomes complete
- Cons: Delays execution
- Effort: Low

### My recommendation

Option A - this is clearly an oversight in the plan.

### What I need from you

Confirm I should create the utils module structure.
```

---

## Decision Options Format

Always provide structured options:

### Standard Options

| Option | When to suggest |
|--------|-----------------|
| **Fix it now** | Clear solution, low risk |
| **Use alternative** | Similar existing code works |
| **Get clarification** | Ambiguous requirements |
| **Skip and continue** | Non-blocking, can revisit |
| **Abort and revise** | Fundamental plan issue |

### Option Template

```markdown
**[Letter]) [Action]**
- Pros: [advantages]
- Cons: [disadvantages]
- Effort: Low | Medium | High
- Risk: Low | Medium | High
```

---

## Escalation Patterns

### When to Escalate to User

1. **First blocker** - Always report
2. **Architecture questions** - User decides
3. **Unclear requirements** - User clarifies
4. **Conflicting information** - User resolves

### When to Make Decision Yourself

1. **Obvious typos** - Fix and note
2. **Formatting issues** - Fix silently
3. **Import statements** - Add as needed
4. **Whitespace** - Follow project style

---

## Documentation Requirements

After blocker is resolved:

### Capture the Resolution

```bash
kodo reflect --signal "Blocker: [description] - Resolved by: [solution]"
```

### Update Plan if Needed

If blocker revealed plan gap:
1. Note the gap in plan file
2. Add missing information
3. Commit the update

### Continue Execution

After resolution:
1. Resume from blocked step
2. Complete remaining steps
3. Update TodoWrite progress
4. Continue to next task

---

## Quick Reference: Blocker Response Time

| Blocker Type | Max Time to Decide | Action |
|--------------|-------------------|--------|
| Missing file/function | 5 minutes | Report immediately |
| Unclear instruction | 2 minutes | Ask for clarification |
| Test failure | 10 minutes | Diagnose then report |
| Plan gap | 5 minutes | Propose fix |
| Environment issue | 15 minutes | Debug then report |

**If you exceed these times, you're likely going in circles. STOP and REPORT.**
