---
name: kodo-ph-event
description: Track custom events and manage event documentation for PostHog analytics
---

# /kodo ph-event - Event Tracking Management

Track custom events and manage event documentation for PostHog analytics.

## What You Do

When the user runs `/kodo ph-event [action] [event-name]`:

**Actions:**
- `track` - Implement tracking for a new event
- `list` - List all event definitions in PostHog
- `search` - Search for existing events
- `document` - Create/update Notion documentation for an event
- `validate` - Check event implementation against documentation

### Default Behavior (no action specified)

1. **Load project context** from `.kodo/config.json`
2. **List recent events** using MCP tools
3. **Show event naming conventions** and offer to create new event

### Action: `track [event-name]`

1. **Validate naming convention**: `{domain}_{action}_{object}`
   - Domain: `user_`, `subscription_`, `feature_`, `system_`, `error_`
   - Action: `created`, `updated`, `deleted`, `viewed`, `clicked`, `completed`
   - Object: What was acted upon

2. **Check if event exists** in PostHog
3. **Generate tracking code** for the framework (React/Next.js/Node)
4. **Document in Notion** if `sync.auto_sync_on_create` is enabled

### Action: `list`

1. Fetch all event definitions from PostHog
2. Display grouped by domain prefix
3. Show implementation status and last seen

### Action: `document [event-name]`

1. Get event details from PostHog
2. Create or update Notion entry with:
   - Event name and description
   - Property schema
   - Implementation status
   - Feature areas using this event

## Commands to Execute

### List Events
```
mcp__posthog__event-definitions-list with:
- limit: 100
- q: "{search_term}"  # Optional filter
```

### Get Event Properties
```
mcp__posthog__properties-list with:
- type: "event"
- eventName: "{event_name}"
```

### Create Notion Documentation
```
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{events_database_id}" }
- pages: [{
    properties: {
      "Event Name": "{event_name}",
      "Domain": "{domain_prefix}",
      "Category": "{category}",
      "Description": "{description}",
      "Implementation Status": "planned",
      "Tracked On": "{frontend|backend|both}"
    }
  }]
```

## Event Tracking Templates

### React/Next.js Client-Side
```typescript
import { trackEvent } from '@/lib/posthog';

// Basic event
trackEvent('feature_button_clicked', {
  button_name: 'submit',
  feature_area: 'checkout',
});

// With user context
trackEvent('user_subscription_upgraded', {
  from_plan: 'free',
  to_plan: 'pro',
  upgrade_source: 'settings_page',
});
```

### Server-Side (Node.js)
```typescript
import { posthog } from '@/lib/posthog-server';

posthog.capture({
  distinctId: userId,
  event: 'subscription_payment_completed',
  properties: {
    amount_cents: 4999,
    currency: 'USD',
    payment_method: 'card',
  },
});
```

### trackEvent Helper
```typescript
// lib/posthog.ts
import posthog from 'posthog-js';

export function trackEvent(
  eventName: string,
  properties?: Record<string, unknown>
) {
  if (typeof window !== 'undefined') {
    posthog.capture(eventName, {
      ...properties,
      timestamp: new Date().toISOString(),
    });
  }
}
```

## Naming Convention Reference

| Domain | Events |
|--------|--------|
| `user_` | `user_signed_up`, `user_logged_in`, `user_profile_updated` |
| `subscription_` | `subscription_created`, `subscription_upgraded`, `subscription_canceled` |
| `feature_` | `feature_enabled`, `feature_used`, `feature_limit_reached` |
| `error_` | `error_api_failed`, `error_validation_failed`, `error_payment_declined` |
| `system_` | `system_notification_sent`, `system_job_completed` |

## Property Naming

- Use `snake_case` for all property names
- Include units in name: `duration_seconds`, `amount_cents`
- Use consistent types: `user_id` always string, counts always number

## Constraints

- Event names must be snake_case
- Maximum 200 properties per event
- Property names max 200 characters
- Avoid high-cardinality properties (unique IDs in values)
- Don't track PII in properties without consent

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/SKILL.md` - Core PostHog guidance
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/events.md` - Detailed event patterns
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/notion-sync.md` - Documentation sync workflow

## Example

**User:** `/kodo ph-event track feature_export_completed`

**Agent:**
I'll set up tracking for `feature_export_completed`. Let me first check if this event already exists...

Event not found - creating new event tracking.

**Event:** `feature_export_completed`
- **Domain:** `feature_`
- **Category:** engagement
- **Suggested Properties:**
  - `export_format` (string): pdf, csv, json
  - `item_count` (number): Number of items exported
  - `duration_ms` (number): Time to complete export
  - `file_size_bytes` (number): Resulting file size

**Tracking Code:**
```typescript
// Add to your export completion handler
trackEvent('feature_export_completed', {
  export_format: format,
  item_count: items.length,
  duration_ms: endTime - startTime,
  file_size_bytes: blob.size,
});
```

Should I:
1. Add this to a specific file in your codebase?
2. Create documentation in Notion?
3. Set up a dashboard insight for this event?
