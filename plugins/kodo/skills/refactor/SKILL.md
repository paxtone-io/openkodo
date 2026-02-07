---
name: refactor
description: >
  Guided safe refactoring with test verification at each step.
  Use for restructuring code safely with continuous validation.
---

# Safe Refactoring Process

## Overview

Systematic refactoring workflow with safety checks at every step. Verify test
coverage before starting, make small incremental changes, run tests after each
change, and commit frequently. Matches the kodo-refactor agent capabilities.

**Core principle:** Safety first. Small steps. Continuous verification. Never break tests.

**Announce at start:** "I'm using the refactor skill for safe refactoring."

## When to Use

- Improving code structure
- Reducing duplication (DRY)
- Extracting reusable components
- Renaming for clarity
- Simplifying complex logic
- Preparing code for new features

## The Refactoring Process

### Phase 1: Assess

**Before touching code:**

1. **Understand scope:**
   ```bash
   kodo query "refactoring patterns"    # Check existing patterns
   kodo query "<component>"             # Component context
   ```

2. **Check test coverage:**
   ```bash
   kodo test coverage --file <file>     # Current coverage
   kodo test coverage --threshold 80    # Ensure minimum coverage
   ```

3. **Identify risks:**
   - External dependencies
   - Breaking changes
   - Performance implications
   - Side effects

4. **Plan refactor:**
   - List specific changes
   - Order by risk (safest first)
   - Identify test gaps

### Phase 2: Prepare

**Add missing test coverage:**

```bash
# 1. Find coverage gaps
kodo test coverage --gaps

# 2. Write tests for uncovered paths
# ... add tests ...

# 3. Verify new tests pass
kodo test --changed

# 4. Commit test improvements
git add tests/
git commit -m "test: add coverage before refactor"
```

**Never refactor without test coverage. If tests don't exist, write them first.**

### Phase 3: Execute (Small Steps)

**Each refactoring step:**

1. **Make ONE change** (2-5 minutes):
   - Extract method
   - Rename variable
   - Move code
   - Simplify logic

2. **Run affected tests:**
   ```bash
   kodo test --changed
   ```

3. **Verify tests pass:**
   - All green? Continue
   - Tests fail? Revert and reassess

4. **Commit immediately:**
   ```bash
   git add <files>
   git commit -m "refactor: <specific-change>"
   ```

**Example sequence:**

```bash
# Step 1: Extract method
# ... extract calculate_total() ...
kodo test --module billing
git commit -m "refactor: extract calculate_total method"

# Step 2: Rename for clarity
# ... rename 'x' to 'customer_count' ...
kodo test --module billing
git commit -m "refactor: rename x to customer_count"

# Step 3: Move to utils
# ... move helper to utils/ ...
kodo test --changed
git commit -m "refactor: move calculate_total to utils"
```

### Phase 4: Validate

**After refactoring complete:**

1. **Run full test suite:**
   ```bash
   cargo test
   ```

2. **Verify coverage maintained:**
   ```bash
   kodo test coverage --threshold 80
   ```

3. **Check for regressions:**
   ```bash
   kodo test --module <refactored-module>
   ```

4. **Capture learnings:**
   ```bash
   kodo reflect --signal "Refactoring pattern: <pattern>"
   ```

## Integration with Kodo

**Before refactoring:**
```bash
kodo query "refactoring patterns"       # Check existing approaches
kodo query "<component>"                # Component context
kodo test coverage --file <file>        # Ensure test coverage
```

**During refactoring:**
```bash
kodo test --changed                     # After each step
kodo reflect --signal "Step worked: <description>"
```

**After refactoring:**
```bash
cargo test                              # Full validation
kodo test coverage                      # Verify coverage
kodo reflect                            # Capture session learnings
kodo curate add --category patterns     # Document reusable pattern
```

## Refactoring Patterns

### Extract Method

**Before:**
```rust
fn process_order(order: Order) -> Result<Receipt> {
    // 50 lines of complex logic
    let total = order.items.iter().map(|i| i.price * i.qty).sum();
    let tax = total * 0.08;
    let final_total = total + tax;
    // More logic...
}
```

**After:**
```rust
fn process_order(order: Order) -> Result<Receipt> {
    let total = calculate_order_total(&order);
    // Clearer logic...
}

fn calculate_order_total(order: &Order) -> f64 {
    let subtotal = order.items.iter().map(|i| i.price * i.qty).sum();
    let tax = subtotal * 0.08;
    subtotal + tax
}
```

**Steps:**
1. Write test for extracted method
2. Extract method with exact current logic
3. Run tests: `kodo test --changed`
4. Commit: `git commit -m "refactor: extract calculate_order_total"`

### Rename for Clarity

**Before:**
```rust
fn process(x: Vec<Item>) -> f64 {
    x.iter().map(|i| i.p * i.q).sum()
}
```

**After:**
```rust
fn calculate_total_price(items: Vec<Item>) -> f64 {
    items.iter().map(|item| item.price * item.quantity).sum()
}
```

**Steps:**
1. Use IDE refactor tool (if available) or manual find-replace
2. Run tests: `kodo test --changed`
3. Commit: `git commit -m "refactor: rename process to calculate_total_price"`

### Remove Duplication (DRY)

**Before:**
```rust
fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.')
}

fn check_user_email(user: &User) -> bool {
    user.email.contains('@') && user.email.contains('.')
}
```

**After:**
```rust
fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.')
}

fn check_user_email(user: &User) -> bool {
    validate_email(&user.email)
}
```

**Steps:**
1. Ensure both functions have tests
2. Update second function to call first
3. Run all tests: `kodo test --module <module>`
4. Commit: `git commit -m "refactor: deduplicate email validation"`

### Simplify Complex Logic

Use pattern matching, early returns, guard clauses:

**Before:**
```rust
fn get_discount(user: &User, amount: f64) -> f64 {
    if user.is_premium {
        if amount > 100.0 {
            return amount * 0.2;
        } else {
            return amount * 0.1;
        }
    } else {
        if amount > 100.0 {
            return amount * 0.05;
        } else {
            return 0.0;
        }
    }
}
```

**After:**
```rust
fn get_discount(user: &User, amount: f64) -> f64 {
    match (user.is_premium, amount > 100.0) {
        (true, true) => amount * 0.2,
        (true, false) => amount * 0.1,
        (false, true) => amount * 0.05,
        (false, false) => 0.0,
    }
}
```

## Key Principles

- **Test coverage first** - Never refactor without tests
- **Small steps** - One change at a time (2-5 minutes)
- **Run tests after each step** - Catch issues immediately
- **Commit frequently** - After each verified step
- **Don't change behavior** - Refactor should not alter functionality
- **Stop if tests fail** - Revert and reassess approach

## Red Flags

**You're doing it wrong if:**
- Refactoring without test coverage
- Making multiple changes before running tests
- Continuing after test failures
- Not committing between steps
- Changing behavior while refactoring
- Skipping `kodo test coverage` validation
- Not capturing refactoring patterns with `kodo reflect`
- Making changes larger than 5 minutes without verification
