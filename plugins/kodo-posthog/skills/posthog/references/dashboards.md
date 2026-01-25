# PostHog Dashboards & Insights Reference

Comprehensive guide for creating dashboards, insights, and data visualizations.

## Insight Types

### Trends

Time-series visualization of events over time.

```
Use cases:
- Daily/weekly/monthly active users
- Feature usage over time
- Conversion trends
- Error rate monitoring
```

**MCP Creation:**
```
mcp__posthog__query-run with:
- query: {
    kind: "InsightVizNode",
    source: {
      kind: "TrendsQuery",
      series: [{
        kind: "EventsNode",
        event: "user_signed_up",
        custom_name: "Signups"
      }],
      interval: "day",
      dateRange: { date_from: "-30d" }
    }
  }
```

**Configuration Options:**

| Option | Values | Purpose |
|--------|--------|---------|
| `interval` | hour, day, week, month | Aggregation period |
| `display` | ActionsLineGraph, ActionsBar, BoldNumber | Visualization type |
| `math` | total, dau, weekly_active, avg, sum, min, max | Aggregation method |
| `compare` | true/false | Show previous period |

### Funnels

Conversion flow analysis through sequential steps.

```
Use cases:
- Signup -> Activation -> Purchase
- Onboarding completion
- Checkout flow optimization
- Feature adoption journeys
```

**MCP Creation:**
```
mcp__posthog__query-run with:
- query: {
    kind: "InsightVizNode",
    source: {
      kind: "FunnelsQuery",
      series: [
        { kind: "EventsNode", event: "page_viewed", custom_name: "Viewed" },
        { kind: "EventsNode", event: "signup_started", custom_name: "Started Signup" },
        { kind: "EventsNode", event: "signup_completed", custom_name: "Completed" }
      ],
      funnelsFilter: {
        funnelVizType: "steps",
        funnelOrderType: "ordered",
        funnelWindowInterval: 14,
        funnelWindowIntervalUnit: "day"
      }
    }
  }
```

**Funnel Options:**

| Option | Values | Purpose |
|--------|--------|---------|
| `funnelOrderType` | ordered, unordered, strict | Step sequence requirement |
| `funnelVizType` | steps, time_to_convert, trends | Visualization mode |
| `funnelWindowInterval` | number | Conversion window |
| `funnelWindowIntervalUnit` | minute, hour, day, week, month | Window unit |

### Retention

User return behavior over time cohorts.

```
Use cases:
- Week 1/2/4 retention rates
- Feature stickiness
- Cohort analysis
- Churn prediction signals
```

**Retention Periods:**
- Day 0: Initial action
- Day 1, 7, 14, 30: Return measurements
- Unbounded: Any return within period

### Paths

User journey visualization between events.

```
Use cases:
- Navigation patterns
- Drop-off discovery
- Unexpected user flows
- Entry/exit point analysis
```

### Lifecycle

User state transitions over time.

```
States:
- New: First time performing action
- Returning: Performed in previous and current period
- Resurrecting: Returned after being dormant
- Dormant: Previously active, now inactive
```

### Stickiness

How often users perform an action.

```
Use cases:
- Feature engagement depth
- Power user identification
- Habit formation tracking
```

## Dashboard Design Patterns

### Product Overview Dashboard

Essential metrics for daily monitoring:

```markdown
## Sections

### 1. Key Metrics (Top Row - BoldNumber display)
- DAU (Daily Active Users)
- Signups (today)
- Conversion Rate (7-day)
- Revenue (if applicable)

### 2. Trends (Middle)
- DAU/WAU/MAU trend (line chart)
- Core action trend (line chart)

### 3. Funnels (Bottom Left)
- Primary conversion funnel
- Onboarding completion funnel

### 4. Retention (Bottom Right)
- Week 1 retention cohort
- Feature retention
```

**MCP Creation:**
```
# Create dashboard
mcp__posthog__dashboard-create with:
- name: "Product Overview"
- description: "Daily monitoring of key product metrics"
- pinned: true

# Create insights and add to dashboard
mcp__posthog__insight-create-from-query with:
- data: {
    name: "Daily Active Users",
    query: { kind: "InsightVizNode", source: {...} },
    favorited: true
  }

mcp__posthog__add-insight-to-dashboard with:
- insightId: "created_insight_id"
- dashboardId: dashboard_id
```

### Feature Adoption Dashboard

Track specific feature performance:

```markdown
## Sections

### 1. Adoption Metrics
- Users who discovered feature (trend)
- Users who used feature (trend)
- Adoption rate (percentage)

### 2. Engagement Depth
- Usage frequency distribution
- Time spent in feature
- Actions per session

### 3. Conversion Impact
- Funnel with/without feature usage
- Revenue correlation (if applicable)

### 4. User Segments
- Breakdown by plan type
- Breakdown by user tenure
- Geographic distribution
```

### Experiment Dashboard

Monitor active experiments:

```markdown
## Sections

### 1. Experiment Status
- Active experiments list
- Sample sizes per variant
- Days running

### 2. Primary Metrics
- Conversion rates by variant
- Confidence intervals
- Statistical significance indicator

### 3. Secondary Metrics
- Engagement metrics by variant
- Guardrail metrics status

### 4. Historical Results
- Past experiment outcomes
- Cumulative learnings
```

### Technical Health Dashboard

Monitor application performance:

```markdown
## Sections

### 1. Error Tracking
- Error event trend
- Error rate by feature area
- Top errors table

### 2. Performance
- API response times (if tracked)
- Page load events
- Client-side errors

### 3. SDK Health
- SDK versions in use
- Event volume trend
- Failed event rate
```

## Insight Best Practices

### Naming Conventions

```
{metric_type} - {subject} ({timeframe})

Examples:
- Trend - Daily Active Users (30d)
- Funnel - Signup to Purchase (14d window)
- Retention - Week 1 by Cohort
- Breakdown - Feature Usage by Plan
```

### Filter Strategies

**Filter Test Accounts:**
```
Always set filterTestAccounts: true in production dashboards
```

**Common Filters:**
```typescript
// By user property
properties: [
  { key: "plan", value: "pro", operator: "exact" }
]

// By event property
properties: [
  { key: "feature_area", value: "dashboard", operator: "exact" }
]

// Exclude internal
properties: [
  { key: "email", value: "@yourcompany.com", operator: "not_icontains" }
]
```

### Breakdown Dimensions

Useful breakdown properties:

| Property | Use Case |
|----------|----------|
| `$browser` | Cross-browser behavior |
| `$device_type` | Desktop vs Mobile |
| `$geoip_country_code` | Geographic patterns |
| `plan` | Segment by pricing tier |
| `feature_area` | Usage by product area |
| `$referring_domain` | Traffic sources |

### Date Range Strategies

```
Daily monitoring: -7d to today
Weekly review: -30d to today
Monthly review: -90d to today
Trend analysis: -12mo to today
Comparison: -30d with compare enabled
```

## MCP Dashboard Commands

### List Dashboards

```
mcp__posthog__dashboards-get-all with:
- data: {
    limit: 20,
    pinned: true,  // Optional: only pinned
    search: "overview"  // Optional: search term
  }
```

### Create Dashboard

```
mcp__posthog__dashboard-create with:
- name: "Dashboard Name"
- description: "Purpose and audience"
- pinned: true
- tags: ["product", "weekly-review"]
```

### Update Dashboard

```
mcp__posthog__dashboard-update with:
- dashboardId: 123
- data: {
    name: "Updated Name",
    description: "Updated description",
    pinned: false
  }
```

### Delete Dashboard

```
mcp__posthog__dashboard-delete with:
- dashboardId: 123
```

## MCP Insight Commands

### Run Query (Test)

```
mcp__posthog__query-run with:
- query: {
    kind: "InsightVizNode",
    source: {
      kind: "TrendsQuery",
      series: [...],
      ...
    }
  }
```

### Create Insight

```
mcp__posthog__insight-create-from-query with:
- data: {
    name: "Insight Name",
    description: "What this measures",
    query: { ... },  // From successful query-run
    favorited: false,
    tags: ["feature-x"]
  }
```

### Get Insight

```
mcp__posthog__insight-get with:
- insightId: "abc123"
```

### Query Insight (Get Results)

```
mcp__posthog__insight-query with:
- insightId: "abc123"
```

### Update Insight

```
mcp__posthog__insight-update with:
- insightId: "abc123"
- data: {
    name: "Updated Name",
    query: { ... }
  }
```

### Add to Dashboard

```
mcp__posthog__add-insight-to-dashboard with:
- insightId: "abc123"
- dashboardId: 456
```

## HogQL for Advanced Queries

For complex analysis beyond standard insights:

```
mcp__posthog__query-generate-hogql-from-question with:
- question: "Show me the top 10 users by event count in the last 30 days"
```

**When to Use HogQL:**
- Complex joins or subqueries
- Custom aggregations
- Data exploration
- One-off analysis

**When to Use Standard Insights:**
- Recurring metrics
- Dashboard visualizations
- Team-shared insights
- Standard patterns

## Dashboard Organization

### Tagging Strategy

```
Tags:
- product      -> Product metrics dashboards
- growth       -> Growth/acquisition focused
- engagement   -> User engagement metrics
- revenue      -> Revenue/billing metrics
- technical    -> Technical health
- experiment   -> A/B test monitoring
- weekly       -> Weekly review dashboards
- executive    -> Leadership summaries
```

### Access Patterns

```
Pinned Dashboards:
- Daily operational dashboards
- Key metric dashboards
- Active experiment monitors

Regular Dashboards:
- Feature-specific deep dives
- Historical analysis
- Ad-hoc investigations
```

## Troubleshooting

### No Data Showing

1. Check date range includes events
2. Verify event names are exact matches
3. Check filter properties exist on events
4. Confirm test account filter isn't excluding all data

### Slow Dashboard Loading

1. Reduce number of insights per dashboard
2. Shorten date ranges
3. Simplify breakdown dimensions
4. Consider sampling for exploration

### Inconsistent Numbers

1. Verify unique user counting (distinct_id)
2. Check for duplicate events
3. Confirm timezone settings
4. Review filter consistency across insights
