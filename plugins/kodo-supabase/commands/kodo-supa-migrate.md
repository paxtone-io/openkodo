---
name: kodo-supa-migrate
description: Manage database migrations using Supabase CLI with intelligent ORM detection for hybrid workflows
---

# /kodo supa-migrate - Universal Database Migrations

Manage database migrations using Supabase CLI, with intelligent ORM detection for hybrid workflows across TypeScript, Python, and Rust.

## What You Do

When the user runs `/kodo supa-migrate [action] [name]`:

**First**: Check `.kodo/config.json` for `stack.workspaces.*.database.orm.name` to detect ORM and language.

**Actions:**
- `new` - Create empty Supabase migration
- `list` - List all migrations
- `status` - Check sync status
- `up` - Apply pending migrations
- `repair` - Fix migration history
- `squash` - Combine migrations
- `sync` - Sync ORM migrations to Supabase (hybrid only)
- `init` - Initialize hybrid migration structure (hybrid only)

## ORM Detection

Check `.kodo/config.json`:

```json
{
  "stack": {
    "languages": ["typescript", "python"],
    "workspaces": {
      "server": {
        "language": "typescript",
        "database": {
          "orm": { "name": "drizzle" },
          "migrationStrategy": {
            "type": "hybrid",
            "serviceRange": { "start": "00100", "end": "00199" }
          }
        }
      },
      "api": {
        "language": "python",
        "database": {
          "orm": { "name": "sqlalchemy" },
          "migrationStrategy": {
            "type": "hybrid",
            "serviceRange": { "start": "00200", "end": "00299" }
          }
        }
      }
    },
    "sharedDatabase": {
      "enabled": true,
      "provider": "supabase"
    }
  }
}
```

**ORM Detection Table:**

| `orm.name` | Language | Migration Tool | Migration Source | Service Range |
|------------|----------|----------------|------------------|---------------|
| `"drizzle"` | TypeScript | drizzle-kit | `drizzle/migrations/` | 00100-00199 |
| `"sqlalchemy"` | Python | alembic | `alembic/versions/` | 00200-00299 |
| `"sqlx"` | Rust | sqlx-cli | `migrations/` | 00300-00399 |
| `null` | Any | supabase CLI | SQL only | 00000-00099 |

**If ORM detected:**
- Guide hybrid workflow
- ORM generates table migrations -> convert/copy to Supabase
- Supabase manages functions, triggers, RLS
- Use `/kodo supa-schema` for table changes

**If no ORM:**
- Standard Supabase-only workflow

## Commands to Execute

### Create Migration (Supabase-Only)

```bash
# Empty migration
supabase migration new <name>

# From schema diff (RECOMMENDED when NOT using ORM)
supabase db diff --use-migra -f <name>
```

Creates: `supabase/migrations/<timestamp>_<name>.sql`

### List Migrations

```bash
supabase migration list
```

### Check Status

```bash
supabase migration status
```

Shows:
- Local migrations
- Remote migrations (if linked)
- Sync status

### Apply Migrations

```bash
# Reset and apply all (local)
supabase db reset

# Apply pending only
supabase migration up

# Push to remote
supabase db push
```

### Repair History

```bash
# Mark as applied (without running)
supabase migration repair --status applied <version>

# Mark as reverted
supabase migration repair --status reverted <version>
```

### Squash Migrations

```bash
supabase migration squash --version <target-version>
```

## Hybrid Workflow Commands

### Initialize Hybrid Setup

Detect ORM from config, then:

**TypeScript (Drizzle):**
```bash
# Check Drizzle migrations
ls drizzle/migrations/

# Check Supabase migrations
ls supabase/migrations/

# Service range: 00100-00199
```

**Python (SQLAlchemy):**
```bash
# Check Alembic migrations
ls alembic/versions/

# Check Supabase migrations
ls supabase/migrations/

# Service range: 00200-00299
```

**Rust (SQLx):**
```bash
# Check SQLx migrations
ls migrations/

# Check Supabase migrations
ls supabase/migrations/

# Service range: 00300-00399
```

### Sync ORM to Supabase

The sync process varies by ORM but converges on `supabase/migrations/`:

**TypeScript (Drizzle):**
```bash
# 1. Generate migration
npx drizzle-kit generate

# 2. Copy to Supabase with service numbering
cp drizzle/migrations/0003_*.sql supabase/migrations/00103_node_add_feature.sql

# 3. Apply
supabase db reset
```

**Python (SQLAlchemy):**
```bash
# 1. Generate migration
alembic revision --autogenerate -m "add_feature"

# 2. Convert Python migration to raw SQL
# Option A: Run in test DB and extract SQL
alembic upgrade head --sql > temp_migration.sql

# Option B: Extract upgrade() DDL manually
# Copy CREATE TABLE, ALTER statements to SQL file

# 3. Copy to Supabase
cp temp_migration.sql supabase/migrations/00203_python_add_feature.sql

# 4. Apply
supabase db reset
```

**Rust (SQLx):**
```bash
# 1. Create migration (SQLx uses raw SQL)
sqlx migrate add add_feature

# 2. Edit migrations/XXXX_add_feature.sql with your DDL

# 3. Copy to Supabase with service numbering
cp migrations/00200_add_feature.sql supabase/migrations/00303_rust_add_feature.sql

# 4. Apply
supabase db reset
```

### Create Behavior Migration (Functions/Triggers/RLS)

This is the same for all languages:

```bash
# Create Supabase migration for non-table operations
supabase migration new add_audit_trigger

# This creates: supabase/migrations/XXXXXXXXXX_add_audit_trigger.sql
# Add your SQL for functions, triggers, RLS
```

## Migration Workflow

### Standard (No ORM)

1. **Make changes** in Supabase Studio or SQL
2. **Generate diff**:
   ```bash
   supabase db diff --use-migra -f add_users_table
   ```
3. **Review** the generated SQL
4. **Test locally**:
   ```bash
   supabase db reset
   ```
5. **Push to production**:
   ```bash
   supabase db push
   ```

### Hybrid (Single Language)

1. **Schema changes** -> Use `/kodo supa-schema` (modifies ORM schema)
2. **Generate ORM migration**:
   - TypeScript: `npx drizzle-kit generate`
   - Python: `alembic revision --autogenerate -m "description"`
   - Rust: `sqlx migrate add description`
3. **Copy to Supabase** with service numbering
4. **Add RLS/triggers** -> Create separate Supabase migration:
   ```bash
   supabase migration new add_rls_for_new_table
   ```
5. **Test locally**:
   ```bash
   supabase db reset
   ```
6. **Push to production**:
   ```bash
   supabase db push
   ```

### Hybrid (Multi-Language / Multi-Service)

For projects with multiple services sharing one database:

1. **Each service** manages its own tables via native ORM
2. **Each service** has its own migration range:
   - Node/TypeScript: 00100-00199
   - Python: 00200-00299
   - Rust: 00300-00399
3. **All migrations converge** in `supabase/migrations/`
4. **Single deploy** via `supabase db push`

```
+-----------------------------------------------------------------+
|              MULTI-SERVICE MIGRATION FLOW                       |
+-----------------------------------------------------------------+
|  TypeScript Service                Python Service               |
|  +- drizzle/migrations/            +- alembic/versions/         |
|  +- npx drizzle-kit generate       +- alembic revision --auto   |
|  +- copy -> 001XX_node_*.sql       +- convert -> 002XX_py_*.sql |
|       |                                  |                      |
+-----------------------------------------------------------------+
|                supabase/migrations/                             |
|  +- 00000_extensions.sql                                        |
|  +- 00001_core_functions.sql                                    |
|  +- 00100_node_create_users.sql                                 |
|  +- 00101_node_users_rls.sql                                    |
|  +- 00200_python_analytics.sql                                  |
|  +- 00201_python_analytics_rls.sql                              |
|  +- 00400_shared_cross_service.sql                              |
|       |                                                         |
|  supabase db push (atomic deployment)                           |
+-----------------------------------------------------------------+
```

## Migration File Structure

### Standard (Supabase Only)

```
supabase/migrations/
+-- 20240101000000_create_users.sql
+-- 20240102000000_add_profiles.sql
+-- 20240103000000_add_rls_policies.sql
+-- 20240104000000_add_indexes.sql
```

### Hybrid (Single Service)

```
project-root/
+-- drizzle/                          # TypeScript ORM
|   +-- migrations/
|       +-- 0000_create_users.sql
|       +-- meta/
+-- supabase/
    +-- migrations/                    # All converge here
        +-- 00000_extensions.sql
        +-- 00001_core_functions.sql
        +-- 00100_node_create_users.sql
        +-- 00101_node_users_rls.sql
        +-- ...
```

### Hybrid (Multi-Service)

```
project-root/
+-- services/
|   +-- node-api/                     # TypeScript service
|   |   +-- src/db/schema.ts          # Drizzle schema
|   |   +-- drizzle/migrations/
|   |       +-- 0000_users.sql
|   |
|   +-- python-analytics/             # Python service
|   |   +-- src/db/models/
|   |   +-- alembic/versions/
|   |       +-- abc123_events.py
|   |
|   +-- rust-realtime/                # Rust service
|       +-- src/db/models/
|       +-- migrations/
|           +-- 00300_channels.sql
|
+-- supabase/
    +-- migrations/                    # Unified migrations
        +-- 00000_extensions.sql       # Bootstrap
        +-- 00001_core_functions.sql   # Shared functions
        +-- 00100_node_users.sql       # From drizzle-kit
        +-- 00101_node_users_rls.sql   # Node behavior
        +-- 00200_python_events.sql    # From alembic
        +-- 00201_python_events_rls.sql
        +-- 00300_rust_channels.sql    # From sqlx
        +-- 00301_rust_channels_rls.sql
        +-- 00400_shared_views.sql     # Cross-service
```

**Service Range Numbering:**
- `00000-00099`: Bootstrap (extensions, core functions)
- `00100-00199`: TypeScript/Node service
- `00200-00299`: Python service
- `00300-00399`: Rust service
- `00400+`: Shared/cross-service migrations

**Within each range:**
- Even numbers (XX00, XX02, XX04): Schema migrations
- Odd numbers (XX01, XX03, XX05): Behavior migrations (RLS, triggers)

## Migration Templates

### Extension Setup (00000)

```sql
-- supabase/migrations/00000_extensions.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_net;
CREATE EXTENSION IF NOT EXISTS vector;
```

### Core Functions (00001)

```sql
-- supabase/migrations/00001_core_functions.sql

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- RLS helper for org_id from JWT
CREATE OR REPLACE FUNCTION public.get_org_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'org_id', '')::uuid;
$$;
```

### Table + RLS Pattern (per service)

After ORM migration creates table, add RLS in next migration:

```sql
-- supabase/migrations/00101_tablename_rls.sql

ALTER TABLE public.tablename ENABLE ROW LEVEL SECURITY;

CREATE POLICY "org_isolation_select"
ON public.tablename FOR SELECT
USING (org_id = public.get_org_id());

CREATE POLICY "org_isolation_insert"
ON public.tablename FOR INSERT
WITH CHECK (org_id = public.get_org_id());

CREATE INDEX IF NOT EXISTS idx_tablename_org_id ON public.tablename(org_id);
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md` (decision matrix)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/hybrid-orm-architecture.md` (universal patterns)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/drizzle-integration.md` (TypeScript)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/python-sqlalchemy-integration.md` (Python)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/rust-sqlx-integration.md` (Rust)

## Examples

### Standard Workflow

```
User: /kodo supa-migrate new add_products_table

Claude: Creating migration...

```bash
supabase migration new add_products_table
```

This creates an empty migration file. Do you want me to generate SQL for a products table?

If yes, I'll ask about:
- Column definitions
- RLS policies needed
- Indexes
- Triggers
```

### Hybrid Workflow (TypeScript)

```
User: /kodo supa-migrate new

Claude: I see you're using Drizzle ORM (TypeScript, service range 00100-00199).

**For table changes** (columns, indexes):
-> Use `/kodo supa-schema` to modify Drizzle schema, then generate migration

**For database behavior** (functions, triggers, RLS):
-> Create a Supabase migration:

```bash
supabase migration new <name>
```

What would you like to add?
```

### Hybrid Workflow (Python)

```
User: /kodo supa-migrate new

Claude: I see you're using SQLAlchemy ORM (Python, service range 00200-00299).

**For table changes**:
-> Use `/kodo supa-schema` to modify SQLAlchemy models, then:
1. `alembic revision --autogenerate -m "description"`
2. Convert to SQL and copy to `supabase/migrations/002XX_python_*.sql`

**For database behavior**:
-> Create a Supabase migration:

```bash
supabase migration new <name>
```

What would you like to add?
```

### Sync Status (Multi-Service)

```
User: /kodo supa-migrate status

Claude: Checking migration status for multi-service hybrid setup...

**Node Service (drizzle)** - Range: 00100-00199
- 0000_create_users.sql -> 00100_node_create_users.sql
- 0001_add_profiles.sql -> 00102_node_add_profiles.sql
- 0002_add_orders.sql <- NEW (not synced)

**Python Service (sqlalchemy)** - Range: 00200-00299
- abc123_events.py -> 00200_python_events.sql
- def456_analytics.py -> 00202_python_analytics.sql

**Supabase migrations** (`supabase/migrations/`):
- 00000_extensions.sql
- 00001_core_functions.sql
- 00100_node_create_users.sql
- 00101_node_users_rls.sql
- 00102_node_add_profiles.sql
- 00103_node_profiles_rls.sql
- 00200_python_events.sql
- 00201_python_events_rls.sql
- 00202_python_analytics.sql
- 00203_python_analytics_rls.sql

**Action needed**: Sync new Drizzle migration:

```bash
cp drizzle/migrations/0002_add_orders.sql supabase/migrations/00104_node_add_orders.sql
supabase migration new orders_rls
```
```

### Initialize Hybrid (Multi-Service)

```
User: /kodo supa-migrate init

Claude: Initializing multi-service hybrid migration structure...

**Step 1**: Create bootstrap migrations:

```bash
supabase migration new extensions
# -> 00000_extensions.sql

supabase migration new core_functions
# -> 00001_core_functions.sql
```

**Step 2**: Assign service ranges in `.kodo/config.json`:

```json
{
  "stack": {
    "sharedDatabase": {
      "enabled": true,
      "serviceRanges": {
        "server": "00100-00199",
        "api": "00200-00299",
        "rust-service": "00300-00399"
      }
    }
  }
}
```

**Step 3**: Copy existing ORM migrations with proper numbering:

TypeScript: `cp drizzle/migrations/*.sql supabase/migrations/001XX_node_*.sql`
Python: Convert alembic to `supabase/migrations/002XX_python_*.sql`
Rust: `cp migrations/*.sql supabase/migrations/003XX_rust_*.sql`

**Step 4**: Apply:

```bash
supabase db reset
```

Your multi-service hybrid setup is ready!
```

## Decision Guide: Where to Put What

| Change Type | ORM Schema | Supabase Migration |
|-------------|------------|-------------------|
| New table | Yes | Copy generated |
| New column | Yes | Copy generated |
| Column type change | Yes | Copy generated |
| Index | Yes | Copy generated |
| Foreign key | Yes | Copy generated |
| Function | No | Write SQL |
| Trigger | No | Write SQL |
| RLS Policy | No | Write SQL |
| Extension | No | Write SQL |
| Custom type/enum | No | Write SQL |
| Cross-service view | No | Write SQL (00400+) |

## Alembic -> SQL Conversion Tips

For Python projects, converting Alembic migrations to raw SQL:

**Option 1: SQL dump (recommended)**
```bash
# Run upgrade in dry-run mode
alembic upgrade head --sql > migration.sql
```

**Option 2: Extract manually**
```python
# From alembic/versions/abc123_add_feature.py
def upgrade():
    op.create_table('analytics',
        sa.Column('id', sa.UUID(), primary_key=True),
        sa.Column('org_id', sa.UUID(), nullable=False),
    )
```

Becomes:
```sql
-- supabase/migrations/00200_python_analytics.sql
CREATE TABLE analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id)
);
```

**Option 3: Use `print_schema` helper**
```python
from sqlalchemy.schema import CreateTable
print(CreateTable(Analytics.__table__).compile(dialect=postgresql.dialect()))
```
