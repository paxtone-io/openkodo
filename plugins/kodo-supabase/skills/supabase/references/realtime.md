# Realtime Reference

## Overview

Supabase Realtime provides WebSocket-based communication with four primitives: Broadcast, Presence, Postgres Changes, and Channels.

## Limits by Plan

| Metric | Free | Pro | Team/Enterprise |
|--------|------|-----|-----------------|
| Concurrent connections | 200 | 500 | 10,000+ |
| Messages/second | 100 | 500-2,500 | 2,500+ |
| Broadcast payload | 256 KB | 3 MB | 3 MB+ |
| Presence keys/object | 10 | 10 | 10 |
| Channel joins/second | 100 | 500 | 500+ |

**Note**: Postgres Changes are processed on a single thread—compute upgrades won't improve throughput.

## Channels

Basic channel subscription:

```typescript
const channel = supabase.channel('room-1')

channel
  .on('broadcast', { event: 'cursor' }, (payload) => {
    console.log('Cursor update:', payload)
  })
  .subscribe()
```

### Private Channels with RLS

```typescript
// Requires RLS policy on realtime.messages
const channel = supabase.channel('private-room', {
  config: {
    private: true
  }
})
```

## Broadcast

Client-to-client messaging without database persistence:

```typescript
// Send message
channel.send({
  type: 'broadcast',
  event: 'cursor-move',
  payload: { x: 100, y: 200, userId: 'user-123' }
})

// Receive messages
channel.on('broadcast', { event: 'cursor-move' }, ({ payload }) => {
  updateCursor(payload.userId, payload.x, payload.y)
})
```

### Self-send and Acknowledgment

```typescript
const channel = supabase.channel('room', {
  config: {
    broadcast: {
      self: true,      // Receive own messages
      ack: true        // Wait for server acknowledgment
    }
  }
})

// With acknowledgment
const result = await channel.send({
  type: 'broadcast',
  event: 'message',
  payload: { text: 'Hello' }
})

if (result === 'ok') {
  console.log('Message delivered')
}
```

## Presence

Track online users and their state:

```typescript
const channel = supabase.channel('online-users')

// Track current user
channel.subscribe(async (status) => {
  if (status === 'SUBSCRIBED') {
    await channel.track({
      user_id: user.id,
      username: user.name,
      online_at: new Date().toISOString()
    })
  }
})

// Listen for presence changes
channel.on('presence', { event: 'sync' }, () => {
  const state = channel.presenceState()
  console.log('Online users:', Object.keys(state).length)
})

channel.on('presence', { event: 'join' }, ({ key, newPresences }) => {
  console.log('User joined:', newPresences)
})

channel.on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
  console.log('User left:', leftPresences)
})
```

### Presence State Structure

```typescript
// presenceState() returns:
{
  'user-uuid-1': [
    { user_id: 'user-uuid-1', username: 'Alice', online_at: '...' }
  ],
  'user-uuid-2': [
    { user_id: 'user-uuid-2', username: 'Bob', online_at: '...' }
  ]
}
```

**Limitation**: Maximum 10 presence keys per object.

## Postgres Changes

Subscribe to database INSERT/UPDATE/DELETE events:

```typescript
const channel = supabase.channel('db-changes')

// Listen to all changes on a table
channel.on(
  'postgres_changes',
  {
    event: '*',
    schema: 'public',
    table: 'messages'
  },
  (payload) => {
    console.log('Change:', payload.eventType, payload.new, payload.old)
  }
)

// Listen to specific events
channel.on(
  'postgres_changes',
  {
    event: 'INSERT',
    schema: 'public',
    table: 'messages'
  },
  (payload) => {
    addMessage(payload.new)
  }
)

// Filter by column value
channel.on(
  'postgres_changes',
  {
    event: '*',
    schema: 'public',
    table: 'messages',
    filter: 'room_id=eq.room-123'
  },
  (payload) => {
    handleRoomMessage(payload)
  }
)

channel.subscribe()
```

### Filter Operators

```typescript
// Equals
filter: 'status=eq.active'

// In list
filter: 'status=in.(active,pending)'

// Greater than
filter: 'amount=gt.100'

// Less than
filter: 'amount=lt.1000'
```

### Enable Realtime on Table

```sql
-- Via SQL
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Or in Dashboard: Database > Replication > Add table
```

### Row Level Security for Postgres Changes

Users only receive changes they're authorized to see:

```sql
-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy for viewing messages
CREATE POLICY "Users can view messages in their rooms"
ON messages FOR SELECT
USING (
  room_id IN (
    SELECT room_id FROM room_members WHERE user_id = auth.uid()
  )
);
```

## Scaling Patterns

### Re-broadcast Database Changes

For high-scale scenarios, use Broadcast instead of direct Postgres Changes:

```typescript
// Edge Function triggered by database webhook
serve(async (req) => {
  const { record, type } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Broadcast to channel
  await supabase.channel(`room-${record.room_id}`).send({
    type: 'broadcast',
    event: type.toLowerCase(),
    payload: record
  })

  return new Response('ok')
})
```

### Connection Management

```typescript
// Properly cleanup on unmount (React example)
useEffect(() => {
  const channel = supabase.channel('my-channel')

  channel.subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, [])
```

### Reconnection Handling

```typescript
channel.subscribe((status, err) => {
  if (status === 'SUBSCRIBED') {
    console.log('Connected')
  } else if (status === 'CHANNEL_ERROR') {
    console.error('Connection error:', err)
  } else if (status === 'TIMED_OUT') {
    console.log('Connection timed out, retrying...')
  } else if (status === 'CLOSED') {
    console.log('Connection closed')
  }
})
```

## Common Patterns

### Chat Application

```typescript
// Subscribe to messages and presence
const channel = supabase.channel(`chat-${roomId}`)

channel
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'messages',
    filter: `room_id=eq.${roomId}`
  }, ({ new: message }) => {
    addMessage(message)
  })
  .on('presence', { event: 'sync' }, () => {
    setOnlineUsers(Object.values(channel.presenceState()).flat())
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({ user_id: userId, username })
    }
  })

// Send message (database insert, not broadcast)
const sendMessage = async (text: string) => {
  await supabase.from('messages').insert({
    room_id: roomId,
    user_id: userId,
    text
  })
}
```

### Collaborative Cursors

```typescript
const channel = supabase.channel('cursors', {
  config: { broadcast: { self: false } }
})

// Broadcast cursor position (debounced)
const handleMouseMove = debounce((e: MouseEvent) => {
  channel.send({
    type: 'broadcast',
    event: 'cursor',
    payload: { x: e.clientX, y: e.clientY, userId }
  })
}, 50)

// Receive other cursors
channel.on('broadcast', { event: 'cursor' }, ({ payload }) => {
  updateOtherCursor(payload.userId, payload.x, payload.y)
})

channel.subscribe()
```

### Live Dashboard Updates

```typescript
// Subscribe to metrics table
const channel = supabase.channel('dashboard')

channel.on('postgres_changes', {
  event: 'UPDATE',
  schema: 'public',
  table: 'metrics',
  filter: `org_id=eq.${orgId}`
}, ({ new: metrics }) => {
  updateDashboard(metrics)
})

channel.subscribe()
```

## When to Use Custom WebSocket

Use custom implementation instead of Supabase Realtime when:

- **Sub-10ms latency** required (trading, gaming)
- **Custom binary protocols** needed
- **Guaranteed message delivery** required (Supabase doesn't guarantee every message)
- **>2,500 messages/second** needed
- **Unlimited connection duration** required (Realtime connections have limits)

For these cases, use Socket.io or ws on Fly.io with proper scaling.
