---
name: kodo-supa-deploy
description: Deploy Edge Functions and database changes to production
---

# /kodo supa-deploy - Deploy to Supabase

Deploy Edge Functions and database changes to production.

## What You Do

When the user runs `/kodo supa-deploy [target]`:

**Targets:**
- (none) - Deploy all
- `functions` - Edge Functions only
- `db` - Database only
- `<function-name>` - Specific function

## Commands to Execute

### Deploy all Edge Functions
```bash
supabase functions deploy
```

### Deploy specific function
```bash
supabase functions deploy <function-name>

# With import map
supabase functions deploy <function-name> --import-map supabase/functions/import_map.json
```

### Deploy database
```bash
supabase db push
```

### Full deployment
```bash
# Database first, then functions
supabase db push
supabase functions deploy
```

## Pre-Deployment Checklist

Run these checks before deploying:

```bash
# 1. Check migration status
supabase migration status

# 2. List configured secrets
supabase secrets list

# 3. Test functions locally
supabase functions serve

# 4. Verify project link
supabase status
```

## Setting Secrets

```bash
# Set individual secret
supabase secrets set MY_API_KEY=value

# Set multiple
supabase secrets set KEY1=value1 KEY2=value2

# From env file
supabase secrets set --env-file .env.production

# List (names only, not values)
supabase secrets list

# Remove
supabase secrets unset MY_API_KEY
```

### Common Secrets Needed

```bash
# Stripe
supabase secrets set STRIPE_SECRET_KEY=sk_live_xxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx

# OpenAI
supabase secrets set OPENAI_API_KEY=sk-xxx

# Resend (email)
supabase secrets set RESEND_API_KEY=re_xxx

# Custom
supabase secrets set APP_SECRET=xxx
```

## Import Maps for npm

Create `supabase/functions/import_map.json`:
```json
{
  "imports": {
    "stripe": "https://esm.sh/stripe@14.0.0",
    "openai": "https://esm.sh/openai@4.0.0",
    "lodash": "https://esm.sh/lodash@4.17.21",
    "zod": "https://esm.sh/zod@3.22.0"
  }
}
```

Deploy with:
```bash
supabase functions deploy --import-map supabase/functions/import_map.json
```

## Post-Deployment Verification

```bash
# List deployed functions
supabase functions list

# Check function logs
supabase functions logs <function-name>

# Test function
curl -X POST https://<project>.supabase.co/functions/v1/<function-name> \
  -H "Authorization: Bearer <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md`

## Example

```
User: /kodo supa-deploy

Claude: Preparing full deployment...

**Pre-deployment checklist:**

1. Migration status:
```bash
supabase migration status
```

2. Secrets configured? (check these are set):
   - STRIPE_SECRET_KEY
   - STRIPE_WEBHOOK_SECRET

3. Functions tested locally?

**Deploy commands:**

```bash
# Push database changes
supabase db push

# Deploy all functions
supabase functions deploy
```

Ready to deploy? I can run these commands for you.

---

User: /kodo supa-deploy stripe-webhook

Claude: Deploying stripe-webhook function...

```bash
# Ensure secrets are set
supabase secrets list

# Deploy function
supabase functions deploy stripe-webhook
```

After deployment, verify:
```bash
supabase functions list
supabase functions logs stripe-webhook
```
```
