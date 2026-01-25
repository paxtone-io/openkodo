# PostHog Event Tracking Reference

Comprehensive guide for event tracking, naming conventions, and property schemas.

## Event Categories

### System Events (Autocapture)

PostHog autocapture handles these automatically:

| Event | Description | Properties |
|-------|-------------|------------|
| `$pageview` | Page navigation | `$current_url`, `$pathname`, `$referrer` |
| `$pageleave` | User leaves page | `$current_url`, duration |
| `$autocapture` | Clicks, form submits | `$event_type`, `$elements` |
| `$rageclick` | Repeated clicks (frustration) | `$elements`, count |

### Custom Business Events

Define these explicitly for business-critical actions:

```typescript
// Core conversion events
'user_signed_up'
'user_activated'
'subscription_started'
'subscription_upgraded'
'subscription_cancelled'
'payment_completed'
'payment_failed'

// Feature engagement
'feature_used'
'feature_discovered'
'onboarding_step_completed'
'onboarding_completed'
'onboarding_skipped'

// Content interaction
'content_viewed'
'content_created'
'content_shared'
'content_exported'
'search_performed'
'filter_applied'

// Collaboration
'team_created'
'team_member_invited'
'team_member_joined'
'permission_changed'
```

## Naming Conventions

### Pattern

```
{domain}_{action}_{object}
```

All lowercase, snake_case.

### Domain Prefixes

| Domain | Description | Examples |
|--------|-------------|----------|
| `user_` | User account actions | `user_signed_up`, `user_logged_in` |
| `subscription_` | Billing/subscription | `subscription_started`, `subscription_cancelled` |
| `payment_` | Payment transactions | `payment_completed`, `payment_failed` |
| `feature_` | Feature interactions | `feature_used`, `feature_enabled` |
| `content_` | Content CRUD | `content_created`, `content_deleted` |
| `team_` | Team/org actions | `team_created`, `team_member_added` |
| `notification_` | Notification events | `notification_sent`, `notification_clicked` |
| `api_` | API/integration events | `api_key_created`, `api_request_made` |
| `error_` | Error tracking | `error_occurred`, `error_recovered` |
| `experiment_` | A/B test events | `experiment_viewed`, `experiment_converted` |

### Action Verbs (Past Tense)

```
created, updated, deleted, archived
viewed, clicked, submitted, completed
started, paused, resumed, cancelled
enabled, disabled, toggled
sent, received, opened, dismissed
uploaded, downloaded, exported, imported
searched, filtered, sorted
connected, disconnected, synced
```

## Standard Property Schema

### Base Properties (All Events)

```typescript
interface BaseEventProperties {
  // Automatically added by SDK
  $lib: string;                    // 'web' | 'posthog-node'
  $lib_version: string;            // SDK version
  $current_url?: string;           // Browser URL
  $pathname?: string;              // URL pathname
  $referrer?: string;              // Referrer URL
  $referring_domain?: string;      // Referrer domain
  $device_type?: string;           // 'Desktop' | 'Mobile' | 'Tablet'
  $browser?: string;               // Browser name
  $browser_version?: string;       // Browser version
  $os?: string;                    // Operating system

  // Custom base properties (add to all events)
  client_timestamp: string;        // ISO 8601
  app_version?: string;            // Your app version
  environment?: string;            // 'development' | 'staging' | 'production'
}
```

### User Context Properties

```typescript
interface UserContextProperties {
  user_id?: string;                // Internal user ID
  organization_id?: string;        // Team/org ID
  plan_type?: string;              // 'free' | 'pro' | 'enterprise'
  subscription_status?: string;    // 'active' | 'trialing' | 'cancelled'
  user_role?: string;              // 'admin' | 'member' | 'viewer'
  account_age_days?: number;       // Days since signup
  is_internal?: boolean;           // Internal test account
}
```

### Feature Context Properties

```typescript
interface FeatureContextProperties {
  feature_area: string;            // 'dashboard' | 'settings' | 'billing'
  feature_name?: string;           // Specific feature
  component?: string;              // UI component name
  action_source?: 'button' | 'keyboard' | 'menu' | 'api' | 'automated';
  interaction_type?: 'click' | 'hover' | 'focus' | 'scroll';
}
```

## Event-Specific Schemas

### User Events

```typescript
// user_signed_up
interface UserSignedUpProperties {
  signup_method: 'email' | 'google' | 'github' | 'sso';
  referral_source?: string;
  utm_source?: string;
  utm_medium?: string;
  utm_campaign?: string;
  initial_plan?: string;
}

// user_activated
interface UserActivatedProperties {
  activation_criteria: string;     // What defined activation
  time_to_activate_hours: number;
  activation_path: string[];       // Steps taken
}
```

### Subscription Events

```typescript
// subscription_started
interface SubscriptionStartedProperties {
  plan_id: string;
  plan_name: string;
  billing_cycle: 'monthly' | 'yearly';
  price_cents: number;
  currency: string;
  trial_days?: number;
  discount_code?: string;
  previous_plan?: string;
}

// subscription_cancelled
interface SubscriptionCancelledProperties {
  plan_id: string;
  plan_name: string;
  cancellation_reason?: string;
  feedback?: string;
  subscription_duration_days: number;
  mrr_lost_cents: number;
}
```

### Payment Events

```typescript
// payment_completed
interface PaymentCompletedProperties {
  payment_id: string;
  amount_cents: number;
  currency: string;
  payment_method: 'card' | 'bank_transfer' | 'paypal';
  is_recurring: boolean;
  invoice_id?: string;
}

// payment_failed
interface PaymentFailedProperties {
  payment_id?: string;
  amount_cents: number;
  currency: string;
  failure_reason: string;
  failure_code?: string;
  retry_count: number;
}
```

### Feature Events

```typescript
// feature_used
interface FeatureUsedProperties {
  feature_name: string;
  feature_category: string;
  usage_count?: number;            // Times used in session
  time_spent_seconds?: number;
  success: boolean;
}

// onboarding_step_completed
interface OnboardingStepCompletedProperties {
  step_number: number;
  step_name: string;
  total_steps: number;
  time_on_step_seconds: number;
  skipped: boolean;
}
```

### Error Events

```typescript
// error_occurred
interface ErrorOccurredProperties {
  error_type: string;              // 'api_error' | 'validation_error' | 'network_error'
  error_code?: string;
  error_message: string;
  stack_trace?: string;            // Only in development
  feature_area: string;
  user_action: string;             // What user was doing
  recoverable: boolean;
}
```

## Implementation Examples

### Frontend Tracking

```typescript
import { trackEvent } from '@/lib/posthog';

// Basic event
trackEvent('feature_used', {
  feature_name: 'export_report',
  feature_category: 'analytics',
  success: true,
});

// With user context
trackEvent('subscription_started', {
  plan_id: 'pro_monthly',
  plan_name: 'Pro',
  billing_cycle: 'monthly',
  price_cents: 2900,
  currency: 'USD',
});

// Error tracking
trackEvent('error_occurred', {
  error_type: 'api_error',
  error_code: 'RATE_LIMIT_EXCEEDED',
  error_message: 'Too many requests',
  feature_area: 'data_export',
  user_action: 'export_csv',
  recoverable: true,
});
```

### Backend Tracking

```typescript
import { trackServerEvent } from '@/lib/posthog-server';

// Subscription event from webhook
trackServerEvent(userId, 'subscription_started', {
  plan_id: 'pro_monthly',
  plan_name: 'Pro',
  billing_cycle: 'monthly',
  price_cents: 2900,
  currency: 'USD',
  stripe_subscription_id: sub.id,
});

// API usage tracking
trackServerEvent(userId, 'api_request_made', {
  endpoint: '/api/v1/data',
  method: 'POST',
  response_time_ms: 245,
  status_code: 200,
  api_version: 'v1',
});
```

## Event Validation

### Required Properties Checklist

Before shipping an event, verify:

- [ ] Event name follows naming convention
- [ ] All required properties present
- [ ] Property types are correct
- [ ] Sensitive data is NOT included
- [ ] Event fires at correct moment
- [ ] Duplicate events are prevented
- [ ] Event appears in PostHog debug

### Property Type Validation

```typescript
// Type guard for event properties
function validateEventProperties<T extends Record<string, unknown>>(
  eventName: string,
  properties: T,
  requiredKeys: (keyof T)[]
): boolean {
  for (const key of requiredKeys) {
    if (properties[key] === undefined || properties[key] === null) {
      console.error(`Missing required property "${String(key)}" for event "${eventName}"`);
      return false;
    }
  }
  return true;
}

// Usage
const props = { plan_id: 'pro', price_cents: 2900 };
if (validateEventProperties('subscription_started', props, ['plan_id', 'price_cents'])) {
  trackEvent('subscription_started', props);
}
```

## Anti-Patterns

### Don't Do This

```typescript
// Too generic
trackEvent('click', { element: 'button' });

// Inconsistent naming
trackEvent('userSignedUp', {});     // camelCase
trackEvent('USER_SIGNUP', {});      // SCREAMING_SNAKE_CASE

// Sensitive data
trackEvent('payment_completed', {
  card_number: '4242...', // NEVER
  cvv: '123',             // NEVER
  ssn: '...',             // NEVER
});

// Missing context
trackEvent('error_occurred', {
  error: 'Something went wrong', // Too vague
});

// Tracking too frequently
useEffect(() => {
  trackEvent('page_viewed', {}); // Fires on every re-render
}, [someState]); // Wrong dependency
```

### Do This Instead

```typescript
// Specific and descriptive
trackEvent('export_button_clicked', {
  export_format: 'csv',
  row_count: 1500,
  feature_area: 'reports',
});

// Consistent naming
trackEvent('user_signed_up', { signup_method: 'google' });

// No sensitive data, only IDs
trackEvent('payment_completed', {
  payment_id: 'pay_123',
  amount_cents: 2900,
  currency: 'USD',
});

// Rich error context
trackEvent('error_occurred', {
  error_type: 'validation_error',
  error_code: 'INVALID_EMAIL',
  error_message: 'Email format is invalid',
  feature_area: 'signup_form',
  user_action: 'submit_form',
  recoverable: true,
});

// Track once on mount
useEffect(() => {
  trackEvent('page_viewed', { page_name: 'dashboard' });
}, []); // Empty dependency array
```

## Testing Events

### Local Development

```typescript
// Enable debug mode
posthog.init(POSTHOG_KEY, {
  loaded: (posthog) => {
    if (import.meta.env.DEV) {
      posthog.debug(); // Logs all events to console
    }
  },
});
```

### Verification Checklist

1. Open PostHog -> Activity -> Live Events
2. Filter by your user
3. Trigger the action
4. Verify event appears within seconds
5. Check all properties are present
6. Confirm property values are correct
