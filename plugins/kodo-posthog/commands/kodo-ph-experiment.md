---
name: kodo-ph-experiment
description: Create, monitor, and analyze PostHog experiments with proper hypothesis documentation
---

# /kodo ph-experiment - A/B Test & Experiment Management

Create, monitor, and analyze PostHog experiments with proper hypothesis documentation.

## What You Do

When the user runs `/kodo ph-experiment [action] [experiment-name]`:

**Actions:**
- `create` - Create a new A/B test experiment
- `list` - List all experiments with status
- `get` - Get experiment details and current results
- `results` - Fetch comprehensive experiment results
- `launch` - Start a draft experiment
- `stop` - Conclude a running experiment
- `update` - Modify experiment configuration
- `delete` - Delete an experiment
- `document` - Create/update Notion documentation

### Default Behavior (no action specified)

1. **Load project context** from `.kodo/config.json`
2. **List active experiments** with status and progress
3. **Show running experiments** with current sample sizes

### Action: `create [experiment-name]`

1. **Gather experiment details**:
   - Hypothesis (what we're testing and expected outcome)
   - Primary metric (conversion, engagement, revenue)
   - Secondary metrics (guardrails)
   - Variants (control + test variants)
   - Targeting (who sees the experiment)

2. **Search for existing feature flags** that might be reusable
3. **Create experiment** via MCP with proper configuration
4. **Document in Notion** if `sync.auto_sync_on_create` is enabled

### Action: `results [experiment-name]`

1. Get experiment ID from name
2. Fetch comprehensive results with metrics data
3. Display statistical significance and confidence
4. Recommend action based on results

## Commands to Execute

### List All Experiments
```
mcp__posthog__experiment-get-all with:
- data: { limit: 20 }
```

### Get Experiment Details
```
mcp__posthog__experiment-get with:
- experimentId: {experiment_id}
```

### Get Experiment Results
```
mcp__posthog__experiment-results-get with:
- experimentId: {experiment_id}
- refresh: true  # Force fresh data
```

### Create Experiment
```
mcp__posthog__experiment-create with:
- name: "{experiment_name}"
- description: "{hypothesis_statement}"
- feature_flag_key: "experiment_{snake_case_name}"
- draft: true
- primary_metrics: [{
    metric_type: "funnel",
    event_name: "{first_event}",
    funnel_steps: ["{event1}", "{event2}", "{event3}"],
    name: "{metric_name}"
  }]
- secondary_metrics: [{
    metric_type: "mean",
    event_name: "{event}",
    name: "{metric_name}"
  }]
- variants: [
    { key: "control", name: "Control", rollout_percentage: 50 },
    { key: "test", name: "Test Variant", rollout_percentage: 50 }
  ]
- minimum_detectable_effect: 20
- filter_test_accounts: true
```

### Launch Experiment (Start)
```
mcp__posthog__experiment-update with:
- experimentId: {experiment_id}
- data: { launch: true }
```

### Stop/Conclude Experiment
```
mcp__posthog__experiment-update with:
- experimentId: {experiment_id}
- data: {
    conclude: "won",  # won | lost | inconclusive | stopped_early
    conclusion_comment: "{learnings and next steps}"
  }
```

### Update Experiment
```
mcp__posthog__experiment-update with:
- experimentId: {experiment_id}
- data: {
    name: "{updated_name}",
    description: "{updated_description}",
    primary_metrics: [...],
    secondary_metrics: [...]
  }
```

### Delete Experiment
```
mcp__posthog__experiment-delete with:
- experimentId: {experiment_id}
```

### Create Notion Documentation
```
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{experiments_database_id}" }
- pages: [{
    properties: {
      "Experiment Name": "{experiment_name}",
      "Flag Key": "experiment_{snake_case_name}",
      "Hypothesis": "{hypothesis}",
      "Status": "draft",
      "Primary Metric": "{metric_name}",
      "Owner": "{owner_name}"
    }
  }]
```

## Experiment Types

| Type | Use Case | Duration | Sample Size |
|------|----------|----------|-------------|
| **Conversion** | Signup, purchase flows | 2-4 weeks | 1000+ per variant |
| **Engagement** | Feature usage, retention | 2-6 weeks | 500+ per variant |
| **Revenue** | Pricing, upsells | 4-8 weeks | Depends on AOV |
| **UX** | Layout, copy changes | 1-2 weeks | 2000+ per variant |

## Metric Types

### Funnel Metric (Conversion)
```json
{
  "metric_type": "funnel",
  "event_name": "checkout_started",
  "funnel_steps": ["checkout_started", "payment_entered", "purchase_completed"],
  "name": "Checkout Conversion"
}
```

### Mean Metric (Average Value)
```json
{
  "metric_type": "mean",
  "event_name": "purchase_completed",
  "name": "Average Order Value",
  "properties": { "property": "amount_cents" }
}
```

### Ratio Metric
```json
{
  "metric_type": "ratio",
  "event_name": "feature_used",
  "name": "Feature Adoption Rate"
}
```

## Hypothesis Template

```markdown
## Hypothesis Statement

We believe that **[change being tested]**
will result in **[expected outcome]**
for **[target user segment]**
because **[reasoning/evidence]**.

## Success Criteria
- Primary: [metric] increases by [X]%
- Guardrail: [metric] does not decrease by more than [Y]%

## Minimum Detectable Effect
We want to detect a [Z]% change with 95% confidence.
```

## Variant Configuration

### Standard A/B Test (50/50)
```json
{
  "variants": [
    { "key": "control", "name": "Control", "rollout_percentage": 50 },
    { "key": "test", "name": "Test", "rollout_percentage": 50 }
  ]
}
```

### A/B/C Test (Multi-variant)
```json
{
  "variants": [
    { "key": "control", "name": "Control", "rollout_percentage": 34 },
    { "key": "variant_a", "name": "Variant A", "rollout_percentage": 33 },
    { "key": "variant_b", "name": "Variant B", "rollout_percentage": 33 }
  ]
}
```

### Conservative Rollout (80/20)
```json
{
  "variants": [
    { "key": "control", "name": "Control", "rollout_percentage": 80 },
    { "key": "test", "name": "Test", "rollout_percentage": 20 }
  ]
}
```

## Implementation Templates

### React Hook for Variants
```typescript
import { useFeatureFlag } from '@/lib/posthog';

function CheckoutFlow() {
  const variant = useFeatureFlag('experiment_new_checkout');

  // variant is 'control', 'test', or false if not in experiment
  switch (variant) {
    case 'test':
      return <NewCheckoutFlow />;
    case 'control':
    default:
      return <CurrentCheckoutFlow />;
  }
}
```

### With Payload for Configuration
```typescript
import { useFeatureFlagPayload } from '@/lib/posthog';

function PricingPage() {
  const config = useFeatureFlagPayload('experiment_pricing_test');

  if (!config) return <DefaultPricing />;

  return (
    <PricingGrid
      showAnnualToggle={config.showAnnualToggle}
      highlightedPlan={config.highlightedPlan}
      ctaText={config.ctaText}
    />
  );
}
```

### Server-Side Assignment
```typescript
import { posthog } from '@/lib/posthog-server';

async function getExperimentVariant(userId: string, experimentKey: string) {
  const variant = await posthog.getFeatureFlag(experimentKey, userId);

  // Track exposure
  posthog.capture({
    distinctId: userId,
    event: '$feature_flag_called',
    properties: {
      $feature_flag: experimentKey,
      $feature_flag_response: variant,
    },
  });

  return variant;
}
```

## Results Interpretation

### Statistical Significance
- **95%+ confidence**: Safe to declare winner
- **90-95% confidence**: Consider extending experiment
- **<90% confidence**: Inconclusive, need more data

### Decision Framework
```markdown
## When to Stop

STOP if:
- Reached 95% significance
- Clear winner with meaningful lift
- Guardrail metrics violated
- Business priority changed

EXTEND if:
- 80-95% significance
- Trending positive but need more data
- Seasonal effects suspected

STOP EARLY if:
- Negative impact on guardrails
- Critical bugs discovered
- Experiment logic broken
```

## Constraints

- Minimum 1000 users per variant for reliable results
- Run for at least 1 full business cycle (usually 1 week)
- Don't peek at results before planned analysis time
- Document all experiment changes
- Clean up feature flags after conclusion

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/SKILL.md` - Core PostHog guidance
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/experiments.md` - Detailed experiment patterns
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/feature-flags.md` - Flag configuration for experiments
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/notion-sync.md` - Documentation sync workflow

## Example

**User:** `/kodo ph-experiment create new_onboarding_flow`

**Agent:**
I'll help create an A/B test for the new onboarding flow. Let me first check for any existing experiments or flags...

No existing experiment found for this feature.

**Experiment Setup:**

**Name:** New Onboarding Flow Test
**Flag Key:** `experiment_new_onboarding_flow`
**Type:** Conversion experiment

**Hypothesis:**
We believe that the new streamlined onboarding flow will increase activation rates because it reduces friction by 3 steps.

**Metrics:**
- **Primary:** Onboarding completion rate (funnel)
- **Secondary:** Time to first value action
- **Guardrail:** User retention (Day 7)

**Variants:**
- Control (50%): Current 7-step onboarding
- Test (50%): New 4-step onboarding

Creating the experiment...

```typescript
// Experiment created
{
  id: 456,
  name: "New Onboarding Flow Test",
  feature_flag_key: "experiment_new_onboarding_flow",
  status: "draft",
  primary_metrics: [{
    metric_type: "funnel",
    funnel_steps: ["onboarding_started", "profile_completed", "first_action"],
    name: "Onboarding Completion"
  }]
}
```

Experiment created in draft mode!

**Implementation code:**
```typescript
// Add to your onboarding component
const variant = useFeatureFlag('experiment_new_onboarding_flow');

return variant === 'test'
  ? <NewOnboarding />
  : <CurrentOnboarding />;
```

Should I:
1. Launch the experiment now?
2. Create Notion documentation?
3. Add the implementation to a specific file?
4. Set up a results dashboard?
