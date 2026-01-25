# PostHog Experiments Reference

Comprehensive guide for A/B testing, experiment design, and statistical analysis.

## Experiment Types

### A/B Tests

Two variants testing a single change.

```typescript
// Feature flag for A/B test
const variant = posthog.getFeatureFlag('experiment_checkout_redesign');

if (variant === 'control') {
  return <CheckoutOriginal />;
} else if (variant === 'test') {
  return <CheckoutRedesigned />;
}
```

### A/B/n Tests

Multiple variants testing several approaches.

```typescript
const variant = posthog.getFeatureFlag('experiment_pricing_page');

switch (variant) {
  case 'control':
    return <PricingOriginal />;
  case 'simplified':
    return <PricingSimplified />;
  case 'comparison':
    return <PricingComparison />;
  case 'value_focused':
    return <PricingValueFocused />;
  default:
    return <PricingOriginal />;
}
```

### Holdout Tests

Exclude percentage from all experiments to measure cumulative impact.

## Experiment Workflow

### 1. Hypothesis Formation

```markdown
**Hypothesis Template:**
We believe that [change]
will result in [outcome]
for [user segment]
because [reasoning].

**Example:**
We believe that simplifying checkout to 2 steps
will result in 15% higher completion rate
for mobile users
because current 4-step flow has 60% drop-off on mobile.
```

### 2. Metric Selection

#### Primary Metrics

Single metric that determines success:

| Metric Type | Use Case | Example |
|-------------|----------|---------|
| Funnel | Conversion flows | Signup -> Activation |
| Trend | Engagement | Daily feature usage |
| Mean | Quantitative | Average order value |

#### Secondary Metrics

Monitor for unintended effects:

```typescript
// Primary: Conversion rate
// Secondary: Time on page, Bounce rate, Support tickets
```

#### Guardrail Metrics

Ensure no negative impact:

```typescript
// Guardrails: Page load time, Error rate, Revenue per user
```

### 3. Sample Size Calculation

```
Required sample = f(baseline_rate, minimum_detectable_effect, significance, power)

Typical values:
- Significance level: 95% (alpha = 0.05)
- Statistical power: 80% (beta = 0.20)
- MDE: 5-20% relative change
```

PostHog calculates this automatically based on your settings.

### 4. Experiment Duration

Factors affecting duration:
- Traffic volume
- Conversion rate
- Minimum detectable effect
- Day-of-week effects (run full weeks)

**Minimum**: 1-2 weeks to account for weekly patterns
**Recommended**: Until statistical significance OR max 4-6 weeks

## Creating Experiments

### Via MCP Tools

```
# Create experiment
mcp__posthog__experiment-create with:
- name: "Checkout Redesign Test"
- feature_flag_key: "experiment_checkout_redesign"
- description: "Testing simplified 2-step checkout vs original 4-step"
- primary_metrics: [{
    metric_type: "funnel",
    event_name: "checkout_started",
    funnel_steps: ["checkout_started", "payment_entered", "purchase_completed"]
  }]
- secondary_metrics: [{
    metric_type: "mean",
    event_name: "checkout_completed",
    name: "Time to complete"
  }]
- variants: [
    { key: "control", rollout_percentage: 50 },
    { key: "test", rollout_percentage: 50 }
  ]
- minimum_detectable_effect: 10
- draft: true
```

### Variant Configuration

```typescript
// Equal split (recommended for most tests)
variants: [
  { key: 'control', rollout_percentage: 50 },
  { key: 'test', rollout_percentage: 50 }
]

// Unequal split (for risky changes)
variants: [
  { key: 'control', rollout_percentage: 90 },
  { key: 'test', rollout_percentage: 10 }
]

// Multi-variant
variants: [
  { key: 'control', rollout_percentage: 25 },
  { key: 'variant_a', rollout_percentage: 25 },
  { key: 'variant_b', rollout_percentage: 25 },
  { key: 'variant_c', rollout_percentage: 25 }
]
```

### Targeting Options

```typescript
// All users
target_properties: {}

// Specific segments
target_properties: {
  plan: 'pro',
  $geoip_country_code: 'US'
}

// New users only
target_properties: {
  days_since_signup: { operator: 'lt', value: 7 }
}
```

## Implementation Patterns

### React Integration

```typescript
// hooks/useExperiment.ts
import { useEffect, useState } from 'react';
import posthog from 'posthog-js';
import { trackEvent } from '@/lib/posthog';

interface ExperimentResult<T extends string> {
  variant: T | undefined;
  isLoading: boolean;
}

export function useExperiment<T extends string>(
  experimentKey: string
): ExperimentResult<T> {
  const [variant, setVariant] = useState<T | undefined>();
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Get initial value
    const value = posthog.getFeatureFlag(experimentKey);
    if (value !== undefined) {
      setVariant(value as T);
      setIsLoading(false);

      // Track exposure
      trackEvent('$experiment_exposure', {
        $feature_flag: experimentKey,
        $variant: value,
      });
    }

    // Listen for changes
    const unsubscribe = posthog.onFeatureFlags(() => {
      const newValue = posthog.getFeatureFlag(experimentKey);
      if (newValue !== undefined) {
        setVariant(newValue as T);
        setIsLoading(false);
      }
    });

    return () => {
      if (typeof unsubscribe === 'function') {
        unsubscribe();
      }
    };
  }, [experimentKey]);

  return { variant, isLoading };
}

// Usage
function CheckoutPage() {
  const { variant, isLoading } = useExperiment<'control' | 'test'>(
    'experiment_checkout_redesign'
  );

  if (isLoading) return <CheckoutSkeleton />;

  return variant === 'test'
    ? <CheckoutRedesigned />
    : <CheckoutOriginal />;
}
```

### Server-Side Experiments

```typescript
// server/lib/experiments.ts
import { posthog } from '@/lib/posthog-server';

interface ExperimentContext {
  userId: string;
  userProperties?: Record<string, unknown>;
}

export async function getExperimentVariant(
  experimentKey: string,
  context: ExperimentContext
): Promise<string | undefined> {
  const variant = await posthog.getFeatureFlag(
    experimentKey,
    context.userId,
    {
      personProperties: context.userProperties,
    }
  );

  if (variant && typeof variant === 'string') {
    // Track server-side exposure
    posthog.capture({
      distinctId: context.userId,
      event: '$experiment_exposure',
      properties: {
        $feature_flag: experimentKey,
        $variant: variant,
      },
    });

    return variant;
  }

  return undefined;
}

// Usage in API
app.get('/api/checkout', async (req, res) => {
  const variant = await getExperimentVariant(
    'experiment_checkout_api',
    { userId: req.user.id, userProperties: { plan: req.user.plan } }
  );

  if (variant === 'streamlined') {
    return res.json(await getStreamlinedCheckoutData());
  }
  return res.json(await getStandardCheckoutData());
});
```

### Tracking Conversions

```typescript
// Track primary metric event
function handlePurchaseComplete(order: Order) {
  trackEvent('purchase_completed', {
    order_id: order.id,
    amount_cents: order.totalCents,
    currency: order.currency,
    item_count: order.items.length,
    // Experiment will automatically associate this with variant
  });
}

// Track funnel steps
function handleCheckoutStep(step: number, stepName: string) {
  trackEvent('checkout_step_completed', {
    step_number: step,
    step_name: stepName,
  });
}
```

## Analyzing Results

### Via MCP Tools

```
# Get experiment results
mcp__posthog__experiment-results-get with:
- experimentId: 123
- refresh: true

# Returns:
# - variant_results with statistical data
# - exposure_counts per variant
# - conversion_rates with confidence intervals
# - statistical_significance (true/false)
# - credible_interval for each variant
```

### Interpreting Results

| Indicator | Meaning |
|-----------|---------|
| Significant: true | 95%+ confidence the difference is real |
| Credible interval doesn't cross 0 | Effect is likely in indicated direction |
| Exposure balanced | Similar sample sizes across variants |
| Expected loss < 1% | Safe to roll out winning variant |

### Decision Framework

```
IF statistical_significance = true AND variant_better:
  -> Roll out winning variant

IF statistical_significance = true AND control_better:
  -> Keep control, document learnings

IF statistical_significance = false after max duration:
  -> No meaningful difference, keep control (simpler)

IF guardrail_regression detected:
  -> Stop experiment, investigate
```

## Managing Experiments

### Lifecycle States

```
draft -> running -> complete -> archived
          |
       stopped (early termination)
```

### Launch Experiment

```
mcp__posthog__experiment-update with:
- experimentId: 123
- data: { launch: true }
```

### Stop Experiment

```
mcp__posthog__experiment-update with:
- experimentId: 123
- data: {
    conclude: "won",  // or "lost", "inconclusive", "stopped_early"
    conclusion_comment: "Test variant showed 12% improvement in conversion"
  }
```

### Roll Out Winner

After experiment concludes with a winner:

1. Update feature flag to 100% for winning variant
2. Remove experiment code, keep winning implementation
3. Archive experiment
4. Document learnings

```
# Update flag to winner
mcp__posthog__update-feature-flag with:
- flagKey: "experiment_checkout_redesign"
- data: {
    filters: {
      groups: [{
        properties: [],
        rollout_percentage: 100
      }]
    },
    # Return winning variant for all users
    multivariate: {
      variants: [{ key: "test", rollout_percentage: 100 }]
    }
  }
```

## Best Practices

### Do

- Define hypothesis before starting
- Choose one primary metric
- Run for full weeks (7, 14, 21 days)
- Wait for statistical significance
- Document all experiments in Notion
- Track exposure events
- Use guardrail metrics
- Clean up code after experiment

### Don't

- Peek at results and stop early
- Change experiment mid-flight
- Run too many experiments on same users
- Ignore guardrail regressions
- Ship without significance
- Forget to track conversions
- Leave experiment code forever

## Common Patterns

### Progressive Rollout After Experiment

```typescript
// Phase 1: Experiment (50/50)
// Phase 2: Winner at 25%
// Phase 3: Winner at 50%
// Phase 4: Winner at 100%
// Phase 5: Remove flag, winner is default
```

### Mutually Exclusive Experiments

Use holdout groups to prevent user overlap:

```
mcp__posthog__experiment-create with:
- holdout_id: 456  // Users in this holdout excluded
```

### Feature + Experiment Combo

```typescript
// Feature flag for release control
const featureEnabled = useFeatureFlag('release_new_checkout');

// Experiment within feature
const { variant } = useExperiment('experiment_checkout_variant');

if (!featureEnabled) {
  return <LegacyCheckout />;
}

// Experiment only runs for users with feature enabled
return variant === 'streamlined'
  ? <CheckoutStreamlined />
  : <CheckoutStandard />;
```

## Troubleshooting

### No Exposures Recording

1. Verify experiment is in "running" state
2. Check feature flag is active
3. Ensure tracking code calls `$experiment_exposure`
4. Verify user matches targeting criteria

### Unbalanced Variants

1. Check targeting isn't biased
2. Verify randomization is working
3. Look for implementation bugs showing one variant more

### Results Not Significant

1. Calculate if sample size is sufficient
2. Consider increasing MDE threshold
3. Run longer if traffic allows
4. Accept null result if appropriate

### SRM (Sample Ratio Mismatch)

If variant split differs significantly from expected:

1. Check for bugs in variant assignment
2. Look for user-triggered variant switches
3. Verify no targeting bias
4. Consider restarting experiment
