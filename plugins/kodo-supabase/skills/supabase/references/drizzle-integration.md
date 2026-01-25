# Drizzle ORM Integration with Supabase

## Overview

Drizzle is a TypeScript-first ORM that provides type-safe database access with SQL-like syntax. When used with Supabase, it handles schema definition and type-safe queries while Supabase manages database behavior (triggers, functions, RLS).

## Setup

### Installation

```bash
pnpm add drizzle-orm postgres
pnpm add -D drizzle-kit
```

### Configuration

```typescript
// drizzle.config.ts
import type { Config } from 'drizzle-kit';

export default {
  schema: './src/db/schema.ts',
  out: './drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    // For local development
    url: process.env.DATABASE_URL!,
  },
  // Recommended settings
  verbose: true,
  strict: true,
} satisfies Config;
```

### Environment Variables

```env
# Local development (direct connection)
DATABASE_URL="postgresql://postgres:postgres@localhost:54321/postgres"

# Production (via Supabase connection pooler)
DATABASE_URL="postgres://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true"

# Direct connection (for migrations only)
DATABASE_URL_DIRECT="postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres"
```

## Schema Definition Patterns

### Basic Table

```typescript
// src/db/schema.ts
import { pgTable, uuid, text, timestamp, boolean, integer } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').unique().notNull(),
  fullName: text('full_name'),
  avatarUrl: text('avatar_url'),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Infer types
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
```

### Table with Foreign Keys

```typescript
export const profiles = pgTable('profiles', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id')
    .references(() => users.id, { onDelete: 'cascade' })
    .notNull()
    .unique(),
  bio: text('bio'),
  website: text('website'),
  location: text('location'),
});

export type Profile = typeof profiles.$inferSelect;
```

### Table with Indexes

```typescript
import { pgTable, uuid, text, timestamp, index } from 'drizzle-orm/pg-core';

export const documents = pgTable('documents', {
  id: uuid('id').primaryKey().defaultRandom(),
  orgId: uuid('org_id').notNull(),
  title: text('title').notNull(),
  content: text('content'),
  status: text('status').default('draft'),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  // Indexes for RLS performance
  orgIdIdx: index('idx_documents_org_id').on(table.orgId),
  statusIdx: index('idx_documents_status').on(table.status),
  // Composite index
  orgStatusIdx: index('idx_documents_org_status').on(table.orgId, table.status),
}));
```

### Enums

```typescript
import { pgEnum } from 'drizzle-orm/pg-core';

export const orderStatusEnum = pgEnum('order_status', [
  'pending',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
]);

export const orders = pgTable('orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  status: orderStatusEnum('status').default('pending'),
  // ...
});
```

### Using Extensions (Vector Search)

```typescript
import { pgTable, uuid, text, index } from 'drizzle-orm/pg-core';
import { vector } from 'drizzle-orm/pg-core';

// Requires: CREATE EXTENSION IF NOT EXISTS vector; in Supabase migrations

export const embeddings = pgTable('embeddings', {
  id: uuid('id').primaryKey().defaultRandom(),
  content: text('content').notNull(),
  embedding: vector('embedding', { dimensions: 1536 }),
}, (table) => ({
  // HNSW index for fast similarity search
  embeddingIdx: index('idx_embeddings_vector')
    .using('hnsw', table.embedding.op('vector_cosine_ops')),
}));
```

## Client Setup

### Basic Client

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const connectionString = process.env.DATABASE_URL!;

// Create postgres connection
const client = postgres(connectionString, {
  max: 10, // Connection pool size
  idle_timeout: 20,
  connect_timeout: 10,
});

// Create drizzle client with schema for relational queries
export const db = drizzle(client, { schema });

// Export types
export * from './schema';
```

### With Transaction Support

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const connectionString = process.env.DATABASE_URL!;
const client = postgres(connectionString);

export const db = drizzle(client, { schema });

// Transaction helper with retry
export async function withTransaction<T>(
  fn: (tx: typeof db) => Promise<T>,
  options?: { maxRetries?: number }
): Promise<T> {
  const maxRetries = options?.maxRetries ?? 3;
  let attempts = 0;

  while (attempts < maxRetries) {
    try {
      return await db.transaction(fn);
    } catch (error) {
      attempts++;
      if (attempts >= maxRetries) throw error;
      // Exponential backoff
      await new Promise(r => setTimeout(r, Math.pow(2, attempts) * 100));
    }
  }
  throw new Error('Transaction failed after max retries');
}
```

## Query Patterns

### Select Queries

```typescript
import { eq, and, or, gt, lt, like, inArray, isNull } from 'drizzle-orm';
import { db, users, documents } from './db';

// Simple select
const allUsers = await db.select().from(users);

// Select with where
const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.isActive, true));

// Select specific columns
const userEmails = await db
  .select({ id: users.id, email: users.email })
  .from(users);

// Complex where
const filteredDocs = await db
  .select()
  .from(documents)
  .where(
    and(
      eq(documents.orgId, orgId),
      or(
        eq(documents.status, 'published'),
        eq(documents.status, 'draft')
      ),
      gt(documents.createdAt, sevenDaysAgo)
    )
  );

// Like query
const searchResults = await db
  .select()
  .from(documents)
  .where(like(documents.title, `%${searchTerm}%`));
```

### Insert Queries

```typescript
// Single insert
const [newUser] = await db
  .insert(users)
  .values({
    email: 'user@example.com',
    fullName: 'John Doe',
  })
  .returning();

// Bulk insert
const newUsers = await db
  .insert(users)
  .values([
    { email: 'user1@example.com', fullName: 'User One' },
    { email: 'user2@example.com', fullName: 'User Two' },
  ])
  .returning();

// Upsert (insert or update)
const upserted = await db
  .insert(users)
  .values({ email: 'user@example.com', fullName: 'Updated Name' })
  .onConflictDoUpdate({
    target: users.email,
    set: { fullName: 'Updated Name', updatedAt: new Date() },
  })
  .returning();
```

### Update Queries

```typescript
// Update by condition
const updated = await db
  .update(users)
  .set({ isActive: false, updatedAt: new Date() })
  .where(eq(users.id, userId))
  .returning();

// Bulk update
await db
  .update(documents)
  .set({ status: 'archived' })
  .where(
    and(
      eq(documents.orgId, orgId),
      lt(documents.createdAt, oneYearAgo)
    )
  );
```

### Delete Queries

```typescript
// Delete by condition
await db.delete(users).where(eq(users.id, userId));

// Soft delete (update deletedAt)
await db
  .update(users)
  .set({ deletedAt: new Date() })
  .where(eq(users.id, userId));
```

### Relational Queries

```typescript
// Define relations in schema
import { relations } from 'drizzle-orm';

export const usersRelations = relations(users, ({ one, many }) => ({
  profile: one(profiles, {
    fields: [users.id],
    references: [profiles.userId],
  }),
  documents: many(documents),
}));

export const documentsRelations = relations(documents, ({ one }) => ({
  author: one(users, {
    fields: [documents.authorId],
    references: [users.id],
  }),
}));

// Query with relations
const usersWithProfiles = await db.query.users.findMany({
  with: {
    profile: true,
    documents: {
      where: eq(documents.status, 'published'),
      limit: 5,
    },
  },
});
```

### Joins

```typescript
// Inner join
const usersWithOrders = await db
  .select({
    user: users,
    order: orders,
  })
  .from(users)
  .innerJoin(orders, eq(users.id, orders.userId));

// Left join
const usersWithOptionalProfiles = await db
  .select({
    user: users,
    profile: profiles,
  })
  .from(users)
  .leftJoin(profiles, eq(users.id, profiles.userId));
```

## Calling Supabase Database Functions

### Pattern 1: Direct SQL Call

```typescript
import { sql } from 'drizzle-orm';
import { db } from './db';

// Simple function call
const result = await db.execute<{ total: number }>(
  sql`SELECT calculate_order_total(${orderId}::uuid) as total`
);
const total = result.rows[0].total;
```

### Pattern 2: Type-Safe Wrapper

```typescript
// src/db/functions/orders.ts
import { sql } from 'drizzle-orm';
import { db } from '../index';

interface OrderTotal {
  subtotal: number;
  tax: number;
  total: number;
}

export async function calculateOrderTotal(orderId: string): Promise<OrderTotal> {
  const result = await db.execute<OrderTotal>(
    sql`SELECT * FROM calculate_order_total(${orderId}::uuid)`
  );
  return result.rows[0];
}
```

### Pattern 3: Function Returning SETOF

```typescript
// src/db/functions/analytics.ts
import { sql } from 'drizzle-orm';
import { db } from '../index';

interface DailyStats {
  date: string;
  orderCount: number;
  revenue: number;
}

export async function getDailyStats(
  orgId: string,
  startDate: Date,
  endDate: Date
): Promise<DailyStats[]> {
  const result = await db.execute<DailyStats>(
    sql`
      SELECT
        date::text,
        order_count as "orderCount",
        revenue
      FROM get_daily_stats(
        ${orgId}::uuid,
        ${startDate.toISOString()}::date,
        ${endDate.toISOString()}::date
      )
    `
  );
  return result.rows;
}
```

### Pattern 4: Parameterized Queries

```typescript
// Safe parameterized query
export async function searchProducts(
  searchTerm: string,
  category: string | null,
  minPrice: number | null,
  maxPrice: number | null,
  limit = 20
): Promise<Product[]> {
  const result = await db.execute<Product>(
    sql`
      SELECT * FROM search_products(
        ${searchTerm},
        ${category},
        ${minPrice},
        ${maxPrice},
        ${limit}
      )
    `
  );
  return result.rows;
}
```

## Transactions

### Basic Transaction

```typescript
import { db, users, profiles } from './db';

await db.transaction(async (tx) => {
  const [newUser] = await tx
    .insert(users)
    .values({ email: 'user@example.com' })
    .returning();

  await tx.insert(profiles).values({
    userId: newUser.id,
    bio: 'New user profile',
  });
});
```

### Transaction with Rollback

```typescript
try {
  await db.transaction(async (tx) => {
    await tx.insert(orders).values(orderData);

    // Deduct inventory
    const [item] = await tx
      .update(inventory)
      .set({ quantity: sql`quantity - ${orderQuantity}` })
      .where(eq(inventory.productId, productId))
      .returning();

    if (item.quantity < 0) {
      throw new Error('Insufficient inventory');
    }
  });
} catch (error) {
  // Transaction automatically rolled back
  console.error('Order failed:', error);
}
```

### Nested Transactions (Savepoints)

```typescript
await db.transaction(async (tx) => {
  await tx.insert(users).values(userData);

  try {
    // Creates savepoint
    await tx.transaction(async (nestedTx) => {
      await nestedTx.insert(profiles).values(profileData);
      // This might fail
      await nestedTx.insert(settings).values(settingsData);
    });
  } catch (error) {
    // Only nested transaction rolls back
    console.log('Profile creation failed, but user created');
  }
});
```

## Migration Commands

### Generate Migration

```bash
# Generate migration from schema changes
npx drizzle-kit generate

# With custom name
npx drizzle-kit generate --name add_products_table
```

### Apply Migrations

```bash
# Apply all pending migrations
npx drizzle-kit migrate

# Or use Supabase CLI (recommended for hybrid setup)
supabase db reset  # Local
supabase db push   # Remote
```

### Introspect Existing Database

```bash
# Generate schema from existing database
npx drizzle-kit introspect
```

## Integration with Supabase Auth

### Getting User ID in Queries

```typescript
// In Edge Function or server with Supabase client
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(url, anonKey);

// Get user from JWT
const { data: { user }, error } = await supabase.auth.getUser(token);

if (user) {
  // Use Drizzle with user context
  const userDocs = await db
    .select()
    .from(documents)
    .where(eq(documents.authorId, user.id));
}
```

### Service Role Bypass (Admin Operations)

```typescript
// Use service role for admin operations that bypass RLS
const serviceClient = postgres(process.env.DATABASE_URL_SERVICE!, {
  // Service role connection
});

const adminDb = drizzle(serviceClient, { schema });

// This query runs with elevated privileges
const allUsers = await adminDb.select().from(users);
```

## Performance Tips

### 1. Use Prepared Statements

```typescript
import { db } from './db';
import { sql } from 'drizzle-orm';

// Prepared statement (reusable)
const getUserById = db
  .select()
  .from(users)
  .where(eq(users.id, sql.placeholder('id')))
  .prepare('get_user_by_id');

// Execute prepared statement
const user = await getUserById.execute({ id: userId });
```

### 2. Batch Operations

```typescript
// Batch insert (more efficient than individual inserts)
await db.insert(orders).values(orderArray);

// Batch update with CASE
await db.execute(sql`
  UPDATE products
  SET price = CASE id
    ${sql.join(
      priceUpdates.map(u => sql`WHEN ${u.id}::uuid THEN ${u.price}`),
      sql` `
    )}
  END
  WHERE id IN (${sql.join(priceUpdates.map(u => sql`${u.id}::uuid`), sql`, `)})
`);
```

### 3. Pagination

```typescript
// Offset pagination (simple but slow for large offsets)
const page = await db
  .select()
  .from(documents)
  .limit(20)
  .offset(page * 20);

// Cursor pagination (better for large datasets)
const page = await db
  .select()
  .from(documents)
  .where(gt(documents.createdAt, lastSeenTimestamp))
  .orderBy(documents.createdAt)
  .limit(20);
```

### 4. Select Only Needed Columns

```typescript
// Bad: fetches all columns
const docs = await db.select().from(documents);

// Good: fetches only needed columns
const docs = await db
  .select({ id: documents.id, title: documents.title })
  .from(documents);
```

## Error Handling

```typescript
import { PostgresError } from 'postgres';

try {
  await db.insert(users).values({ email: 'duplicate@example.com' });
} catch (error) {
  if (error instanceof PostgresError) {
    switch (error.code) {
      case '23505': // unique_violation
        throw new Error('Email already exists');
      case '23503': // foreign_key_violation
        throw new Error('Referenced record not found');
      case '23502': // not_null_violation
        throw new Error('Required field missing');
      default:
        throw error;
    }
  }
  throw error;
}
```
