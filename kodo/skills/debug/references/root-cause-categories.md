# Root Cause Categories

Systematic categorization of bug root causes for faster diagnosis.

---

## Category Overview

| Category | % of Bugs | Diagnostic Focus |
|----------|-----------|------------------|
| Logic Errors | 35% | Trace data flow, check conditionals |
| Data Issues | 25% | Validate inputs, check transformations |
| Concurrency | 15% | Race conditions, deadlocks, ordering |
| External Dependencies | 10% | API changes, network, file system |
| Environment/Config | 10% | Settings, paths, credentials |
| Memory/Resources | 5% | Leaks, exhaustion, limits |

---

## Logic Errors

### Off-by-One Errors

**Symptoms:**
- First or last item skipped
- Array index out of bounds
- Loop runs one too many/few times

**Diagnostic:**
```rust
// Check boundary conditions
for i in 0..len {        // 0 to len-1
for i in 0..=len {       // 0 to len (inclusive)
for i in 1..len {        // 1 to len-1

// Check slice operations
&data[0..len]            // First len elements
&data[1..]               // Skip first element
&data[..data.len()-1]    // Skip last element
```

**Questions to ask:**
- Is the range inclusive or exclusive?
- What happens with empty input?
- What happens with single-element input?

### Conditional Logic Errors

**Symptoms:**
- Wrong branch taken
- Condition never true/always true
- Short-circuit evaluation issues

**Diagnostic:**
```rust
// Check operator precedence
if a && b || c           // (a && b) || c
if a && (b || c)         // Different!

// Check negation
if !a && !b              // Neither a nor b
if !(a && b)             // Not both (DeMorgan)
if !(a || b)             // Neither (DeMorgan)

// Check boundary comparisons
if x > 0                 // Excludes 0
if x >= 0                // Includes 0
```

### State Machine Errors

**Symptoms:**
- Invalid state transitions
- Missing state handling
- State corruption

**Diagnostic:**
```rust
// Enumerate all states
#[derive(Debug, PartialEq)]
enum State {
    Initial,
    Processing,
    Complete,
    Error,
}

// Add exhaustive match
match state {
    State::Initial => { /* ... */ }
    State::Processing => { /* ... */ }
    State::Complete => { /* ... */ }
    State::Error => { /* ... */ }
}  // Compiler catches missing variants
```

---

## Data Issues

### Invalid Input

**Symptoms:**
- Parse failures
- Unexpected None/null values
- Type conversion errors

**Diagnostic checklist:**
- [ ] Is input validated at entry point?
- [ ] Are optional fields handled?
- [ ] Are empty strings checked?
- [ ] Are numeric ranges validated?

```rust
// Trace input from source
fn process(input: &str) -> Result<Output, Error> {
    // Log input for debugging
    tracing::debug!(input = %input, "Processing input");

    // Validate early
    if input.is_empty() {
        return Err(Error::EmptyInput);
    }

    // Parse with context
    let parsed = input.parse::<i32>()
        .map_err(|e| Error::ParseFailed { input: input.to_string(), cause: e })?;

    // Validate ranges
    if parsed < 0 || parsed > 100 {
        return Err(Error::OutOfRange { value: parsed, min: 0, max: 100 });
    }

    // Continue processing...
}
```

### Data Transformation Errors

**Symptoms:**
- Incorrect output values
- Lost precision
- Encoding issues

**Diagnostic:**
```rust
// Add intermediate logging
let step1 = transform_a(input);
tracing::debug!(?step1, "After transform_a");

let step2 = transform_b(step1);
tracing::debug!(?step2, "After transform_b");

let result = transform_c(step2);
tracing::debug!(?result, "Final result");
```

### Serialization/Deserialization Errors

**Common issues:**

| Issue | Symptom | Fix |
|-------|---------|-----|
| Missing field | Deserialization fails | Add `#[serde(default)]` |
| Renamed field | Field not found | Add `#[serde(rename = "old_name")]` |
| Type mismatch | Parse error | Check JSON/source types |
| Encoding | Invalid UTF-8 | Check source encoding |

---

## Concurrency Problems

### Race Conditions

**Symptoms:**
- Intermittent failures
- Different results on each run
- Works in debug, fails in release

**Diagnostic:**
```rust
// Add synchronization logging
tracing::debug!(thread = ?std::thread::current().id(), "Entering critical section");

// Check for unsynchronized shared state
// Look for: static mut, RefCell across threads, raw pointers

// Run repeatedly to reproduce
for _ in 0..1000 {
    test_concurrent_function();
}
```

### Deadlocks

**Symptoms:**
- Application hangs
- No CPU usage
- Timeouts

**Diagnostic checklist:**
- [ ] Are locks acquired in consistent order?
- [ ] Are there nested lock acquisitions?
- [ ] Is async code blocking on sync primitives?

```rust
// Check lock ordering
// BAD: Inconsistent order
fn thread_a() { lock_a(); lock_b(); }
fn thread_b() { lock_b(); lock_a(); }  // Potential deadlock!

// GOOD: Consistent order
fn thread_a() { lock_a(); lock_b(); }
fn thread_b() { lock_a(); lock_b(); }  // Same order
```

### Ordering Issues

**Symptoms:**
- Events processed out of order
- Missing updates
- Stale data

**Diagnostic:**
```rust
// Add sequence numbers
struct Message {
    seq: u64,
    payload: Data,
}

// Log ordering
tracing::debug!(seq = msg.seq, "Processing message");
```

---

## External Dependencies

### API Changes

**Symptoms:**
- Deserialization failures
- Missing fields
- Changed response formats

**Diagnostic:**
```bash
# Compare expected vs actual response
curl -s https://api.example.com/endpoint | jq .

# Check dependency versions
cargo tree -i <package>
```

### Network Issues

**Symptoms:**
- Timeout errors
- Connection refused
- Intermittent failures

**Diagnostic checklist:**
- [ ] Is the endpoint reachable?
- [ ] Are credentials valid?
- [ ] Are there rate limits?
- [ ] Is SSL/TLS configured correctly?

### File System Issues

**Symptoms:**
- File not found
- Permission denied
- Path resolution failures

**Diagnostic:**
```rust
// Log resolved paths
let path = config_dir.join("settings.toml");
tracing::debug!(path = %path.display(), "Looking for config");

// Check existence and permissions
if !path.exists() {
    tracing::error!(path = %path.display(), "File not found");
}
```

---

## Environment/Configuration

### Missing Configuration

**Symptoms:**
- Panic on startup
- Default values used unexpectedly
- Environment-specific failures

**Diagnostic:**
```bash
# Check environment variables
env | grep -i <prefix>

# Verify config file location
echo $CONFIG_PATH
ls -la ~/.config/app/
```

### Path Resolution Issues

**Symptoms:**
- Works locally, fails in CI
- Works in one directory, fails in another
- Relative path confusion

**Diagnostic:**
```rust
// Always log resolved paths
let cwd = std::env::current_dir()?;
tracing::debug!(cwd = %cwd.display(), "Current directory");

let resolved = path.canonicalize()?;
tracing::debug!(resolved = %resolved.display(), "Resolved path");
```

### Credential Issues

**Symptoms:**
- Authentication failures
- 401/403 HTTP responses
- "Invalid token" errors

**Diagnostic checklist:**
- [ ] Is the credential present?
- [ ] Is it in the correct format?
- [ ] Has it expired?
- [ ] Is it for the correct environment?

---

## Memory/Resources

### Memory Leaks

**Symptoms:**
- Growing memory usage
- OOM kills
- Slowdown over time

**Diagnostic:**
```bash
# Monitor memory
watch -n 1 "ps -o rss,vsz,pid -p $(pgrep app)"

# Use valgrind (if available)
valgrind --leak-check=full ./target/debug/app
```

### Resource Exhaustion

**Symptoms:**
- "Too many open files"
- "Out of memory"
- "Thread limit reached"

**Diagnostic:**
```bash
# Check file descriptors
ls -la /proc/$(pgrep app)/fd | wc -l
ulimit -n

# Check threads
ps -T -p $(pgrep app) | wc -l
```

---

## Root Cause Documentation Template

When you identify a root cause, document it:

```markdown
## Root Cause: [Brief Description]

**Category:** [Logic | Data | Concurrency | External | Environment | Memory]

**Symptom:** What was observed

**Investigation:**
1. Step taken
2. What was found
3. How root cause was identified

**Root Cause:** Specific technical cause

**Fix:** What was changed

**Prevention:** How to prevent similar issues

**Kodo Signal:**
```bash
kodo reflect --signal "Root cause: <category> - <description>"
```
```

---

## Quick Diagnosis Flowchart

```
Bug Reported
    │
    ├─ Reproducible? ─── No ──→ Concurrency or Environment
    │                           - Add logging
    │                           - Check race conditions
    │
    └─ Yes
        │
        ├─ Clear error message? ─── Yes ──→ Follow the error
        │                                   - Check stack trace
        │                                   - Trace to source
        │
        └─ No clear error
            │
            ├─ Wrong output? ──→ Logic or Data
            │                    - Trace data flow
            │                    - Check transformations
            │
            ├─ Crash/Panic? ──→ Memory or Logic
            │                   - Check bounds
            │                   - Check unwraps
            │
            └─ Hang? ──→ Concurrency or External
                         - Check locks
                         - Check network calls
```
