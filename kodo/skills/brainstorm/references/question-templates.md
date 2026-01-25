# Discovery Question Templates

Organized question templates for brainstorming sessions.

---

## Usage Guidelines

1. **Ask ONE question at a time** - Never multiple questions in one message
2. **Prefer multiple choice** - When possible, offer options A, B, C
3. **Follow the domain order** - Start with Problem, end with Testing
4. **Adapt to context** - Skip irrelevant sections

---

## Problem Domain Questions

### Understanding the Goal

**Multiple choice format:**
```
What's the primary goal here?

A) Build a new feature from scratch
B) Improve an existing feature
C) Fix a specific problem
D) Explore possibilities (not sure yet)
```

**Open format (when needed):**
- "What problem are we solving for the user?"
- "What does success look like when this is done?"
- "Why is this needed now?"

### Scope Definition

```
Should this be:

A) A minimal solution focused only on [core need]
B) A complete solution including [related features]
C) Something in between - let me describe the boundaries
```

**Follow-up if "C":**
- "What specific features are definitely in scope?"
- "What should we explicitly leave out for now?"

### User Context

```
Who is the primary user?

A) Developer using the CLI directly
B) Automated system (CI/CD, scripts)
C) Both equally
D) Someone else - let me describe
```

---

## Architecture Questions

### Integration Points

```
How should this integrate with existing code?

A) Standalone module with minimal dependencies
B) Extend an existing module ([module name])
C) New module that wraps/orchestrates existing code
D) Not sure - help me decide
```

### Data Flow

```
Where does the input data come from?

A) User input (CLI arguments, interactive prompts)
B) Files (config, data files)
C) External APIs/services
D) Database/storage
E) Multiple sources - let me specify
```

**Follow-up:**
```
Where should the output go?

A) Stdout/stderr
B) Files
C) External service
D) Database/storage
E) Multiple destinations
```

### Persistence

```
Does this need to persist state?

A) No - stateless operation
B) Yes - save to local files
C) Yes - save to database
D) Yes - needs both local and remote
```

**If persistence needed:**
- "What specifically needs to be saved?"
- "How long should data be retained?"
- "Who needs access to this data?"

### Concurrency

```
Will this run:

A) Sequentially (one operation at a time)
B) With concurrent operations (async/threads)
C) Both modes depending on use case
D) Not sure - depends on performance needs
```

---

## User Experience Questions

### Interface Design

```
What's the preferred interface?

A) CLI command with arguments
B) Interactive prompts
C) Configuration file
D) API for other code to call
E) Multiple interfaces
```

**For CLI:**
```
Should this command:

A) Run and exit (one-shot)
B) Watch/run continuously
C) Interactive session
D) Daemon/background process
```

### Feedback and Output

```
What feedback should users see?

A) Minimal - just success/failure
B) Progress updates during operation
C) Detailed logging for debugging
D) Structured output (JSON, etc.)
E) Combination based on verbosity flags
```

### Error Presentation

```
When errors occur, prefer:

A) Simple message for end users
B) Technical details for debugging
C) Actionable suggestions for fixing
D) All of the above, context-dependent
```

---

## Error Handling Questions

### Failure Modes

- "What should happen if [specific operation] fails?"
- "Should this retry automatically, or report and stop?"
- "Are partial results acceptable, or is it all-or-nothing?"

```
When this operation fails:

A) Stop immediately and report error
B) Retry [N] times then fail
C) Continue with partial results
D) Fall back to alternative approach
```

### Recovery Options

```
Should users be able to:

A) Resume from where it failed
B) Start fresh only
C) Choose at runtime
```

### Validation Strategy

```
Input validation approach:

A) Fail fast - validate everything upfront
B) Validate as we go
C) Lenient - fix/ignore minor issues
D) Strict with helpful error messages
```

---

## Performance Questions

### Scale Expectations

```
Expected data volume:

A) Small (< 100 items, < 1MB)
B) Medium (100-10K items, < 100MB)
C) Large (10K+ items, > 100MB)
D) Variable - should handle any size
```

### Speed Requirements

```
Performance priority:

A) Fast is critical (sub-second)
B) Reasonable speed (few seconds OK)
C) Speed doesn't matter (batch/background)
D) Depends on mode (interactive vs batch)
```

### Resource Constraints

- "Are there memory limits to consider?"
- "Should this work on limited hardware?"
- "Are there rate limits or quotas to respect?"

---

## Security Questions

### Data Sensitivity

```
Does this handle sensitive data?

A) No sensitive data
B) Yes - credentials/secrets
C) Yes - personal information
D) Yes - financial data
E) Multiple categories
```

**If sensitive:**
- "How should secrets be stored/passed?"
- "Should data be encrypted at rest?"
- "Are there compliance requirements?"

### Access Control

```
Who should be able to use this?

A) Anyone (public)
B) Authenticated users
C) Specific roles/permissions
D) Admin only
```

---

## Testing Questions

### Test Strategy

```
What testing is most important?

A) Unit tests for core logic
B) Integration tests for external interactions
C) End-to-end CLI tests
D) All of the above equally
```

### Test Data

```
For testing, we need:

A) Simple fixtures (hardcoded data)
B) Generated test data
C) Real data samples (sanitized)
D) Mock services/APIs
```

### Edge Cases

- "What's the weirdest valid input this might receive?"
- "What happens with empty input?"
- "What if the user cancels mid-operation?"

---

## Quick Reference: Question Types

### When to Use Multiple Choice

- Architectural decisions (limited valid options)
- Interface choices (A, B, or C approach)
- Priority ordering (what matters most)
- Yes/No with nuance (Yes, but...)

### When to Use Open Questions

- Understanding the problem (why, what)
- Discovering edge cases (what if)
- Clarifying vague requirements
- Exploring possibilities

### Question Ordering

1. **Problem domain** - Understand what we're solving
2. **Architecture** - How it fits in the system
3. **User experience** - How users interact
4. **Error handling** - What can go wrong
5. **Performance** - Speed and scale needs
6. **Security** - Protection requirements
7. **Testing** - Verification approach

---

## Kodo Integration

**Before brainstorming:**
```bash
kodo query "<topic>"           # Check existing context
kodo query "similar features"  # Find related patterns
```

**After design is formed:**
```bash
kodo reflect --signal "Decided: <decision> because <reason>"
kodo reflect --signal "Requirement: <key requirement>"
```
