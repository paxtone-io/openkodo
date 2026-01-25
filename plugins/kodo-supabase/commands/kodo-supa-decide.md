---
name: kodo-supa-decide
description: Get architecture recommendation for implementing a feature with Supabase
---

# /kodo supa-decide - Architecture Decision

Get architecture recommendation for implementing a feature with Supabase.

## What You Do

When the user runs `/kodo supa-decide` or `/kodo supa-decide [feature]`:

1. **Load project context**:
   - Read `.kodo/config.json` for stack configuration
   - Check existing architecture in `./docs/tech-decisions/`

2. **If no feature specified**, ask what to implement.

3. **Analyze requirements**:
   - CPU/time constraints
   - External API needs
   - Real-time requirements
   - Data complexity
   - Authentication needs
   - Scale expectations

4. **Apply decision matrix**:

   | Scenario | Use |
   |----------|-----|
   | API endpoint <2s CPU | Edge Function |
   | Webhook handler | Edge Function |
   | CPU-intensive (image/ML) | Fly.io backend |
   | Long-running >6.5min | Fly.io worker |
   | Data validation/triggers | Database Function |
   | Bulk INSERT/UPDATE | Database Function |
   | User CRUD with auth | Direct client + RLS |
   | Rate limiting, quotas | Backend API layer |
   | Real-time <10K users | Supabase Realtime |
   | Sub-10ms latency | Custom WebSocket |

5. **Provide recommendation** with:
   - Which approach and why
   - Constraints to consider
   - Code pattern from skill references
   - Supabase CLI commands to get started

6. **Document decision** in `./docs/tech-decisions/`:
   ```markdown
   # Architecture Decision: {feature}

   ## Context
   {What we're building and why}

   ## Decision
   Use {Edge Function / DB Function / etc.}

   ## Rationale
   - Constraint 1: {reason}
   - Constraint 2: {reason}

   ## Consequences
   - Pro: {benefit}
   - Con: {tradeoff}

   ## Implementation
   ```bash
   supabase functions new {name}
   ```
   ```

## Supabase CLI Commands (Use These)

```bash
# Edge Functions
supabase functions new webhook-handler
supabase functions serve
supabase functions deploy webhook-handler

# Database Functions
supabase migration new add_function
# Then add SQL in migration file

# Check status
supabase status
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md` - Decision matrix and constraints
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/edge-functions.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/database-functions.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/flyio-integration.md`

## Example

```
User: /kodo supa-decide stripe webhook handler

Claude: Analyzing Stripe webhook requirements...

**Recommendation: Edge Function**

Reasons:
- Webhooks need fast response (<2s)
- No CPU-intensive processing
- External API call (Stripe)
- No native binary dependencies

Constraints:
- 2s CPU time limit (sufficient for webhook)
- 256MB memory (sufficient)

Get started:
```bash
supabase functions new stripe-webhook
```

[Shows webhook handler code pattern]

Document this decision? (y/n)
```
