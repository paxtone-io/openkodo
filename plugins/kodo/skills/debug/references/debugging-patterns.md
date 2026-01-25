# Debugging Patterns for Rust Codebases

Common debugging patterns and diagnostic approaches for Rust projects.

---

## Memory-Related Issues

### Use-After-Free / Double-Free

**Symptoms:**
- Panic with "already borrowed" or "already mutably borrowed"
- Segfault in unsafe code
- Corrupted data appearing randomly

**Diagnostic Steps:**

1. **Check ownership transfers**
   ```rust
   // Problem: value moved
   let data = get_data();
   process(data);        // data moved here
   println!("{:?}", data); // Error: use after move

   // Fix: clone or borrow
   let data = get_data();
   process(&data);       // borrow instead
   println!("{:?}", data); // Works
   ```

2. **Look for `mem::forget` or `ManuallyDrop`**
   ```bash
   grep -r "mem::forget\|ManuallyDrop" src/
   ```

3. **Run with sanitizers (nightly)**
   ```bash
   RUSTFLAGS="-Z sanitizer=address" cargo +nightly test
   ```

**Kodo integration:**
```bash
kodo query "ownership patterns"
kodo query "memory management"
```

---

### Lifetime and Borrow Checker Issues

**Common Error Messages:**

| Error | Likely Cause |
|-------|--------------|
| "does not live long enough" | Reference outlives data |
| "cannot borrow as mutable" | Already borrowed immutably |
| "cannot move out of" | Trying to own borrowed data |
| "missing lifetime specifier" | Function needs explicit lifetimes |

**Diagnostic Patterns:**

1. **Identify the borrowed value**
   ```rust
   // Error: returns reference to local
   fn get_name() -> &str {
       let name = String::from("test");
       &name  // name dropped here, reference invalid
   }

   // Fix: return owned value
   fn get_name() -> String {
       String::from("test")
   }
   ```

2. **Trace the borrow chain**
   ```rust
   // Find where the immutable borrow starts
   let data = &self.items;  // immutable borrow starts
   // ... many lines ...
   self.items.push(x);      // Error: mutable borrow while immutable exists

   // Fix: scope the borrow
   {
       let data = &self.items;
       // use data
   }  // immutable borrow ends
   self.items.push(x);  // Now OK
   ```

3. **Check for self-referential structs**
   ```rust
   // Problem: struct can't hold reference to itself
   struct Node {
       value: String,
       next: Option<&Node>,  // Won't work
   }

   // Fix: use Box, Rc, or indices
   struct Node {
       value: String,
       next: Option<Box<Node>>,
   }
   ```

---

## Async/Tokio Patterns

### Deadlocks

**Symptoms:**
- Application hangs
- No CPU usage but not responding
- Timeout errors

**Diagnostic Steps:**

1. **Check for sync in async context**
   ```rust
   // Problem: blocking in async
   async fn fetch() {
       let data = std::fs::read("file.txt"); // Blocks!
   }

   // Fix: use async version
   async fn fetch() {
       let data = tokio::fs::read("file.txt").await;
   }
   ```

2. **Check mutex usage**
   ```rust
   // Problem: std::sync::Mutex in async
   let lock = std::sync::Mutex::new(data);

   // Fix: use tokio::sync::Mutex
   let lock = tokio::sync::Mutex::new(data);
   ```

3. **Add tracing for diagnosis**
   ```rust
   #[tracing::instrument]
   async fn problematic_function() {
       tracing::debug!("entering");
       // ...
       tracing::debug!("exiting");
   }
   ```

### Runtime Panics

**Common causes:**

| Panic Message | Cause | Fix |
|--------------|-------|-----|
| "Cannot start a runtime from within a runtime" | Nested `block_on` | Use `.await` or spawn |
| "no reactor running" | Async op outside runtime | Ensure tokio runtime exists |
| "task was cancelled" | Parent task dropped | Handle cancellation properly |

**Diagnostic:**
```bash
RUST_BACKTRACE=1 cargo run
RUST_BACKTRACE=full cargo test
```

---

## Error Propagation Issues

### Lost Error Context

**Problem:** Errors lose their original context when propagated.

```rust
// Bad: context lost
fn process() -> Result<(), Error> {
    read_file()?;  // If this fails, where was it called?
}

// Good: add context
use anyhow::Context;

fn process() -> Result<(), Error> {
    read_file()
        .context("Failed to read configuration file")?;
}
```

### Wrong Error Type

**Diagnostic:**
```rust
// Check error type matches
fn parse_config() -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string(path)?; // Returns io::Error!
    //                                          ^ Type mismatch
}

// Fix: convert or use anyhow
fn parse_config() -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string(path)
        .map_err(|e| ConfigError::IoError(e))?;
}
```

### Error Not Displayed

**Problem:** Custom errors don't show useful messages.

```rust
// Missing Display implementation
#[derive(Debug)]
struct MyError(String);

// Add Display
impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "MyError: {}", self.0)
    }
}
impl std::error::Error for MyError {}
```

---

## Type System Issues

### Trait Object Problems

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| "trait cannot be made into an object" | Has generic methods | Use concrete type or `Box<dyn>` |
| "the size cannot be known" | Missing `Sized` bound | Add `?Sized` or use reference |
| "cannot be sent between threads" | Missing `Send` bound | Add `Send` requirement |

**Diagnostic pattern:**
```rust
// Find what's preventing object safety
trait MyTrait {
    fn generic_method<T>(&self, x: T);  // Not object-safe!
    fn sized_self(self);                 // Not object-safe!
}

// Fix: make non-generic
trait MyTrait {
    fn method(&self, x: Box<dyn Any>);
    fn sized_self(self: Box<Self>);
}
```

### Generic Bound Issues

**Diagnostic steps:**

1. **Read the full error message** - Rust usually tells you what bound is missing
2. **Add bounds incrementally**
   ```rust
   // Start simple
   fn process<T>(x: T) {}

   // Add bounds as compiler requests
   fn process<T: Clone>(x: T) {}
   fn process<T: Clone + Debug>(x: T) {}
   fn process<T: Clone + Debug + Send>(x: T) {}
   ```

---

## Concurrency Problems

### Data Races (in unsafe code)

**Detection:**
```bash
# Run with thread sanitizer (nightly)
RUSTFLAGS="-Z sanitizer=thread" cargo +nightly test
```

### Incorrect Sync/Send

**Symptoms:**
- Compilation fails when spawning threads
- "cannot be sent between threads safely"

**Diagnostic:**
```rust
// Check what's not Send
fn assert_send<T: Send>() {}

// This will fail if MyType isn't Send
assert_send::<MyType>();
```

---

## Build and Compilation Issues

### Dependency Conflicts

```bash
# View dependency tree
cargo tree

# Find duplicates
cargo tree -d

# Specific package versions
cargo tree -i <package-name>
```

### Feature Flag Issues

```bash
# Show enabled features
cargo tree -f "{p} {f}"

# Build with specific features
cargo build --features "feature1,feature2"
cargo build --no-default-features --features "minimal"
```

---

## Diagnostic Tools Quick Reference

| Tool | Purpose | Command |
|------|---------|---------|
| Backtrace | Stack trace on panic | `RUST_BACKTRACE=1 cargo run` |
| Miri | Undefined behavior | `cargo +nightly miri test` |
| Clippy | Lint warnings | `cargo clippy -- -W clippy::all` |
| ASan | Memory errors | `RUSTFLAGS="-Z sanitizer=address"` |
| TSan | Thread safety | `RUSTFLAGS="-Z sanitizer=thread"` |
| Expand | Macro expansion | `cargo expand` |
| Flamegraph | Performance | `cargo flamegraph` |

---

## Kodo Integration

**Before debugging:**
```bash
kodo query "similar error"       # Was this solved before?
kodo query "<module> behavior"   # Expected patterns
```

**After fixing:**
```bash
kodo reflect --signal "Root cause: <description>"
kodo reflect --signal "Pattern to watch: <description>"
```
