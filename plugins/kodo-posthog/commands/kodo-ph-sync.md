---
name: kodo-ph-sync
description: Synchronize PostHog analytics configuration with Notion documentation
---

# /kodo ph-sync - PostHog Notion Documentation Sync

Synchronize PostHog analytics configuration with Notion documentation.

## What You Do

When the user runs `/kodo ph-sync [action] [resource-type]`:

**Actions:**
- `status` - Check sync status between PostHog and Notion
- `import` - Import existing PostHog data to Notion
- `export` - Export Notion documentation to compare with PostHog
- `audit` - Find discrepancies between PostHog and Notion
- `setup` - Initialize Notion databases for analytics documentation

**Resource Types:**
- `events` - Event definitions and tracking plan
- `flags` - Feature flag documentation
- `experiments` - A/B test documentation
- `dashboards` - Dashboard catalog
- `all` - All resource types

### Default Behavior (no action specified)

1. **Load project context** from `.kodo/config.json`
2. **Check sync status** for all resource types
3. **Report discrepancies** between PostHog and Notion
4. **Offer sync actions** based on findings

### Action: `status`

1. Count resources in PostHog via MCP
2. Count documented resources in Notion
3. Identify missing documentation
4. Show last sync timestamps

### Action: `import [resource-type]`

1. Fetch all resources from PostHog
2. Check existing Notion entries
3. Create missing entries
4. Update stale entries

### Action: `audit`

1. Compare PostHog and Notion resources
2. Identify:
   - Undocumented PostHog resources
   - Orphaned Notion entries (no PostHog match)
   - Stale documentation (status mismatch)
3. Generate audit report

### Action: `setup`

1. Create Notion databases with proper schemas
2. Configure `.kodo/config.json` with database IDs
3. Create initial documentation structure

## Commands to Execute

### Get PostHog Resource Counts

```
# Events
mcp__posthog__event-definitions-list with:
- limit: 100

# Feature Flags
mcp__posthog__feature-flag-get-all with:
- data: { limit: 100 }

# Experiments
mcp__posthog__experiment-get-all with:
- data: { limit: 100 }

# Dashboards
mcp__posthog__dashboards-get-all with:
- data: { limit: 100 }
```

### Search Notion Documentation

```
# Search Events Database
mcp__plugin_Notion_notion__notion-search with:
- query: ""
- data_source_url: "collection://{events_database_id}"

# Search Flags Database
mcp__plugin_Notion_notion__notion-search with:
- query: ""
- data_source_url: "collection://{flags_database_id}"

# Search Experiments Database
mcp__plugin_Notion_notion__notion-search with:
- query: ""
- data_source_url: "collection://{experiments_database_id}"

# Search Dashboards Database
mcp__plugin_Notion_notion__notion-search with:
- query: ""
- data_source_url: "collection://{dashboards_database_id}"
```

### Create Notion Database Entry

```
# Event Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{events_database_id}" }
- pages: [{
    properties: {
      "Event Name": "{event_name}",
      "Domain": "{domain_prefix}",
      "Category": "{category}",
      "Description": "{description}",
      "Implementation Status": "implemented",
      "Tracked On": "{frontend|backend|both}"
    }
  }]

# Flag Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{flags_database_id}" }
- pages: [{
    properties: {
      "Flag Key": "{flag_key}",
      "Name": "{human_readable_name}",
      "Type": "{release|experiment|ops|permission}",
      "Status": "{draft|active|rolling_out|archived}",
      "Rollout %": {rollout_percentage},
      "Owner": "{owner_name}"
    }
  }]

# Experiment Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{experiments_database_id}" }
- pages: [{
    properties: {
      "Experiment Name": "{experiment_name}",
      "Flag Key": "{feature_flag_key}",
      "Hypothesis": "{hypothesis}",
      "Status": "{draft|running|concluded|archived}",
      "Primary Metric": "{metric_name}",
      "Owner": "{owner_name}"
    }
  }]

# Dashboard Entry
mcp__plugin_Notion_notion__notion-create-pages with:
- parent: { data_source_id: "{dashboards_database_id}" }
- pages: [{
    properties: {
      "Dashboard Name": "{dashboard_name}",
      "ID": {dashboard_id},
      "Purpose": "{description}",
      "Category": "{product|growth|technical|executive}",
      "Pinned": {true|false},
      "PostHog URL": "https://app.posthog.com/dashboard/{dashboard_id}"
    }
  }]
```

### Update Notion Entry

```
mcp__plugin_Notion_notion__notion-update-page with:
- data: {
    page_id: "{notion_page_id}",
    command: "update_properties",
    properties: {
      "Status": "{new_status}",
      "Rollout %": {new_percentage},
      "Last Updated": "{iso_date}"
    }
  }
```

### Fetch Notion Database

```
mcp__plugin_Notion_notion__notion-fetch with:
- id: "{database_id}"
```

## Database Schemas

### Events Database

| Property | Type | Purpose |
|----------|------|---------|
| Event Name | Title | Snake_case event name |
| Domain | Select | `user_`, `subscription_`, `feature_`, etc. |
| Category | Select | `conversion`, `engagement`, `error`, `system` |
| Description | Text | What the event tracks |
| Properties | Text | Property schema (JSON) |
| Implementation Status | Select | `planned`, `implemented`, `deprecated` |
| Tracked On | Multi-select | `frontend`, `backend`, `both` |
| Feature Area | Multi-select | Product areas using this event |
| Owner | Person | Team member responsible |
| Created | Date | When event was added |
| Last Updated | Date | Last modification date |

### Feature Flags Database

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

### Experiments Database

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

### Dashboards Database

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

## Sync Workflows

### Initial Import

```markdown
## Step 1: Setup Notion Databases
Create databases with schemas above (or use /kodo ph-sync setup)

## Step 2: Configure .kodo/config.json
Add database IDs to config file

## Step 3: Import Existing Data
Run `/kodo ph-sync import all` to populate Notion from PostHog

## Step 4: Verify Import
Review imported entries for accuracy
```

### Ongoing Sync Process

```markdown
## When Creating New Resources
1. Document in Notion FIRST (if require_notion_entry is true)
2. Create in PostHog via MCP
3. Update Notion status to "implemented"

## Periodic Audit
1. Run `/kodo ph-sync audit` weekly
2. Address discrepancies
3. Archive deprecated resources
```

## Status Mapping

### Feature Flag Status

| PostHog State | Notion Status |
|---------------|---------------|
| active=false, rollout=0 | `draft` |
| active=true, rollout<100 | `rolling_out` |
| active=true, rollout=100 | `active` |
| deleted | `archived` |

### Experiment Status

| PostHog State | Notion Status |
|---------------|---------------|
| start_date=null | `draft` |
| start_date set, end_date=null | `running` |
| end_date set | `concluded` |
| archived=true | `archived` |

## Audit Report Format

```markdown
# PostHog-Notion Sync Audit Report
Generated: {timestamp}

## Summary
- Events: {posthog_count} in PostHog, {notion_count} in Notion
- Flags: {posthog_count} in PostHog, {notion_count} in Notion
- Experiments: {posthog_count} in PostHog, {notion_count} in Notion
- Dashboards: {posthog_count} in PostHog, {notion_count} in Notion

## Issues Found

### Undocumented Resources
These exist in PostHog but not in Notion:
- [ ] Event: `{event_name}`
- [ ] Flag: `{flag_key}`
- [ ] Dashboard: `{dashboard_name}`

### Orphaned Documentation
These exist in Notion but not in PostHog:
- [ ] Event: `{event_name}` - Consider archiving or removing
- [ ] Flag: `{flag_key}` - May have been deleted

### Status Mismatches
Documentation status doesn't match PostHog state:
- [ ] Flag `{flag_key}`: Notion says "draft", PostHog is active at 50%
- [ ] Experiment `{name}`: Notion says "running", PostHog concluded

## Recommended Actions
1. Document undocumented resources
2. Archive or remove orphaned entries
3. Update status mismatches
```

## Configuration Reference

### .kodo/config.json Structure

```json
{
  "posthog": {
    "project_id": "your_project_id",
    "organization_slug": "your_org_slug",
    "region_url": "https://us.posthog.com"
  },
  "notion": {
    "authMethod": "api-token",
    "tokenEnvVar": "NOTION_API_KEY",
    "databases": {
      "events": "notion_database_id_for_events",
      "feature_flags": "notion_database_id_for_flags",
      "experiments": "notion_database_id_for_experiments",
      "dashboards": "notion_database_id_for_dashboards"
    },
    "pages": {
      "analytics_home": "notion_page_id_for_analytics_docs",
      "tracking_plan": "notion_page_id_for_tracking_plan"
    }
  },
  "sync": {
    "auto_sync_on_create": true,
    "require_notion_entry": false
  }
}
```

## Authentication

This command uses:
- **PostHog**: PostHog MCP server (standard Claude Code MCP)
- **Notion**: API Integration Token (no per-session auth required)

Set `NOTION_API_KEY` in your environment or `.env` file.
Get your token from: https://www.notion.so/my-integrations

## CLI Alternative

For Notion sync operations, you can also use the CLI directly:

```bash
# Sync events, flags, experiments, dashboards to Notion
npx tsx bin/notion-sync.ts --direction push --type events
npx tsx bin/notion-sync.ts --direction push --type flags
npx tsx bin/notion-sync.ts --direction push --type experiments
npx tsx bin/notion-sync.ts --direction push --type dashboards
```

## Constraints

- Database IDs must be configured before sync operations
- Notion API rate limits apply (3 requests/second)
- Large imports should be batched
- Property types must match database schema

## Best Practices

```markdown
## Documentation First
- Create Notion entry before PostHog resource
- Include purpose, owner, and cleanup plan
- Get stakeholder review before implementation

## Keep Current
- Update status immediately after changes
- Run weekly audits
- Archive rather than delete

## Ownership
- Every resource should have an owner
- Owners responsible for documentation accuracy
- Review ownership during team changes
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/SKILL.md` - Core PostHog guidance
- `${CLAUDE_PLUGIN_ROOT}/skills/posthog/references/notion-sync.md` - Detailed sync patterns

## Example

**User:** `/kodo ph-sync audit`

**Agent:**
I'll audit the sync status between PostHog and Notion. Let me check both systems...

**Fetching PostHog resources:**
- Events: 47 definitions
- Feature Flags: 12 flags (8 active)
- Experiments: 3 experiments
- Dashboards: 6 dashboards

**Checking Notion documentation:**
- Events: 41 documented
- Feature Flags: 10 documented
- Experiments: 3 documented
- Dashboards: 4 documented

---

## Audit Report

### Undocumented Resources

**Events (6 missing):**
- `user_api_key_created`
- `feature_export_started`
- `feature_export_completed`
- `error_api_timeout`
- `system_webhook_sent`
- `system_job_failed`

**Feature Flags (2 missing):**
- `release_new_api_v2` (active at 25%)
- `ops_maintenance_mode` (inactive)

**Dashboards (2 missing):**
- "API Performance" (ID: 123)
- "Error Tracking" (ID: 124)

### Status Mismatches

**Flags:**
- `release_checkout_v2`: Notion says "draft", PostHog is active at 100%

### Fully Synced
- Experiments: All 3 documented correctly

---

**Recommended Actions:**

1. **Quick win**: Document the 2 missing flags (both important)
2. **Update status**: Fix `release_checkout_v2` status in Notion
3. **Batch import**: Import 6 undocumented events

Should I:
1. Import all missing resources to Notion now?
2. Generate Notion entries for specific resources?
3. Fix the status mismatches?
4. Export a detailed CSV report?
