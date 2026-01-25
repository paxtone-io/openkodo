---
name: kodo-ph-flag
description: Create, update, and manage PostHog feature flags with proper naming and targeting
---

# /kodo ph-flag - Feature Flag Management

Create, update, and manage PostHog feature flags with proper naming and targeting.

## What You Do

When the user runs `/kodo ph-flag [action] [flag-key]`:

**Actions:**
- `create` - Create a new feature flag
- `list` - List all feature flags
- `get` - Get flag definition and status
- `enable` - Enable a flag (set active + 100% rollout)
- `disable` - Disable a flag (set inactive)
- `rollout` - Update rollout percentage
- `delete` - Delete a feature flag
- `document` - Create/update Notion documentation

### Default Behavior (no action specified)

1. **Load project context** from `.kodo/config.json`
2. **List active flags** with their rollout status
3. **Show flag naming conventions** and offer to create new flag

### Action: `create [flag-key]`

1. **Validate naming convention**: `{type}_{feature_name}`
   - Types: `release_`, `experiment_`, `ops_`, `permission_`, `beta_`

2. **Prompt for configuration**:
   - Description (required)
   - Flag type (release, experiment, ops, permission)
   - Initial state (active/inactive)
   - Targeting rules (optional)

3. **Create flag** via MCP
4. **Document in Notion** if `sync.auto_sync_on_create` is enabled

### Action: `rollout [flag-key] [percentage]`

1. Get current flag state
2. Update rollout percentage
3. Sync status to Notion documentation

## Commands to Execute

### List All Flags
```
mcp__posthog__feature-flag-get-all with:
- data: { limit: 50 }
```

### Get Flag Definition
```
mcp__posthog__feature-flag-get-definition with:
- flagKey: "{flag_key}"
```

### Create Feature Flag
```
mcp__posthog__create-feature-flag with:
- key: "{flag_key}"
- name: "{human_readable_name}"
- description: "{description}"
- active: false
- filters: {
    groups: [{
      properties: [],
      rollout_percentage: 0
    }]
  }
```

### Update Feature Flag
```
mcp__posthog__update-feature-flag with:
- flagKey: "{flag_key}"
- data: {
    active: true,
    filters: {
      groups: [{
        properties: [],
        rollout_percentage: {percentage}
      }]
    }
  }
```

### Enable Flag (100% rollout)
```
mcp__posthog__update-feature-flag with:
- flagKey: "{flag_key}"
- data: {
    active: true,
    filters: {
      groups: [{
        properties: [],
        rollout_percentage: 100
      }]
    }
  }
```

### Disable Flag
```
mcp__posthog__update-feature-flag with:
- flagKey: "{flag_key}"
- data: { active: false }
```

### Delete Flag
```
mcp__posthog__delete-feature-flag with:
- flagKey: "{flag_key}"
```

### Create Notion Documentation
```
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{flags_database_id}" }
- pages: [{
    properties: {
      "Flag Key": "{flag_key}",
      "Name": "{human_readable_name}",
      "Type": "{release|experiment|ops|permission}",
      "Status": "draft",
      "Rollout %": 0,
      "Owner": "{owner_name}"
    }
  }]
```

## Flag Types Reference

| Type | Prefix | Purpose | Lifecycle |
|------|--------|---------|-----------|
| Release | `release_` | Progressive feature rollout | Remove at 100% |
| Experiment | `experiment_` | A/B test variant control | Remove after conclusion |
| Ops | `ops_` | Operational toggles (kill switches) | Keep permanently |
| Permission | `permission_` | Feature access control | Keep permanently |
| Beta | `beta_` | Beta program access | Remove at GA |

## Targeting Patterns

### All Users
```json
{
  "groups": [{
    "properties": [],
    "rollout_percentage": 100
  }]
}
```

### Specific Plan
```json
{
  "groups": [{
    "properties": [{
      "key": "plan",
      "value": "pro",
      "operator": "exact"
    }],
    "rollout_percentage": 100
  }]
}
```

### Internal Users
```json
{
  "groups": [{
    "properties": [{
      "key": "email",
      "value": "@yourcompany.com",
      "operator": "icontains"
    }],
    "rollout_percentage": 100
  }]
}
```

### Beta Users
```json
{
  "groups": [{
    "properties": [{
      "key": "beta_tester",
      "value": true,
      "operator": "exact"
    }],
    "rollout_percentage": 100
  }]
}
```

### Progressive Rollout
```json
{
  "groups": [
    {
      "properties": [{
        "key": "email",
        "value": "@yourcompany.com",
        "operator": "icontains"
      }],
      "rollout_percentage": 100
    },
    {
      "properties": [],
      "rollout_percentage": 10
    }
  ]
}
```

## Implementation Templates

### React Hook
```typescript
import { useFeatureFlag } from '@/lib/posthog';

function MyComponent() {
  const isEnabled = useFeatureFlag('release_new_dashboard');

  if (!isEnabled) {
    return <OldDashboard />;
  }

  return <NewDashboard />;
}
```

### Server-Side Check
```typescript
import { posthog } from '@/lib/posthog-server';

async function getFeatureAccess(userId: string, flagKey: string) {
  const isEnabled = await posthog.isFeatureEnabled(flagKey, userId);
  return isEnabled;
}
```

### With Loading State
```typescript
import { useFeatureFlagWithPayload } from '@/lib/posthog';

function MyComponent() {
  const { isEnabled, isLoading, payload } = useFeatureFlagWithPayload(
    'release_new_pricing'
  );

  if (isLoading) return <Skeleton />;

  return isEnabled
    ? <NewPricing config={payload} />
    : <OldPricing />;
}
```

## Constraints

- Flag keys must be snake_case
- Keys must start with type prefix
- Maximum 1000 active flags per project
- Targeting rules evaluated in order (first match wins)
- Always document cleanup date for release flags

## Rollout Best Practices

```markdown
## Standard Rollout Schedule
1. 0% - Draft, not active
2. Internal (100% internal, 0% external)
3. 5% - Initial external testing
4. 25% - Expanded rollout
5. 50% - Majority rollout
6. 100% - Full release
7. Remove flag - Cleanup

## Rollback Plan
- Keep flag active during rollout
- Set to 0% to rollback
- Document any issues before rollback
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/SKILL.md` - Core PostHog guidance
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/feature-flags.md` - Detailed flag patterns
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/notion-sync.md` - Documentation sync workflow

## Example

**User:** `/kodo ph-flag create release_new_checkout`

**Agent:**
I'll create a new release feature flag for `release_new_checkout`. Let me first check if this flag already exists...

Flag not found - creating new flag.

**Flag:** `release_new_checkout`
- **Type:** Release
- **Status:** Draft (inactive)
- **Initial Rollout:** 0%

I'll create the flag with these settings:

```typescript
// Created feature flag
{
  key: "release_new_checkout",
  name: "New Checkout Flow",
  description: "Progressive rollout of redesigned checkout experience",
  active: false,
  filters: {
    groups: [{
      properties: [],
      rollout_percentage: 0
    }]
  }
}
```

Flag created successfully!

**Implementation code:**
```typescript
// Add to your checkout component
const isNewCheckout = useFeatureFlag('release_new_checkout');

return isNewCheckout ? <NewCheckout /> : <LegacyCheckout />;
```

Should I:
1. Add this to a specific file in your codebase?
2. Create documentation in Notion?
3. Set up initial targeting rules (internal users first)?
4. Start a rollout to 5%?
