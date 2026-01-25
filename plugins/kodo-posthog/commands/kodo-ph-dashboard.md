---
name: kodo-ph-dashboard
description: Create, manage, and organize PostHog dashboards and insights for product analytics
---

# /kodo ph-dashboard - Dashboard & Insight Management

Create, manage, and organize PostHog dashboards and insights for product analytics.

## What You Do

When the user runs `/kodo ph-dashboard [action] [dashboard-name]`:

**Actions:**
- `create` - Create a new dashboard
- `list` - List all dashboards
- `get` - Get dashboard with all insights
- `update` - Update dashboard properties
- `delete` - Delete a dashboard
- `add-insight` - Add an insight to a dashboard
- `insight` - Create or manage individual insights
- `document` - Sync dashboard documentation to Notion

### Default Behavior (no action specified)

1. **Load project context** from `.kodo/config.json`
2. **List pinned dashboards** with descriptions
3. **Show recent dashboards** with last updated times
4. **Offer to create** new dashboard or insight

### Action: `create [dashboard-name]`

1. **Validate naming**: Descriptive, audience-appropriate
2. **Prompt for configuration**:
   - Description (required)
   - Category (product, growth, technical, executive)
   - Pinned status
   - Tags
3. **Create dashboard** via MCP
4. **Document in Notion** if `sync.auto_sync_on_create` is enabled

### Action: `insight [insight-type]`

1. **Choose insight type**: trends, funnels, retention, paths, lifecycle
2. **Build query** using MCP query tools
3. **Test query** before saving
4. **Add to dashboard** or save standalone

## Commands to Execute

### List All Dashboards
```
mcp__posthog__dashboards-get-all with:
- data: {
    limit: 20,
    pinned: true  # Optional: filter pinned only
  }
```

### Get Dashboard Details
```
mcp__posthog__dashboard-get with:
- dashboardId: {dashboard_id}
```

### Create Dashboard
```
mcp__posthog__dashboard-create with:
- data: {
    name: "{dashboard_name}",
    description: "{description}",
    pinned: false,
    tags: ["{category}", "{team}"]
  }
```

### Update Dashboard
```
mcp__posthog__dashboard-update with:
- dashboardId: {dashboard_id}
- data: {
    name: "{updated_name}",
    description: "{updated_description}",
    pinned: true,
    tags: ["{updated_tags}"]
  }
```

### Delete Dashboard
```
mcp__posthog__dashboard-delete with:
- dashboardId: {dashboard_id}
```

### Add Insight to Dashboard
```
mcp__posthog__add-insight-to-dashboard with:
- data: {
    insightId: "{insight_id}",
    dashboardId: {dashboard_id}
  }
```

## Insight Operations

### List All Insights
```
mcp__posthog__insights-get-all with:
- data: {
    limit: 20,
    favorited: true,  # Optional: filter favorites
    search: "{search_term}"  # Optional: filter by name
  }
```

### Get Insight Details
```
mcp__posthog__insight-get with:
- insightId: "{insight_id}"
```

### Run Insight Query
```
mcp__posthog__insight-query with:
- insightId: "{insight_id}"
```

### Create Insight from Query
```
mcp__posthog__insight-create-from-query with:
- data: {
    name: "{insight_name}",
    description: "{description}",
    favorited: false,
    query: {
      kind: "InsightVizNode",
      source: {query_from_query_run}
    }
  }
```

### Delete Insight
```
mcp__posthog__insight-delete with:
- insightId: "{insight_id}"
```

## Query Building

### Run Test Query (Trends)
```
mcp__posthog__query-run with:
- query: {
    kind: "InsightVizNode",
    source: {
      kind: "TrendsQuery",
      series: [{
        kind: "EventsNode",
        event: "{event_name}",
        custom_name: "{display_name}",
        math: "total"  # total | dau | weekly_active | monthly_active | sum | avg | min | max
      }],
      interval: "day",  # hour | day | week | month
      dateRange: {
        date_from: "-30d",
        date_to: null
      },
      filterTestAccounts: true,
      breakdownFilter: {
        breakdown: "{property_name}",
        breakdown_type: "event"  # event | person
      },
      trendsFilter: {
        display: "ActionsLineGraph"  # ActionsLineGraph | ActionsTable | ActionsPie | ActionsBar | BoldNumber
      }
    }
  }
```

### Run Test Query (Funnels)
```
mcp__posthog__query-run with:
- query: {
    kind: "InsightVizNode",
    source: {
      kind: "FunnelsQuery",
      series: [
        { kind: "EventsNode", event: "step_1_event", custom_name: "Step 1" },
        { kind: "EventsNode", event: "step_2_event", custom_name: "Step 2" },
        { kind: "EventsNode", event: "step_3_event", custom_name: "Step 3" }
      ],
      interval: "day",
      dateRange: {
        date_from: "-30d",
        date_to: null
      },
      filterTestAccounts: true,
      funnelsFilter: {
        funnelVizType: "steps",  # steps | time_to_convert | trends
        funnelOrderType: "ordered",  # ordered | unordered | strict
        funnelWindowInterval: 14,
        funnelWindowIntervalUnit: "day"
      }
    }
  }
```

### Run HogQL Query
```
mcp__posthog__query-run with:
- query: {
    kind: "DataVisualizationNode",
    source: {
      kind: "HogQLQuery",
      query: "SELECT count() as total, properties.$browser as browser FROM events WHERE event = '{event_name}' AND timestamp > now() - interval 30 day GROUP BY browser ORDER BY total DESC LIMIT 10",
      filters: {
        dateRange: {
          date_from: "-30d"
        },
        filterTestAccounts: true
      }
    }
  }
```

### Generate Query from Natural Language
```
mcp__posthog__query-generate-hogql-from-question with:
- question: "{natural_language_description}"
```

## Insight Types Reference

| Type | Use Case | Key Configuration |
|------|----------|-------------------|
| **Trends** | Track metrics over time | `series`, `interval`, `breakdownFilter` |
| **Funnels** | Conversion flow analysis | `series` (ordered steps), `funnelWindowInterval` |
| **Retention** | User return patterns | `retentionFilter`, cohort settings |
| **Paths** | User journey mapping | `pathsFilter`, start/end events |
| **Lifecycle** | User state transitions | New, returning, dormant, resurrected |
| **Stickiness** | Engagement frequency | Days active in period |

## Display Types

| Display | Best For | Query Type |
|---------|----------|------------|
| `ActionsLineGraph` | Trends over time | Trends |
| `ActionsBar` | Period comparisons | Trends |
| `ActionsPie` | Distribution | Trends with breakdown |
| `ActionsTable` | Detailed data | Any |
| `BoldNumber` | Single KPI | Trends (single series) |
| `WorldMap` | Geographic data | Trends with geo breakdown |

## Math Operations

| Math | Description | Use Case |
|------|-------------|----------|
| `total` | Count of events | Page views, clicks |
| `dau` | Daily active users | Unique users per day |
| `weekly_active` | 7-day active users | Weekly engagement |
| `monthly_active` | 30-day active users | Monthly engagement |
| `unique_session` | Unique sessions | Session analysis |
| `sum` | Sum of property | Revenue, quantities |
| `avg` | Average of property | Order value, duration |
| `min` / `max` | Extremes | Edge cases |
| `median` | Middle value | Typical behavior |
| `p90` / `p95` / `p99` | Percentiles | Performance metrics |

## Dashboard Templates

### Product Overview Dashboard
```json
{
  "name": "Product Overview",
  "description": "Core product metrics and user engagement",
  "insights": [
    {
      "name": "Daily Active Users",
      "type": "trends",
      "display": "ActionsLineGraph",
      "math": "dau"
    },
    {
      "name": "Key Actions Funnel",
      "type": "funnels",
      "steps": ["signup_started", "signup_completed", "first_action"]
    },
    {
      "name": "Feature Adoption",
      "type": "trends",
      "display": "ActionsBar",
      "breakdown": "feature_name"
    },
    {
      "name": "Weekly Retention",
      "type": "retention",
      "period": "Week"
    }
  ]
}
```

### Growth Dashboard
```json
{
  "name": "Growth Metrics",
  "description": "Acquisition, activation, and conversion tracking",
  "insights": [
    {
      "name": "New User Signups",
      "type": "trends",
      "event": "user_signed_up",
      "breakdown": "signup_source"
    },
    {
      "name": "Activation Rate",
      "type": "funnels",
      "steps": ["user_signed_up", "onboarding_completed", "first_value_action"]
    },
    {
      "name": "Conversion by Channel",
      "type": "trends",
      "breakdown": "utm_source"
    }
  ]
}
```

### Technical Dashboard
```json
{
  "name": "Technical Health",
  "description": "Performance, errors, and system metrics",
  "insights": [
    {
      "name": "Page Load Time (p95)",
      "type": "trends",
      "math": "p95",
      "property": "duration_ms"
    },
    {
      "name": "Error Rate",
      "type": "trends",
      "event": "error_occurred",
      "breakdown": "error_type"
    },
    {
      "name": "API Response Times",
      "type": "trends",
      "math": "avg",
      "property": "response_time_ms"
    }
  ]
}
```

## Notion Documentation

### Create Dashboard Entry
```
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{dashboards_database_id}" }
- pages: [{
    properties: {
      "Dashboard Name": "{dashboard_name}",
      "ID": {dashboard_id},
      "Purpose": "{description}",
      "Category": "{product|growth|technical|executive}",
      "Audience": "{team_names}",
      "Refresh Cadence": "{realtime|daily|weekly}",
      "Pinned": true,
      "Owner": "{owner_name}",
      "PostHog URL": "https://app.posthog.com/dashboard/{dashboard_id}"
    }
  }]
```

## Property Filtering

### Event Properties Filter
```json
{
  "properties": [
    {
      "key": "plan",
      "value": "pro",
      "operator": "exact",
      "type": "event"
    }
  ]
}
```

### Person Properties Filter
```json
{
  "properties": [
    {
      "key": "email",
      "value": "@company.com",
      "operator": "icontains",
      "type": "person"
    }
  ]
}
```

### Combined Filters (AND)
```json
{
  "properties": [
    {
      "type": "AND",
      "values": [
        { "key": "plan", "value": "pro", "operator": "exact", "type": "person" },
        { "key": "country", "value": "US", "operator": "exact", "type": "person" }
      ]
    }
  ]
}
```

## Operators Reference

| Operator | Description | Example |
|----------|-------------|---------|
| `exact` | Equals | `plan = "pro"` |
| `is_not` | Not equals | `plan != "free"` |
| `icontains` | Contains (case-insensitive) | `email contains "@company"` |
| `not_icontains` | Does not contain | `email not contains "@test"` |
| `regex` | Matches regex | `path matches "^/app/"` |
| `is_set` | Property exists | `email is set` |
| `is_not_set` | Property missing | `phone is not set` |
| `gt` / `gte` | Greater than | `amount > 100` |
| `lt` / `lte` | Less than | `amount < 1000` |

## Constraints

- Maximum 20 insights per dashboard recommended
- Complex queries may timeout (use date range limits)
- Breakdowns limited to 25 values by default
- HogQL queries have execution time limits
- Test queries with `query-run` before saving as insights

## Best Practices

```markdown
## Dashboard Organization
- One dashboard per audience/purpose
- Pin critical dashboards
- Use consistent naming: "{Team} - {Purpose}"
- Add descriptions explaining metrics

## Insight Design
- Clear, descriptive names
- Appropriate time ranges
- Filter test accounts
- Use breakdowns sparingly (max 2-3)

## Performance
- Limit date ranges for large datasets
- Use sampling for exploratory analysis
- Cache results with appropriate refresh
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/SKILL.md` - Core PostHog guidance
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/dashboards.md` - Detailed dashboard patterns
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/notion-sync.md` - Documentation sync workflow

## Example

**User:** `/kodo ph-dashboard create conversion-metrics`

**Agent:**
I'll create a new dashboard for conversion metrics. Let me check existing dashboards first...

No existing "conversion-metrics" dashboard found.

**Dashboard:** `Conversion Metrics`
- **Category:** Growth
- **Audience:** Product, Growth teams
- **Purpose:** Track user conversion through key funnels

Creating the dashboard...

```typescript
// Created dashboard
{
  id: 789,
  name: "Conversion Metrics",
  description: "Track user conversion through signup, activation, and purchase funnels",
  pinned: false,
  tags: ["growth", "product"]
}
```

Dashboard created successfully!

Now let's add some insights. What conversions would you like to track?

1. **Signup Funnel**: Landing -> Signup Started -> Signup Completed
2. **Activation Funnel**: Signup -> Onboarding -> First Value Action
3. **Purchase Funnel**: Product View -> Add to Cart -> Checkout -> Purchase
4. **Custom Funnel**: Define your own steps

Should I:
1. Create all suggested funnels?
2. Create a specific funnel?
3. Add existing insights to this dashboard?
4. Document this dashboard in Notion?
