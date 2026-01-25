---
name: kodo-supa-db
description: Manage database operations using Supabase CLI with intelligent ORM detection for hybrid workflows
---

# /kodo supa-db - Database Operations

Manage database operations using Supabase CLI, with intelligent ORM detection for hybrid workflows.

## What You Do

When the user runs `/kodo supa-db [action] [args]`:

**First**: Check `.kodo/config.json` for `stack.workspaces.*.database.orm` to detect if using Drizzle or another ORM.

**Actions:**
- `types` - Generate TypeScript types
- `diff` - Show schema changes
- `reset` - Reset local database
- `push` - Push to remote
- `pull` - Pull from remote
- `function` - Create database function (Supabase migration)
- `trigger` - Create trigger (Supabase migration)
- `policy` - Create RLS policy (Supabase migration)
- `sync` - Sync Drizzle migrations to Supabase (hybrid only)

## ORM Detection

Check `.kodo/config.json`:

```json
{
  "stack": {
    "workspaces": {
      "server": {
        "database": {
          "orm": "drizzle",           // Triggers hybrid mode
          "migrationStrategy": "hybrid"
        }
      }
    }
  }
}
```

**If `orm: "drizzle"` detected:**
- Use hybrid workflow (see `/kodo supa-schema` for table changes)
- Guide user: "Tables should be defined in Drizzle schema. Use `/kodo supa-schema` for table changes."
- Functions, triggers, and RLS go directly to Supabase migrations

**If no ORM or `orm: null`:**
- Standard Supabase-only workflow
- All operations via Supabase CLI and migrations

## Commands to Execute

### Generate TypeScript Types

```bash
# From local database (includes both Drizzle tables and Supabase functions)
supabase gen types typescript --local > src/types/supabase.ts

# From remote
supabase gen types typescript --project-id <project-id> > src/types/supabase.ts
```

**Hybrid note**: Drizzle generates types from `schema.ts` at compile time. Supabase types are for RPC functions, storage, auth, etc.

### Show Schema Diff

```bash
# Show changes (Supabase compares against applied migrations)
supabase db diff --use-migra

# Save as migration
supabase db diff --use-migra -f <migration-name>
```

**Hybrid note**: If using Drizzle, first run `npx drizzle-kit generate` for table changes.

### Reset Local Database

```bash
supabase db reset
```

This applies ALL migrations in `supabase/migrations/` in order, including:
- Extensions
- Drizzle-generated table migrations (copied to Supabase)
- Functions, triggers, RLS

### Push to Remote

```bash
supabase db push
```

**Hybrid workflow**: Ensure Drizzle migrations are copied to `supabase/migrations/` first.

### Pull from Remote

```bash
supabase db pull
```

**Warning for hybrid**: This creates migrations from remote schema. May need to sync back to Drizzle schema manually.

### Sync Drizzle to Supabase (Hybrid Only)

```bash
# List pending Drizzle migrations
ls drizzle/migrations/

# Copy new migrations to Supabase
cp drizzle/migrations/XXXX_*.sql supabase/migrations/XXXXX_drizzle_*.sql
```

## SQL Templates (Supabase Migrations)

These go in `supabase/migrations/` even when using Drizzle:

### Database Function

```sql
-- supabase/migrations/XXXXX_add_calculate_total.sql
CREATE OR REPLACE FUNCTION public.calculate_total(order_id uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  total numeric;
BEGIN
  SELECT SUM(price * quantity) INTO total
  FROM public.order_items
  WHERE order_items.order_id = calculate_total.order_id;

  RETURN COALESCE(total, 0);
END;
$$;
```

### Trigger Function

```sql
-- supabase/migrations/XXXXX_add_updated_at_trigger.sql
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Apply to table (table must exist from Drizzle migration)
CREATE TRIGGER set_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

### Audit Logging Function

```sql
-- supabase/migrations/XXXXX_add_audit_function.sql
CREATE OR REPLACE FUNCTION public.audit_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.audit_log (
    user_id, action, table_name, record_id, old_data, new_data, timestamp
  ) VALUES (
    auth.uid(),
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD)::text END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW)::text END,
    NOW()
  );
  RETURN COALESCE(NEW, OLD);
END;
$$;
```

### RLS Policies

```sql
-- supabase/migrations/XXXXX_add_users_rls.sql

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- User owns data
CREATE POLICY "Users can view own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- Org-based with JWT claims (efficient)
CREATE POLICY "Users can view org documents"
ON public.documents FOR SELECT
USING (org_id = (SELECT auth.jwt() ->> 'org_id')::uuid);

-- Performance index for RLS
CREATE INDEX IF NOT EXISTS idx_documents_org_id ON public.documents(org_id);
```

### Async HTTP with pg_net

```sql
-- supabase/migrations/XXXXX_add_webhook_trigger.sql

-- Ensure pg_net extension exists
-- (should be in 00000_extensions.sql)

CREATE OR REPLACE FUNCTION notify_external_service()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://api.example.com/webhook',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.api_key', true)
    ),
    body := jsonb_build_object('id', NEW.id, 'action', TG_OP)
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER notify_on_order_create
  AFTER INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION notify_external_service();
```

## Migration Naming Convention

```
supabase/migrations/
├── 00000_extensions.sql              # Always first
├── 00001_drizzle_init.sql            # First Drizzle migration
├── 00002_core_functions.sql          # Helper functions
├── 00003_core_triggers.sql           # updated_at triggers
├── 00004_rls_policies.sql            # Initial RLS
├── 00100_drizzle_add_products.sql    # Next Drizzle migration
├── 00101_products_rls.sql            # RLS for products
└── ...
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/database-functions.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/hybrid-orm-architecture.md` (if ORM detected)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/drizzle-integration.md` (if Drizzle)

## Examples

### Standard Workflow (No ORM)

```
User: /kodo supa-db types

Claude: Generating TypeScript types...

```bash
supabase gen types typescript --local > src/types/database.ts
```

Types will be generated from your local database schema.
```

### Hybrid Workflow (Drizzle Detected)

```
User: /kodo supa-db types

Claude: I see you're using Drizzle ORM. Generating types from both sources:

**Drizzle types** are auto-generated from `src/db/schema.ts` at compile time.

**Supabase types** (for RPC, auth, storage):

```bash
supabase gen types typescript --local > src/types/supabase.ts
```

Use Drizzle types for table queries, Supabase types for RPC function calls.
```

### Creating a Function (Hybrid)

```
User: /kodo supa-db function calculate_order_total

Claude: Creating a database function. Since you're using Drizzle, this goes in Supabase migrations (not Drizzle schema).

**Step 1**: Create migration file:

```bash
supabase migration new add_calculate_order_total
```

**Step 2**: Add SQL to `supabase/migrations/XXXXX_add_calculate_order_total.sql`:

[Shows function SQL]

**Step 3**: Apply locally:

```bash
supabase db reset
```

**Step 4**: Create TypeScript wrapper in `src/db/functions/orders.ts`:

[Shows wrapper code]

This keeps your function logic in the database with a type-safe wrapper in TypeScript.
```

### Creating a Trigger (Hybrid)

```
User: /kodo supa-db trigger audit_users

Claude: Creating an audit trigger. In the hybrid setup:

- **Table definition**: Already in Drizzle schema (`src/db/schema.ts`)
- **Trigger + function**: Goes in Supabase migrations

**Step 1**: Create migration:

```bash
supabase migration new add_audit_trigger
```

**Step 2**: Add to migration file:

```sql
-- First ensure audit_log table exists (should be in Drizzle schema)
-- Then create the function and trigger:

CREATE OR REPLACE FUNCTION public.audit_changes() ...

CREATE TRIGGER audit_users
  AFTER INSERT OR UPDATE OR DELETE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.audit_changes();
```

**Step 3**: Apply:

```bash
supabase db reset
```

Triggers run automatically - no TypeScript code needed.
```

## Decision Guide

| Operation | With Drizzle | Without ORM |
|-----------|--------------|-------------|
| Add table | `/kodo supa-schema` (Drizzle) | `/kodo supa-migrate new` |
| Add column | `/kodo supa-schema` (Drizzle) | `/kodo supa-migrate new` |
| Add index | `/kodo supa-schema` (Drizzle) | `/kodo supa-migrate new` |
| Add function | `/kodo supa-db function` | `/kodo supa-db function` |
| Add trigger | `/kodo supa-db trigger` | `/kodo supa-db trigger` |
| Add RLS | `/kodo supa-db policy` | `/kodo supa-db policy` |
| Generate types | `/kodo supa-db types` | `/kodo supa-db types` |
