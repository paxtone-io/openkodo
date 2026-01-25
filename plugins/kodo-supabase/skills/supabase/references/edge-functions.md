# Edge Functions Reference

## Limits

| Resource | Free | Pro/Team |
|----------|------|----------|
| CPU time | 2s | 2s |
| Wall clock | 150s | 400s |
| Memory | 256 MB | 256 MB |
| Bundle size | 20 MB | 20 MB |
| Invocations/month | 500K | 2M (then $2/1M) |
| Concurrent executions | 50 | Scales |

## WebSocket Support (v3)

Inbound WebSocket connections:

```typescript
Deno.serve((req) => {
  const upgrade = req.headers.get("upgrade") || "";
  if (upgrade.toLowerCase() !== "websocket") {
    return new Response("Expected WebSocket", { status: 426 });
  }

  const { socket, response } = Deno.upgradeWebSocket(req);

  socket.onopen = () => console.log("Client connected");
  socket.onmessage = (e) => {
    socket.send(`Echo: ${e.data}`);
  };
  socket.onclose = () => console.log("Client disconnected");

  return response;
});
```

Outbound WebSocket connections:

```typescript
const ws = new WebSocket("wss://external-service.com/ws");
ws.onopen = () => ws.send("Hello");
ws.onmessage = (e) => console.log(e.data);
```

**Limitation**: WebSocket connections count against wall clock time (400s max on paid).

## Background Tasks

Use `EdgeRuntime.waitUntil()` to continue processing after returning response:

```typescript
serve(async (req) => {
  const payload = await req.json();

  // Return immediately (reduces user-perceived latency)
  const response = new Response(JSON.stringify({ status: 'accepted' }));

  // Continue processing in background
  EdgeRuntime.waitUntil((async () => {
    await processData(payload);
    await sendNotifications(payload);
    await updateAnalytics(payload);
  })());

  return response;
});
```

**Note**: Background tasks share the same wall clock limit (150s/400s total).

## NPM Package Compatibility

### Works
- Pure JavaScript packages via `npm:` specifier
- Most TypeScript packages
- Packages using Web APIs (fetch, crypto, etc.)

```typescript
import Stripe from 'npm:stripe@14.0.0';
import { z } from 'npm:zod@3.22.0';
import OpenAI from 'npm:openai@4.0.0';
```

### Doesn't Work
- Native binaries (sharp, libvips, bcrypt with native)
- Node.js-specific APIs (fs, child_process, cluster)
- Packages requiring `node-gyp` compilation
- Multi-threading packages

**Alternative for image processing**: Use Supabase Storage image transforms or call external service.

## Import Maps

Create `supabase/functions/import_map.json`:

```json
{
  "imports": {
    "@supabase/supabase-js": "https://esm.sh/@supabase/supabase-js@2",
    "stripe": "npm:stripe@14.0.0",
    "zod": "npm:zod@3.22.0"
  }
}
```

Configure in `supabase/config.toml`:

```toml
[functions]
import_map = "./functions/import_map.json"
```

## Regional Invocation

By default, Edge Functions run globally (nearest region to user). For database-heavy operations, pin to database region:

### Client-side

```typescript
const { data } = await supabase.functions.invoke('my-function', {
  headers: { 'x-region': 'us-east-1' }
});
```

### Using functionRegion option

```typescript
const supabase = createClient(url, key, {
  global: {
    headers: { 'x-region': 'eu-west-2' }
  }
});
```

### Available Regions
us-east-1, us-west-1, eu-west-1, eu-west-2, eu-west-3, eu-central-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-2, ap-south-1, sa-east-1

## Secrets Management

Set secrets via CLI:

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_live_xxx
supabase secrets set OPENAI_API_KEY=sk-xxx
```

Access in function:

```typescript
const apiKey = Deno.env.get('OPENAI_API_KEY');
```

**Built-in secrets** (automatically available):
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_DB_URL`

## Error Handling

```typescript
serve(async (req) => {
  try {
    // Function logic
    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    console.error('Function error:', error);

    // Return appropriate status codes
    if (error instanceof ValidationError) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
```

## CORS Configuration

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Your logic here
  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
});
```

## Deployment

```bash
# Deploy single function
supabase functions deploy my-function

# Deploy all functions
supabase functions deploy

# Deploy with specific import map
supabase functions deploy my-function --import-map ./import_map.json
```

## Local Development

```bash
# Start local Supabase
supabase start

# Serve functions locally with hot reload
supabase functions serve --env-file .env.local

# Test specific function
curl -i --location --request POST 'http://localhost:54321/functions/v1/my-function' \
  --header 'Authorization: Bearer <ANON_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{"name":"test"}'
```

## Performance Tips

1. **Minimize cold starts**: Keep bundle size small, avoid unnecessary imports
2. **Reuse connections**: Initialize Supabase client outside handler
3. **Use regional pinning**: For database operations, pin to DB region
4. **Batch operations**: Combine multiple DB writes into single transaction
5. **Return early**: Use `waitUntil()` for non-critical background work
