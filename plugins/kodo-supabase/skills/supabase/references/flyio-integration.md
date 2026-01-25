# Fly.io Integration Reference

## Regional Co-location

**Critical**: Deploy Fly.io apps in the same region as Supabase database.

| Supabase Region | Fly.io Region | Location |
|-----------------|---------------|----------|
| us-east-1 | iad | Virginia |
| us-west-1 | sjc | San Jose |
| eu-west-1 | dub | Dublin |
| eu-west-2 | lhr | London |
| eu-central-1 | fra | Frankfurt |
| ap-southeast-1 | sin | Singapore |
| ap-northeast-1 | nrt | Tokyo |
| ap-south-1 | bom | Mumbai |

**Latency expectations:**
- Same region: 5-20ms
- Cross-continent: 150-350ms+

## Connection Configuration

### Connection String Selection

| Type | Port | Use Case |
|------|------|----------|
| Transaction Pooler | 6543 | Serverless, Fly.io apps |
| Session Pooler | 5432 | Prepared statements, IPv4 |
| Direct | 5432 | Migrations only (IPv6) |

### Prisma Configuration

```env
# .env
DATABASE_URL="postgres://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres"
```

```prisma
// prisma/schema.prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

### Drizzle Configuration

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  driver: 'pg',
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!
  }
})
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

const client = postgres(process.env.DATABASE_URL!, {
  prepare: false  // Required for transaction pooler
})

export const db = drizzle(client)
```

## Fly Secrets

```bash
# Set Supabase credentials
fly secrets set SUPABASE_URL="https://[PROJECT].supabase.co"
fly secrets set SUPABASE_ANON_KEY="eyJ..."
fly secrets set SUPABASE_SERVICE_ROLE_KEY="eyJ..."
fly secrets set DATABASE_URL="postgres://..."
fly secrets set DIRECT_URL="postgresql://..."
```

## fly.toml Configuration

```toml
app = "my-app"
primary_region = "iad"  # Match Supabase region

[build]
  dockerfile = "Dockerfile"

[env]
  NODE_ENV = "production"
  PORT = "3000"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512
```

## JWT Verification

Verify Supabase tokens on Fly.io backend:

```typescript
// src/lib/auth.ts
import jwt from 'jsonwebtoken'
import jwksClient from 'jwks-rsa'

const PROJECT_REF = process.env.SUPABASE_URL!
  .replace('https://', '')
  .replace('.supabase.co', '')

const client = jwksClient({
  jwksUri: `https://${PROJECT_REF}.supabase.co/auth/v1/.well-known/jwks.json`,
  cache: true,
  cacheMaxAge: 600000  // 10 minutes
})

export async function verifySupabaseToken(token: string) {
  const decoded = jwt.decode(token, { complete: true })

  if (!decoded || !decoded.header.kid) {
    throw new Error('Invalid token format')
  }

  const key = await client.getSigningKey(decoded.header.kid)

  return jwt.verify(token, key.getPublicKey(), {
    audience: 'authenticated',
    issuer: `https://${PROJECT_REF}.supabase.co/auth/v1`
  }) as {
    sub: string
    email: string
    role: string
    // Custom claims from hooks
    org_id?: string
    user_role?: string
  }
}
```

### Express Middleware

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express'
import { verifySupabaseToken } from '../lib/auth'

export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'No token provided' })
  }

  try {
    req.user = await verifySupabaseToken(token)
    next()
  } catch (error) {
    console.error('Auth error:', error)
    res.status(401).json({ error: 'Invalid token' })
  }
}

// Usage
app.get('/api/protected', requireAuth, (req, res) => {
  res.json({ userId: req.user.sub })
})
```

## Service Role Operations

For admin operations bypassing RLS:

```typescript
// src/lib/supabase-admin.ts
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Usage: bypass RLS for admin operations
const { data } = await supabaseAdmin
  .from('users')
  .select('*')
  .eq('org_id', orgId)
```

## Background Worker Pattern

### Always-On Worker

```typescript
// src/worker.ts
import { supabaseAdmin } from './lib/supabase-admin'

async function processQueue() {
  while (true) {
    const { data: messages } = await supabaseAdmin.rpc('read_queue', {
      queue_name: 'heavy_jobs',
      visibility_timeout: 300,
      batch_size: 10
    })

    for (const msg of messages || []) {
      try {
        await processHeavyJob(msg.message)
        await supabaseAdmin.rpc('delete_from_queue', {
          queue_name: 'heavy_jobs',
          msg_id: msg.msg_id
        })
      } catch (error) {
        console.error('Job failed:', error)
      }
    }

    // Wait before next poll
    await new Promise(r => setTimeout(r, 1000))
  }
}

processQueue().catch(console.error)
```

### fly.toml for Worker

```toml
[processes]
  web = "node dist/server.js"
  worker = "node dist/worker.js"

[[services]]
  processes = ["web"]
  internal_port = 3000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

## Webhook Handling

### Idempotent Webhook Handler

```typescript
// src/routes/webhooks.ts
import { Router } from 'express'
import { supabaseAdmin } from '../lib/supabase-admin'

const router = Router()

router.post('/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature']
  const payload = req.body

  // Verify webhook signature
  const event = stripe.webhooks.constructEvent(
    payload,
    sig,
    process.env.STRIPE_WEBHOOK_SECRET!
  )

  // Idempotency check
  const { data: existing } = await supabaseAdmin
    .from('processed_webhooks')
    .select('id')
    .eq('event_id', event.id)
    .single()

  if (existing) {
    return res.status(200).json({ received: true, duplicate: true })
  }

  // Record webhook before processing
  await supabaseAdmin
    .from('processed_webhooks')
    .insert({ event_id: event.id, type: event.type })

  // Return quickly, process async
  res.status(200).json({ received: true })

  // Background processing
  processStripeEvent(event).catch(console.error)
})

export default router
```

## Database Webhook to Fly.io

```sql
-- Trigger Fly.io endpoint on database changes
CREATE OR REPLACE FUNCTION notify_flyio()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://my-app.fly.dev/webhooks/database',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'X-Webhook-Secret', current_setting('app.webhook_secret', true)
    ),
    body := jsonb_build_object(
      'type', TG_OP,
      'table', TG_TABLE_NAME,
      'record', CASE
        WHEN TG_OP = 'DELETE' THEN row_to_json(OLD)
        ELSE row_to_json(NEW)
      END
    )
  );

  RETURN COALESCE(NEW, OLD);
END;
$$;
```

## Health Check Endpoint

```typescript
// src/routes/health.ts
import { Router } from 'express'
import { supabaseAdmin } from '../lib/supabase-admin'

const router = Router()

router.get('/health', async (req, res) => {
  try {
    // Check database connection
    const { error } = await supabaseAdmin
      .from('health_check')
      .select('id')
      .limit(1)

    if (error) throw error

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    })
  }
})

export default router
```

## Scaling Configuration

### Auto-scaling

```toml
[http_service]
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

  [http_service.concurrency]
    type = "requests"
    hard_limit = 250
    soft_limit = 200

[[services.tcp_checks]]
  grace_period = "5s"
  interval = "10s"
  timeout = "2s"
```

### Manual Scaling

```bash
# Scale to 3 machines
fly scale count 3

# Scale machine size
fly scale vm shared-cpu-2x

# Scale memory
fly scale memory 1024
```

## Connection Pooling Best Practices

1. **Use transaction pooler** for Fly.io apps (port 6543)
2. **Disable prepared statements** in transaction mode
3. **Set appropriate pool size**: 40-80% of max connections
4. **Monitor connection usage** in Supabase dashboard
5. **Use connection string for reads**, direct for migrations

```typescript
// Connection with appropriate pool size
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,  // Adjust based on Fly.io machine count
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000
})
```

## Deployment Checklist

- [ ] Fly.io region matches Supabase region
- [ ] DATABASE_URL uses transaction pooler (port 6543)
- [ ] DIRECT_URL set for migrations
- [ ] Prepared statements disabled
- [ ] Service role key stored as secret
- [ ] Health check endpoint configured
- [ ] Webhook secrets configured
- [ ] Connection pool size appropriate
- [ ] Auto-scaling configured
