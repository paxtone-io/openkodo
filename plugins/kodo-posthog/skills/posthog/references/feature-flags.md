# PostHog Feature Flags Reference

Comprehensive guide for feature flag design, targeting, and implementation patterns.

## Flag Types

### Boolean Flags

Simple on/off toggles.

```typescript
// Check if enabled
const enabled = posthog.isFeatureEnabled('release_new_dashboard');

if (enabled) {
  return <NewDashboard />;
}
return <LegacyDashboard />;
```

### Multivariate Flags

Multiple variants for A/B/n testing.

```typescript
// Get variant
const variant = posthog.getFeatureFlag('experiment_checkout_flow');

switch (variant) {
  case 'control':
    return <CheckoutV1 />;
  case 'simplified':
    return <CheckoutSimplified />;
  case 'express':
    return <CheckoutExpress />;
  default:
    return <CheckoutV1 />;
}
```

### Flags with Payloads

Flags that return configuration data.

```typescript
interface PricingConfig {
  showAnnualToggle: boolean;
  highlightedPlan: string;
  discountPercent: number;
}

const config = posthog.getFeatureFlagPayload('config_pricing_page') as PricingConfig;

return (
  <PricingPage
    showAnnual={config?.showAnnualToggle ?? true}
    highlighted={config?.highlightedPlan ?? 'pro'}
    discount={config?.discountPercent ?? 0}
  />
);
```

## Naming Conventions

### Pattern

```
{scope}_{feature}_{type}
```

### Scope Prefixes

| Prefix | Purpose | Example |
|--------|---------|---------|
| `release_` | Feature release toggle | `release_new_editor_enabled` |
| `experiment_` | A/B test variant | `experiment_onboarding_flow` |
| `ops_` | Operational controls | `ops_maintenance_mode` |
| `beta_` | Beta access control | `beta_ai_features_enabled` |
| `config_` | Configuration flags | `config_pricing_display` |
| `kill_` | Kill switches (disable) | `kill_api_v1_deprecated` |
| `rollout_` | Gradual rollout | `rollout_new_billing_system` |

### Type Suffixes

| Suffix | Meaning | Example |
|--------|---------|---------|
| `_enabled` | Boolean on/off | `release_dark_mode_enabled` |
| `_variant` | Multivariate | `experiment_cta_variant` |
| `_config` | Payload data | `config_limits_config` |
| `_rollout` | Percentage rollout | `release_new_api_rollout` |

## Targeting Strategies

### Percentage Rollout

Gradually release to increasing % of users:

```
Week 1: 5% rollout
Week 2: 25% rollout
Week 3: 50% rollout
Week 4: 100% rollout
```

Create via MCP:
```
mcp__posthog__create-feature-flag with:
- key: rollout_new_feature
- filters: { groups: [{ properties: [], rollout_percentage: 5 }] }
```

### User Property Targeting

Target by user attributes:

```json
{
  "groups": [
    {
      "properties": [
        { "key": "plan", "value": "enterprise", "operator": "exact" }
      ],
      "rollout_percentage": 100
    }
  ]
}
```

Common targeting properties:
- `email` - Target specific users or domains
- `plan` / `subscription_tier` - Target by plan
- `$geoip_country_code` - Geographic targeting
- `created_at` - Target by account age
- Custom properties set via `posthog.identify()`

### Cohort Targeting

Target saved user cohorts:

```json
{
  "groups": [
    {
      "properties": [
        { "key": "id", "value": "cohort_123", "type": "cohort" }
      ],
      "rollout_percentage": 100
    }
  ]
}
```

### Multi-Condition Targeting

Combine multiple conditions:

```json
{
  "groups": [
    {
      "properties": [
        { "key": "plan", "value": "pro", "operator": "exact" },
        { "key": "$geoip_country_code", "value": "US", "operator": "exact" }
      ],
      "rollout_percentage": 50
    },
    {
      "properties": [
        { "key": "plan", "value": "enterprise", "operator": "exact" }
      ],
      "rollout_percentage": 100
    }
  ]
}
```

## Implementation Patterns

### React Hook Pattern

```typescript
// hooks/useFeatureFlag.ts
import { useEffect, useState } from 'react';
import posthog from 'posthog-js';

export function useFeatureFlag(flagKey: string): boolean {
  const [enabled, setEnabled] = useState<boolean>(false);

  useEffect(() => {
    // Check immediately
    setEnabled(posthog.isFeatureEnabled(flagKey) ?? false);

    // Listen for flag changes (remote config updates)
    const unsubscribe = posthog.onFeatureFlags(() => {
      setEnabled(posthog.isFeatureEnabled(flagKey) ?? false);
    });

    return () => {
      if (typeof unsubscribe === 'function') {
        unsubscribe();
      }
    };
  }, [flagKey]);

  return enabled;
}

export function useFeatureFlagVariant(flagKey: string): string | undefined {
  const [variant, setVariant] = useState<string | undefined>();

  useEffect(() => {
    const value = posthog.getFeatureFlag(flagKey);
    setVariant(typeof value === 'string' ? value : undefined);

    const unsubscribe = posthog.onFeatureFlags(() => {
      const value = posthog.getFeatureFlag(flagKey);
      setVariant(typeof value === 'string' ? value : undefined);
    });

    return () => {
      if (typeof unsubscribe === 'function') {
        unsubscribe();
      }
    };
  }, [flagKey]);

  return variant;
}

export function useFeatureFlagPayload<T>(flagKey: string): T | undefined {
  const [payload, setPayload] = useState<T | undefined>();

  useEffect(() => {
    setPayload(posthog.getFeatureFlagPayload(flagKey) as T | undefined);

    const unsubscribe = posthog.onFeatureFlags(() => {
      setPayload(posthog.getFeatureFlagPayload(flagKey) as T | undefined);
    });

    return () => {
      if (typeof unsubscribe === 'function') {
        unsubscribe();
      }
    };
  }, [flagKey]);

  return payload;
}
```

### Component Wrapper Pattern

```typescript
// components/FeatureGate.tsx
import { ReactNode } from 'react';
import { useFeatureFlag } from '@/hooks/useFeatureFlag';

interface FeatureGateProps {
  flag: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureGate({ flag, children, fallback = null }: FeatureGateProps) {
  const enabled = useFeatureFlag(flag);
  return enabled ? <>{children}</> : <>{fallback}</>;
}

// Usage
<FeatureGate flag="release_new_sidebar" fallback={<OldSidebar />}>
  <NewSidebar />
</FeatureGate>
```

### Server-Side Flag Evaluation

```typescript
// server/lib/feature-flags.ts
import { posthog } from '@/lib/posthog-server';

export async function getFeatureFlag(
  flagKey: string,
  userId: string,
  userProperties?: Record<string, unknown>
): Promise<boolean | string | undefined> {
  return posthog.getFeatureFlag(flagKey, userId, {
    personProperties: userProperties,
  });
}

export async function getAllFlags(
  userId: string,
  userProperties?: Record<string, unknown>
): Promise<Record<string, boolean | string>> {
  return posthog.getAllFlags(userId, {
    personProperties: userProperties,
  });
}

// Usage in API route
app.get('/api/dashboard', async (req, res) => {
  const userId = req.user.id;

  const showNewDashboard = await getFeatureFlag(
    'release_new_dashboard',
    userId,
    { plan: req.user.plan }
  );

  if (showNewDashboard) {
    return res.json(await getNewDashboardData());
  }
  return res.json(await getLegacyDashboardData());
});
```

### Local Override Pattern (Development)

```typescript
// lib/posthog.ts
const FLAG_OVERRIDES: Record<string, boolean | string> = {
  // Uncomment to override flags locally
  // 'release_new_feature': true,
  // 'experiment_variant': 'treatment',
};

export function isFeatureEnabled(flagKey: string): boolean {
  // Check local overrides first (dev only)
  if (import.meta.env.DEV && flagKey in FLAG_OVERRIDES) {
    return Boolean(FLAG_OVERRIDES[flagKey]);
  }
  return posthog.isFeatureEnabled(flagKey) ?? false;
}
```

## Flag Lifecycle

### Creation Checklist

Before creating a flag:

- [ ] Define clear purpose and success criteria
- [ ] Choose appropriate scope prefix
- [ ] Plan targeting strategy
- [ ] Document in Notion flags database
- [ ] Set initial rollout percentage

### Rollout Process

```
1. Create flag at 0% rollout
2. Enable for internal team (email targeting)
3. Increase to 5-10% for early adopters
4. Monitor for issues via PostHog dashboards
5. Gradually increase (25% -> 50% -> 75% -> 100%)
6. After stable period, remove flag and clean up code
```

### Flag Cleanup

After 100% rollout and stable:

```typescript
// 1. Update code to remove flag checks
// Before:
const showNew = useFeatureFlag('release_new_feature');
return showNew ? <NewComponent /> : <OldComponent />;

// After:
return <NewComponent />;

// 2. Delete old component code
// 3. Archive flag in PostHog
// 4. Update Notion documentation
```

## MCP Commands

### Create Flag

```
mcp__posthog__create-feature-flag with:
- key: "release_new_feature_enabled"
- name: "New Feature Release"
- description: "Enables the new feature for users"
- filters: {
    groups: [{
      properties: [],
      rollout_percentage: 0
    }]
  }
- active: false
```

### Update Rollout

```
mcp__posthog__update-feature-flag with:
- flagKey: "release_new_feature_enabled"
- data: {
    filters: {
      groups: [{
        properties: [],
        rollout_percentage: 25
      }]
    },
    active: true
  }
```

### Target Specific Users

```
mcp__posthog__update-feature-flag with:
- flagKey: "beta_ai_features_enabled"
- data: {
    filters: {
      groups: [{
        properties: [
          { key: "email", value: "@company.com", operator: "icontains" }
        ],
        rollout_percentage: 100
      }]
    }
  }
```

### Get Flag Status

```
mcp__posthog__feature-flag-get-definition with:
- flagKey: "release_new_feature_enabled"
```

## Best Practices

### Do

- Use descriptive, consistent naming
- Start with 0% rollout
- Test with internal team first
- Monitor dashboards during rollout
- Document flags in Notion
- Clean up flags after full rollout
- Use payloads for configuration

### Don't

- Create flags without clear purpose
- Ship at 100% immediately
- Forget to clean up old flags
- Nest multiple flag checks deeply
- Use flags for permanent configuration
- Make flags that affect critical paths without fallbacks

## Troubleshooting

### Flag Not Evaluating

1. Check if user is identified: `posthog.get_distinct_id()`
2. Verify flag is active in PostHog dashboard
3. Check targeting rules match user properties
4. Wait for feature flags to load: `posthog.onFeatureFlags()`

### Inconsistent Values

1. Ensure consistent `distinct_id` across client/server
2. Check for property mismatches in targeting
3. Verify user properties are set before flag check

### Performance Issues

1. Cache flag values on server side
2. Use `getAllFlags()` instead of multiple `getFeatureFlag()` calls
3. Consider local evaluation for high-traffic endpoints
