---
name: kodo-supa-schema
description: Manage database schema using native ORM in a hybrid Supabase setup across TypeScript, Python, and Rust
---

# /kodo supa-schema - Universal Hybrid Schema Management

Manage database schema using your native ORM (Drizzle, SQLAlchemy, or SQLx) in a hybrid Supabase setup. This command works across TypeScript, Python, and Rust projects.

## What You Do

When the user runs `/kodo supa-schema [action] [args]`:

**First**: Detect the ORM from `.kodo/config.json` at `stack.workspaces.*.database.orm.name`. If ORM is `null` or missing, redirect to `/kodo supa-migrate`.

**Actions:**
- `table` - Add/modify a table in ORM schema
- `column` - Add/modify columns
- `index` - Add/modify indexes
- `relation` - Define table relations
- `generate` - Generate ORM migration
- `sync` - Sync generated migration to Supabase
- `types` - Explain type generation in hybrid setup

## ORM Detection

```json
// .kodo/config.json - Check this first!
{
  "stack": {
    "workspaces": {
      "server": {
        "language": "typescript",
        "database": {
          "orm": {
            "name": "drizzle",
            "schemaPath": "src/db/schema.ts"
          },
          "migrationStrategy": {
            "type": "hybrid",
            "serviceRange": { "start": "00100", "end": "00199" }
          }
        }
      }
    }
  }
}
```

**ORM Detection Table:**

| `orm.name` | Language | Migration Tool | Schema Location |
|------------|----------|----------------|-----------------|
| `"drizzle"` | TypeScript | drizzle-kit | `src/db/schema.ts` |
| `"sqlalchemy"` | Python | alembic | `src/db/models/*.py` |
| `"sqlx"` | Rust | sqlx-cli | `src/db/models/*.rs` |
| `null` | Any | supabase CLI | SQL only -> use `/kodo supa-migrate` |

**If ORM is NOT configured:**
```
This command requires an ORM. Use `/kodo supa-migrate` for standard Supabase-only migrations.
```

## Understanding the Hybrid Model

**What goes in your ORM schema:**
- Table definitions
- Columns with types
- Constraints (unique, notNull)
- Foreign key references
- Indexes
- Relations (for relational queries)

**What goes in Supabase migrations (`supabase/migrations/`):**
- Extensions (00000_extensions.sql)
- Functions (00001_core_functions.sql)
- Triggers (000XX_*_triggers.sql)
- RLS policies (000XX_*_rls.sql)
- Custom types

## Commands by Language

### Create/Modify Table

**User:** `/kodo supa-schema table products`

**Claude:**
1. Detect ORM from config
2. Ask standard questions:
   - What columns do you need?
   - Should it belong to an organization (multi-tenant)?
   - Do you need soft delete?
   - Audit timestamps?
3. Generate language-specific code

---

#### TypeScript (Drizzle)

```typescript
// src/db/schema.ts
import { pgTable, uuid, text, numeric, timestamp, boolean, index } from 'drizzle-orm/pg-core';
import { organizations } from './organizations';

export const products = pgTable('products', {
  id: uuid('id').primaryKey().defaultRandom(),
  orgId: uuid('org_id').references(() => organizations.id).notNull(),
  name: text('name').notNull(),
  description: text('description'),
  price: numeric('price', { precision: 10, scale: 2 }).notNull(),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  orgIdIdx: index('idx_products_org_id').on(table.orgId),
  nameIdx: index('idx_products_name').on(table.name),
}));

export type Product = typeof products.$inferSelect;
export type NewProduct = typeof products.$inferInsert;
```

---

#### Python (SQLAlchemy)

```python
# src/db/models/product.py
from sqlalchemy import Column, String, Numeric, Boolean, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid

from .base import Base, TimestampMixin

class Product(Base, TimestampMixin):
    __tablename__ = "products"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    org_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    price = Column(Numeric(10, 2), nullable=False)
    is_active = Column(Boolean, default=True)

    # Relationships
    organization = relationship("Organization", back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")

    __table_args__ = (
        Index("idx_products_org_id", "org_id"),
        Index("idx_products_name", "name"),
    )
```

```python
# src/db/models/__init__.py
from .product import Product
```

---

#### Rust (SQLx)

```rust
// src/db/models/product.rs
use sqlx::FromRow;
use uuid::Uuid;
use rust_decimal::Decimal;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Product {
    pub id: Uuid,
    pub org_id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub is_active: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateProduct {
    pub org_id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub is_active: Option<bool>,
}
```

```sql
-- migrations/00200_create_products.sql (for sqlx-cli)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id),
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_products_org_id ON products(org_id);
CREATE INDEX idx_products_name ON products(name);
```

---

### Add Column

**User:** `/kodo supa-schema column products sku`

Ask:
1. Column type? (text, integer, boolean, timestamp, uuid, etc.)
2. Required (notNull)?
3. Unique?
4. Default value?

**TypeScript:** Add to table definition
```typescript
sku: text('sku').unique(),
```

**Python:** Add to model class
```python
sku = Column(String, unique=True, nullable=True)
```

**Rust:** Add to struct and migration SQL
```rust
pub sku: Option<String>,
```

---

### Define Relation

**User:** `/kodo supa-schema relation products orderItems`

Ask: One-to-Many, Many-to-One, or Many-to-Many?

**TypeScript (Drizzle):**
```typescript
import { relations } from 'drizzle-orm';

export const productsRelations = relations(products, ({ many }) => ({
  orderItems: many(orderItems),
}));
```

**Python (SQLAlchemy):**
```python
# In Product model
order_items = relationship("OrderItem", back_populates="product")

# In OrderItem model
product = relationship("Product", back_populates="order_items")
```

**Rust (SQLx):**
SQLx doesn't have built-in relations. Use explicit queries:
```rust
// Query with JOIN
pub async fn get_product_with_order_items(pool: &PgPool, id: Uuid) -> Result<ProductWithItems> {
    // Implement with separate queries or custom JOIN
}
```

---

### Generate Migration

**User:** `/kodo supa-schema generate`

**TypeScript:**
```bash
npx drizzle-kit generate
# Output: drizzle/migrations/0003_add_products.sql
```

**Python:**
```bash
alembic revision --autogenerate -m "add_products"
# Output: alembic/versions/abc123_add_products.py
```

**Rust:**
```bash
sqlx migrate add add_products
# Output: migrations/00200_add_products.sql (edit manually)
```

---

### Sync to Supabase

**User:** `/kodo supa-schema sync`

For all languages, the workflow converges:

1. **Find new migrations** in ORM output folder
2. **Copy to Supabase** with service-range numbering:
   - TypeScript (00100-00199): `cp drizzle/migrations/0003_*.sql supabase/migrations/00103_node_add_products.sql`
   - Python (00200-00299): `cp alembic/versions/abc123_*.py supabase/migrations/00203_python_add_products.sql` (convert to SQL)
   - Rust (00300-00399): `cp migrations/00200_*.sql supabase/migrations/00303_rust_add_products.sql`

3. **Next steps:**
   ```bash
   # Create RLS policies
   supabase migration new products_rls

   # Apply migrations
   supabase db reset
   ```

---

### Type Generation

**User:** `/kodo supa-schema types`

**TypeScript (Drizzle):**
- Table types: Automatic at compile time from schema
- Supabase types: `supabase gen types typescript --local > src/types/supabase.ts`

**Python (SQLAlchemy):**
- Table types: Use Pydantic models alongside SQLAlchemy
- Supabase types: Generate TypeScript then convert, or use manual Pydantic schemas

```python
# src/schemas/product.py
from pydantic import BaseModel
from uuid import UUID
from decimal import Decimal

class ProductBase(BaseModel):
    name: str
    description: str | None = None
    price: Decimal

class ProductCreate(ProductBase):
    org_id: UUID

class ProductRead(ProductBase):
    id: UUID
    org_id: UUID
    is_active: bool

    class Config:
        from_attributes = True
```

**Rust (SQLx):**
- Table types: `#[derive(FromRow)]` with compile-time verification
- For RPC functions: Define return types manually

```rust
// Types verified at compile time with query_as!
let products = sqlx::query_as!(
    Product,
    "SELECT * FROM products WHERE org_id = $1",
    org_id
).fetch_all(pool).await?;
```

---

## Common Patterns

### Multi-Tenant Table

**TypeScript:**
```typescript
export const tenantTable = pgTable('table_name', {
  id: uuid('id').primaryKey().defaultRandom(),
  orgId: uuid('org_id').references(() => organizations.id).notNull(),
}, (table) => ({
  orgIdIdx: index('idx_tablename_org_id').on(table.orgId),
}));
```

**Python:**
```python
class TenantModel(Base, TimestampMixin):
    __tablename__ = "table_name"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    org_id = Column(UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False)

    __table_args__ = (
        Index("idx_tablename_org_id", "org_id"),
    )
```

**Rust:**
```rust
#[derive(FromRow)]
pub struct TenantModel {
    pub id: Uuid,
    pub org_id: Uuid,
}
```

### Soft Delete

**TypeScript:**
```typescript
deletedAt: timestamp('deleted_at'),
```

**Python:**
```python
deleted_at = Column(TIMESTAMP(timezone=True), nullable=True)
```

**Rust:**
```rust
pub deleted_at: Option<DateTime<Utc>>,
```

### Vector Embedding (pgvector)

**TypeScript:**
```typescript
import { vector } from 'drizzle-orm/pg-core';
embedding: vector('embedding', { dimensions: 1536 }),
```

**Python:**
```python
from pgvector.sqlalchemy import Vector
embedding = Column(Vector(1536))
```

**Rust:**
```rust
// Use pgvector crate
use pgvector::Vector;
pub embedding: Option<Vector>,
```

---

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/hybrid-orm-architecture.md` (universal patterns)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/drizzle-integration.md` (TypeScript)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/python-sqlalchemy-integration.md` (Python)
- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/references/rust-sqlx-integration.md` (Rust)

---

## Workflow Checklist

### TypeScript (Drizzle)
1. Schema updated in `src/db/schema.ts`
2. Relations defined (if needed)
3. Run `npx drizzle-kit generate`
4. Copy to Supabase: `cp drizzle/migrations/*.sql supabase/migrations/001XX_node_*.sql`
5. Create RLS migration (if new table)
6. Apply: `supabase db reset`
7. Update types: `supabase gen types typescript --local > src/types/supabase.ts`

### Python (SQLAlchemy)
1. Model created/updated in `src/db/models/*.py`
2. Model exported in `__init__.py`
3. Run `alembic revision --autogenerate -m "description"`
4. Convert to SQL and copy: `supabase/migrations/002XX_python_*.sql`
5. Create Pydantic schema (if needed)
6. Create RLS migration (if new table)
7. Apply: `supabase db reset`

### Rust (SQLx)
1. Model struct created in `src/db/models/*.rs`
2. Create migration: `sqlx migrate add description`
3. Write SQL in `migrations/*.sql`
4. Copy to Supabase: `supabase/migrations/003XX_rust_*.sql`
5. Create RLS migration (if new table)
6. Apply: `supabase db reset`
7. Run `cargo sqlx prepare` for offline verification

---

## Error Handling

### "Table already exists"
- Check if table was created directly in Supabase
- Use `supabase migration repair` to mark as applied

### "Foreign key violation"
- Ensure referenced tables are created first
- Check migration order and service range numbering

### "Type does not exist"
Custom types (enums) need Supabase migration first:

```sql
-- supabase/migrations/00000_enums.sql
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered');
```

Then use in ORM schema (all languages).
