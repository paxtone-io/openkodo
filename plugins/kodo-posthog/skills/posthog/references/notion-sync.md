# PostHog Notion Documentation Sync Reference

Comprehensive guide for maintaining analytics documentation in Notion synchronized with PostHog configuration.

## Prerequisites

**Run `/kodo notion-init` first** to automatically create all required databases with proper Relations.

The command will:
1. Find your teamspace (configured in `.kodo/config.json`)
2. Create "Docs Hub" parent page under Teamspace Home
3. Create all databases with bidirectional Relations
4. Store database IDs in config for future sync operations

## Documentation Structure

### Databases (Auto-Created by /kodo notion-init)

All databases are created under "Docs Hub" with proper Relations.

#### 1. Events Database

| Property | Type | Purpose |
|----------|------|---------|
| Event Name | Title | Snake_case event name |
| Domain | Select | `user_`, `subscription_`, `feature_`, etc. |
| Category | Select | `conversion`, `engagement`, `error`, `system` |
| Description | Text | What the event tracks |
| Properties | Text/Table | Property schema (JSON or table) |
| Implementation Status | Select | `planned`, `implemented`, `deprecated` |
| Tracked On | Multi-select | `frontend`, `backend`, `both` |
| Feature Area | Multi-select | Product areas using this event |
| Owner | Person | Team member responsible |
| Created | Date | When event was added |
| Last Updated | Date | Last modification date |

#### 2. Feature Flags Database

| Property | Type | Purpose |
|----------|------|---------|
| Flag Key | Title | PostHog flag key |
| Name | Text | Human-readable name |
| Type | Select | `release`, `experiment`, `ops`, `beta`, `config` |
| Status | Select | `draft`, `active`, `rolling_out`, `archived` |
| Rollout % | Number | Current rollout percentage |
| Targeting | Text | Targeting rules description |
| Owner | Person | Team member responsible |
| Created | Date | When flag was created |
| Planned Removal | Date | When to clean up |
| Related PR | URL | Implementation PR link |
| Notes | Text | Additional context |

#### 3. Experiments Database

| Property | Type | Purpose |
|----------|------|---------|
| Experiment Name | Title | Descriptive experiment name |
| Flag Key | Text | Associated feature flag |
| Hypothesis | Text | What we're testing |
| Status | Select | `draft`, `running`, `concluded`, `archived` |
| Primary Metric | Text | Main success metric |
| Secondary Metrics | Text | Additional metrics |
| Start Date | Date | Experiment launch |
| End Date | Date | Conclusion date |
| Result | Select | `won`, `lost`, `inconclusive`, `stopped_early` |
| Winner Variant | Text | Winning variant key |
| Learnings | Text | Key takeaways |
| Owner | Person | Experiment owner |
| Related Docs | Relation | Links to feature specs |

#### 4. Dashboards Database

| Property | Type | Purpose |
|----------|------|---------|
| Dashboard Name | Title | PostHog dashboard name |
| ID | Number | PostHog dashboard ID |
| Purpose | Text | What it monitors |
| Category | Select | `product`, `growth`, `technical`, `executive` |
| Audience | Multi-select | Who uses this dashboard |
| Refresh Cadence | Select | `realtime`, `daily`, `weekly` |
| Pinned | Checkbox | Is it pinned in PostHog |
| Owner | Person | Dashboard maintainer |
| PostHog URL | URL | Direct link to dashboard |
| Last Reviewed | Date | Last review date |

## Sync Workflow

### Initial Setup

```markdown
## Step 1: Create Notion Databases
1. Create databases with schema above
2. Add database IDs to `.kodo/config.json`
3. Set up database views for different workflows

## Step 2: Import Existing PostHog Data
Use MCP tools to fetch and document existing configuration:

# Get all events
mcp__posthog__event-definitions-list

# Get all feature flags
mcp__posthog__feature-flag-get-all

# Get all experiments
mcp__posthog__experiment-get-all

# Get all dashboards
mcp__posthog__dashboards-get-all
```

### Ongoing Sync Process

```markdown
## When Creating New Events
1. Document in Notion Events database FIRST
2. Get team review/approval
3. Implement tracking code
4. Verify in PostHog Live Events
5. Update status to "implemented"

## When Creating Feature Flags
1. Create Notion entry with purpose and targeting plan
2. Use MCP to create flag in PostHog
3. Link PR in Notion entry
4. Update status as rollout progresses
5. Set removal date when at 100%

## When Running Experiments
1. Document hypothesis in Notion
2. Create experiment via MCP
3. Track progress in Notion
4. Document results and learnings
5. Archive with conclusions
```

## Configuration Reference

### .kodo/config.json Structure

**User-defined fields (set before running /kodo notion-init):**

```json
{
  "notion": {
    "teamspace": "MyTeamspace",
    "idPrefix": "KODO"
  },
  "posthog": {
    "projectId": "your_project_id",
    "organizationSlug": "your_org_slug",
    "regionUrl": "https://us.posthog.com"
  }
}
```

**Auto-populated by /kodo notion-init:**

```json
{
  "notion": {
    "teamspace": "MyTeamspace",
    "idPrefix": "KODO",
    "_populated_by_init": {
      "teamspaceId": "2dd8f777-9a35-8128-afcf-00423bbf2c56",
      "docsHub": {
        "pageId": "uuid",
        "url": "https://notion.so/..."
      },
      "databases": {
        "features": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "tasks": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "eventProperties": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "events": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "featureFlags": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "experiments": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." },
        "dashboards": { "id": "uuid", "dataSourceId": "collection://uuid", "url": "..." }
      }
    },
    "sync": {
      "autoSyncOnCreate": true,
      "requireNotionEntry": true
    }
  }
}
```

### Environment Variables

```bash
# PostHog (usually via MCP server config)
POSTHOG_API_KEY=phx_...
POSTHOG_PROJECT_ID=12345

# Notion (usually via MCP server config)
NOTION_API_KEY=ntn_...
```

## MCP Integration Patterns

### Fetching PostHog Data for Notion Sync

```markdown
## Get Events for Documentation
mcp__posthog__event-definitions-list with:
- limit: 100
- q: "user_"  # Optional: filter by prefix

## Get Flag Details for Notion
mcp__posthog__feature-flag-get-definition with:
- flagKey: "release_new_feature"

## Get Experiment for Documentation
mcp__posthog__experiment-get with:
- experimentId: 123

## Get Dashboard Info
mcp__posthog__dashboard-get with:
- dashboardId: 456
```

### Creating Notion Entries

Use the `dataSourceId` from config (`notion._populated_by_init.databases.{db}.dataSourceId`):

```markdown
## Create Event Documentation Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{events_dataSourceId from config}" }
- pages: [{
    properties: {
      "Event Name": "user_signed_up",
      "Event Type": "Custom Event",
      "Implementation Status": "Not Started",
      "Feature/Area": "Authentication",
      "Notes": "Fired when user completes signup flow"
    }
  }]

## Create Feature Flag Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{featureFlags_dataSourceId from config}" }
- pages: [{
    properties: {
      "Flag Key": "release_new_dashboard",
      "Name": "New Dashboard Release",
      "Type": "release",
      "Status": "Draft",
      "Rollout %": 0
    }
  }]
```

### Searching Existing Documentation

Use the `dataSourceId` for targeted searches:

```markdown
## Find Event Documentation
mcp__plugin_Notion_notion__notion-search with:
- query: "user_signed_up"
- data_source_url: "{events_dataSourceId from config}"

## Find Flag Documentation
mcp__plugin_Notion_notion__notion-search with:
- query: "release_new"
- data_source_url: "{featureFlags_dataSourceId from config}"

## Search within Teamspace (broader search)
mcp__plugin_Notion_notion__notion-search with:
- query: "dashboard"
- teamspace_id: "{teamspaceId from config}"
```

### Updating Documentation

```markdown
## Update Flag Status After Rollout Change
mcp__plugin_Notion_notion__notion-update-page with:
- data: {
    page_id: "notion_page_id",
    command: "update_properties",
    properties: {
      "Status": "rolling_out",
      "Rollout %": 25
    }
  }

## Update Experiment Results
mcp__plugin_Notion_notion__notion-update-page with:
- data: {
    page_id: "experiment_page_id",
    command: "update_properties",
    properties: {
      "Status": "concluded",
      "Result": "won",
      "Winner Variant": "test",
      "End Date": "2024-01-15"
    }
  }
```

## Sync Automation Patterns

### Event Creation Workflow

```markdown
## 1. Document First
Create Notion entry with:
- Event name following naming conventions
- Property schema definition
- Implementation notes

## 2. Implement Tracking
Add tracking code following events.md patterns

## 3. Verify and Update
- Check PostHog Live Events
- Update Notion status to "implemented"
- Add any discovered properties
```

### Feature Flag Lifecycle

```markdown
## Draft Phase
1. Create Notion entry (Status: draft)
2. Define targeting strategy
3. Get stakeholder approval

## Implementation Phase
1. Create flag via MCP (active: false)
2. Link implementation PR
3. Update Notion status: "active"

## Rollout Phase
1. Update rollout % in PostHog via MCP
2. Sync rollout % to Notion
3. Monitor dashboards

## Cleanup Phase
1. Remove flag checks from code
2. Delete or archive flag in PostHog
3. Update Notion status: "archived"
4. Document any learnings
```

### Experiment Documentation

```markdown
## Pre-Launch
1. Create Notion entry with hypothesis
2. Define metrics (primary + secondary)
3. Calculate required sample size
4. Get stakeholder approval

## Running
1. Create experiment via MCP
2. Update Notion with start date
3. Link to PostHog experiment
4. Monitor via dashboards

## Conclusion
1. Get results via MCP
2. Document findings in Notion
3. Record winner and learnings
4. Plan follow-up actions
```

## Best Practices

### Documentation Quality

- **Be specific**: Include exact property names and types
- **Keep current**: Update status as things change
- **Link resources**: Connect PRs, dashboards, related docs
- **Record decisions**: Document why, not just what
- **Review regularly**: Schedule quarterly audits

### Sync Discipline

```markdown
DO:
- Document before implementing
- Update Notion when PostHog changes
- Use consistent naming across both systems
- Archive rather than delete
- Include ownership and dates

DON'T:
- Create PostHog items without Notion entries
- Leave stale documentation
- Skip property documentation
- Forget to update status
- Delete without archiving first
```

### Team Workflow

```markdown
## For Product Managers
- Review experiment hypotheses before launch
- Document feature requirements in Notion
- Use dashboards for progress tracking

## For Engineers
- Check Notion for event schemas before implementing
- Update flag status during rollouts
- Document technical implementation details

## For Analysts
- Maintain dashboard documentation
- Review experiment results
- Update metrics definitions
```

## Troubleshooting

### Sync Issues

| Problem | Solution |
|---------|----------|
| Notion entry doesn't match PostHog | Re-fetch via MCP and update Notion |
| Missing events in documentation | Run event-definitions-list and compare |
| Stale flag status | Check PostHog and update Notion status |
| Experiment results not documented | Use experiment-results-get and update |

### Common Mistakes

1. **Creating flags without documentation**
   - Always create Notion entry first
   - Include purpose, targeting, and cleanup plan

2. **Not updating rollout status**
   - Sync % after each rollout change
   - Set calendar reminders for updates

3. **Leaving concluded experiments undocumented**
   - Document results within 48 hours
   - Include learnings and next steps

4. **Orphaned dashboards**
   - Review dashboard list quarterly
   - Archive unused dashboards

## Templates

### Event Documentation Template

```markdown
# Event: {event_name}

## Overview
- **Domain**: {domain}
- **Category**: {category}
- **Tracked On**: {frontend/backend/both}

## Description
{What this event tracks and when it fires}

## Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| prop_name | string | Yes | Description |

## Implementation Notes
{Any special implementation details}

## Related Events
- {related_event_1}
- {related_event_2}

## Dashboards Using This Event
- {dashboard_name}
```

### Feature Flag Documentation Template

```markdown
# Flag: {flag_key}

## Overview
- **Type**: {release/experiment/ops/beta}
- **Status**: {draft/active/rolling_out/archived}
- **Owner**: {owner_name}

## Purpose
{Why this flag exists}

## Targeting
{Who sees this flag and rules}

## Rollout Plan
- [ ] 0% - Draft
- [ ] 5% - Internal testing
- [ ] 25% - Early adopters
- [ ] 50% - Wider rollout
- [ ] 100% - Full release

## Implementation
- PR: {link}
- Files: {affected files}

## Cleanup Plan
- Planned removal: {date}
- Cleanup PR: {link when ready}
```

### Experiment Documentation Template

```markdown
# Experiment: {experiment_name}

## Hypothesis
We believe that {change}
will result in {outcome}
for {user_segment}
because {reasoning}.

## Metrics
- **Primary**: {metric_name} - {definition}
- **Secondary**: {metric_names}
- **Guardrails**: {metric_names}

## Variants
- **Control**: {description}
- **Test**: {description}

## Timeline
- Start: {date}
- Expected duration: {weeks}
- End: {date}

## Results
- **Winner**: {variant}
- **Lift**: {percentage}
- **Confidence**: {percentage}

## Learnings
{Key takeaways and next steps}
```
