---
name: kodo-supa-edge
description: Create and manage Supabase Edge Functions using the CLI
---

# /kodo supa-edge - Manage Edge Functions

Create and manage Supabase Edge Functions using the CLI.

## What You Do

When the user runs `/kodo supa-edge [action] [name]`:

**Actions:**
- `new` - Create new function
- `serve` - Run locally for development
- `deploy` - Deploy to Supabase
- `list` - List all functions
- `logs` - View function logs
- `delete` - Delete a function

## Commands to Execute

### Create new function
```bash
supabase functions new <function-name>
```
Creates: `supabase/functions/<function-name>/index.ts`

### Serve locally
```bash
# All functions
supabase functions serve

# Specific function with env file
supabase functions serve <function-name> --env-file .env.local

# With debug logging
supabase functions serve --debug
```

### Deploy
```bash
# All functions
supabase functions deploy

# Specific function
supabase functions deploy <function-name>

# With import map for npm packages
supabase functions deploy <function-name> --import-map supabase/functions/import_map.json
```

### List functions
```bash
supabase functions list
```

### View logs
```bash
supabase functions logs <function-name>
```

### Delete function
```bash
supabase functions delete <function-name>
```

## Function Templates

### Basic HTTP Handler
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name } = await req.json()

  return new Response(
    JSON.stringify({ message: `Hello ${name}!` }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

### Webhook with Database
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const payload = await req.json()

  await supabase.from('events').insert({
    type: payload.type,
    data: payload
  })

  return new Response(JSON.stringify({ received: true }))
})
```

### Background Task
```typescript
serve(async (req) => {
  const { userId } = await req.json()

  // Return immediately
  const response = new Response(JSON.stringify({ accepted: true }))

  // Process in background
  EdgeRuntime.waitUntil((async () => {
    await heavyProcessing(userId)
  })())

  return response
})
```

## Constraints

- **CPU time**: 2 seconds max
- **Wall clock**: 150s (Free) / 400s (Paid)
- **Memory**: 256 MB
- **Bundle size**: 20 MB
- **No native binaries** (no sharp, canvas, etc.)

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/edge-functions.md`

## Example

```
User: /kodo supa-edge new stripe-webhook

Claude: Creating new Edge Function...

Run:
```bash
supabase functions new stripe-webhook
```

I'll also generate the webhook handler code:

[Creates supabase/functions/stripe-webhook/index.ts with Stripe pattern]

To test locally:
```bash
supabase functions serve stripe-webhook --env-file .env.local
```

To deploy:
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_xxx STRIPE_WEBHOOK_SECRET=whsec_xxx
supabase functions deploy stripe-webhook
```
```
