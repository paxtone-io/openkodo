# Queues and Cron Reference

## Supabase Queues (pgmq)

PostgreSQL-based message queue using the pgmq extension. Pull-based FIFO queue stored in your database.

### Enable Extension

```sql
CREATE EXTENSION IF NOT EXISTS pgmq;
```

### Create Queue

```sql
SELECT pgmq.create('email_jobs');
SELECT pgmq.create('heavy_tasks');
```

### Send Messages

```sql
-- Single message
SELECT pgmq.send('email_jobs',
  '{"to": "user@example.com", "template": "welcome"}'::jsonb
);

-- With delay (seconds)
SELECT pgmq.send('email_jobs',
  '{"to": "user@example.com", "template": "reminder"}'::jsonb,
  300  -- 5 minute delay
);

-- Batch send
SELECT pgmq.send_batch('email_jobs', ARRAY[
  '{"to": "a@example.com"}'::jsonb,
  '{"to": "b@example.com"}'::jsonb
]);
```

### Read Messages

```sql
-- Read with visibility timeout
SELECT * FROM pgmq.read(
  'email_jobs',  -- queue name
  30,            -- visibility timeout (seconds)
  5              -- batch size
);

-- Returns:
-- msg_id | read_ct | enqueued_at | vt | message
```

### Acknowledge/Delete

```sql
-- Delete after successful processing
SELECT pgmq.delete('email_jobs', msg_id);

-- Archive instead of delete
SELECT pgmq.archive('email_jobs', msg_id);

-- Batch delete
SELECT pgmq.delete('email_jobs', ARRAY[1, 2, 3]);
```

### Message Lifecycle

1. **Send**: Message added to queue
2. **Read**: Message becomes invisible for `visibility_timeout` seconds
3. **Process**: Your code handles the message
4. **Delete**: Remove from queue on success
5. **Return**: If not deleted, message becomes visible again after timeout

### Queue from Client

```typescript
// Send to queue
const { data, error } = await supabase.rpc('send_to_queue', {
  queue_name: 'email_jobs',
  message: { to: 'user@example.com', template: 'welcome' }
})

// Wrapper function
CREATE OR REPLACE FUNCTION send_to_queue(queue_name text, message jsonb)
RETURNS bigint
LANGUAGE sql
AS $$
  SELECT pgmq.send(queue_name, message);
$$;
```

### Consumer Pattern (Edge Function + Cron)

```typescript
// supabase/functions/process-queue/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Read batch of messages
  const { data: messages } = await supabase.rpc('read_queue', {
    queue_name: 'email_jobs',
    visibility_timeout: 60,
    batch_size: 10
  })

  for (const msg of messages || []) {
    try {
      await sendEmail(msg.message)
      await supabase.rpc('delete_from_queue', {
        queue_name: 'email_jobs',
        msg_id: msg.msg_id
      })
    } catch (error) {
      console.error('Failed:', error)
      // Message returns to queue after visibility timeout
    }
  }

  return new Response(JSON.stringify({ processed: messages?.length || 0 }))
})
```

### Helper Functions

```sql
CREATE OR REPLACE FUNCTION read_queue(
  queue_name text,
  visibility_timeout int DEFAULT 30,
  batch_size int DEFAULT 1
)
RETURNS TABLE (msg_id bigint, message jsonb)
LANGUAGE sql
AS $$
  SELECT msg_id, message FROM pgmq.read(queue_name, visibility_timeout, batch_size);
$$;

CREATE OR REPLACE FUNCTION delete_from_queue(queue_name text, msg_id bigint)
RETURNS boolean
LANGUAGE sql
AS $$
  SELECT pgmq.delete(queue_name, msg_id);
$$;
```

## pg_cron Scheduling

PostgreSQL job scheduler for recurring tasks.

### Enable Extension

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### Schedule Syntax

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday = 0)
│ │ │ │ │
* * * * *
```

### Common Schedules

```sql
-- Every minute
SELECT cron.schedule('job-name', '* * * * *', $$SQL$$);

-- Every 5 minutes
SELECT cron.schedule('job-name', '*/5 * * * *', $$SQL$$);

-- Every hour at minute 0
SELECT cron.schedule('job-name', '0 * * * *', $$SQL$$);

-- Daily at midnight UTC
SELECT cron.schedule('job-name', '0 0 * * *', $$SQL$$);

-- Weekly on Sunday at 2am UTC
SELECT cron.schedule('job-name', '0 2 * * 0', $$SQL$$);

-- Monthly on 1st at 3am UTC
SELECT cron.schedule('job-name', '0 3 1 * *', $$SQL$$);

-- Every 30 seconds (Postgres 15.1.1.61+)
SELECT cron.schedule('job-name', '30 seconds', $$SQL$$);
```

### Execute SQL

```sql
-- Run SQL directly
SELECT cron.schedule(
  'cleanup-old-records',
  '0 3 * * *',  -- Daily at 3am UTC
  $$DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days'$$
);
```

### Call Database Function

```sql
SELECT cron.schedule(
  'generate-reports',
  '0 6 * * 1',  -- Monday at 6am UTC
  $$SELECT generate_weekly_report()$$
);
```

### Invoke Edge Function

```sql
SELECT cron.schedule(
  'process-queue',
  '* * * * *',  -- Every minute
  $$
  SELECT net.http_post(
    url := 'https://PROJECT.supabase.co/functions/v1/process-queue',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true),
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb
  )
  $$
);
```

### Manage Jobs

```sql
-- List all jobs
SELECT * FROM cron.job;

-- View job history
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 20;

-- Unschedule job
SELECT cron.unschedule('job-name');

-- Or by job ID
SELECT cron.unschedule(42);
```

### Set Service Role Key

```sql
-- Store service role key for Edge Function calls
ALTER DATABASE postgres SET "app.settings.service_role_key" = 'your-service-role-key';
```

## Combined Pattern: Queue + Cron + Edge Function

```
┌────────────┐     ┌─────────────┐     ┌──────────────┐
│  Database  │────▶│    Queue    │────▶│ Edge Function│
│  Trigger   │     │   (pgmq)    │     │  (Consumer)  │
└────────────┘     └─────────────┘     └──────────────┘
                          ▲
                          │
                   ┌──────┴──────┐
                   │   pg_cron   │
                   │ (every min) │
                   └─────────────┘
```

### Implementation

**1. Trigger adds to queue:**

```sql
CREATE OR REPLACE FUNCTION queue_new_order()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM pgmq.send('order_processing', jsonb_build_object(
    'order_id', NEW.id,
    'user_id', NEW.user_id,
    'total', NEW.total
  ));
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_order_created
  AFTER INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION queue_new_order();
```

**2. Cron triggers processor:**

```sql
SELECT cron.schedule(
  'process-orders',
  '* * * * *',
  $$SELECT net.http_post(
    url := 'https://PROJECT.supabase.co/functions/v1/process-orders',
    headers := '{"Authorization": "Bearer SERVICE_ROLE_KEY"}'::jsonb
  )$$
);
```

**3. Edge Function processes:**

```typescript
serve(async (req) => {
  const supabase = createClient(url, serviceKey)

  const { data: messages } = await supabase.rpc('read_queue', {
    queue_name: 'order_processing',
    visibility_timeout: 120,
    batch_size: 10
  })

  for (const msg of messages || []) {
    await processOrder(msg.message)
    await supabase.rpc('delete_from_queue', {
      queue_name: 'order_processing',
      msg_id: msg.msg_id
    })
  }

  return new Response('ok')
})
```

## Limitations

### pgmq Limitations
- No priority queues
- No built-in dead letter queue
- No push notifications (polling only)
- Queue stored in database (impacts DB performance at scale)

### pg_cron Limitations
- Maximum 32 concurrent jobs (each uses a connection)
- 10 minute recommended execution limit
- GMT timezone by default
- May delay under heavy DB load

## When to Use BullMQ on Fly.io

Use BullMQ + Redis instead when:

- **Priority queues** needed
- **Rate limiting** per job type
- **Complex retry strategies** with exponential backoff
- **Job dependencies** (run job B after job A completes)
- **High throughput** (>1000 jobs/minute)
- **Dead letter queues** with manual inspection
- **Job progress tracking**

```typescript
// Fly.io worker with BullMQ
import { Worker, Queue } from 'bullmq'
import Redis from 'ioredis'

const connection = new Redis(process.env.REDIS_URL)

const worker = new Worker('orders', async (job) => {
  await processOrder(job.data)
}, {
  connection,
  concurrency: 10,
  limiter: {
    max: 100,
    duration: 1000
  }
})

worker.on('failed', (job, err) => {
  console.error(`Job ${job.id} failed:`, err)
})
```
