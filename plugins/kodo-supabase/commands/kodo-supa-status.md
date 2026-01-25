---
name: kodo-supa-status
description: Check Supabase project status and health
---

# /kodo supa-status - Project Status

Check Supabase project status and health.

## What You Do

When the user runs `/kodo supa-status [service]`:

**Services:**
- (none) - Full status
- `db` - Database status
- `functions` - Edge Functions
- `local` - Local dev environment

## Commands to Execute

### Full local status
```bash
supabase status
```

Shows:
- API URL
- GraphQL URL
- Database URL
- Studio URL
- Inbucket URL (email testing)
- JWT secret
- anon key
- service_role key

### Migration status
```bash
supabase migration list
supabase migration status
```

### Functions status
```bash
supabase functions list
```

### Linked projects
```bash
supabase projects list
```

### Service logs
```bash
# All services
supabase logs

# Specific service
supabase logs --service postgres
supabase logs --service edge-runtime
supabase logs --service auth
supabase logs --service storage
supabase logs --service realtime
```

## Local Development Commands

### Start Supabase
```bash
supabase start
```

### Stop Supabase
```bash
supabase stop
```

### Restart
```bash
supabase stop
supabase start
```

## Status Report Format

When running `/kodo supa-status`, provide this report:

```markdown
## Supabase Project Status

### Local Development
- Status: Running / Stopped
- API: http://localhost:54321
- Studio: http://localhost:54323
- Database: postgresql://postgres:postgres@localhost:54322/postgres

### Migrations
- Local: X migrations
- Remote: X migrations
- Status: In sync / Out of sync

### Edge Functions
| Function | Status | Deployed |
|----------|--------|----------|
| stripe-webhook | OK | 2024-01-15 |
| send-email | OK | 2024-01-14 |

### Secrets
Run `supabase secrets list` to check configured secrets.

### Quick Commands
- Start local: `supabase start`
- View Studio: http://localhost:54323
- Generate types: `supabase gen types typescript --local`
```

## Troubleshooting

### Local not starting
```bash
# Check Docker
docker ps

# Reset and restart
supabase stop
supabase start
```

### Migration mismatch
```bash
# Check status
supabase migration status

# Repair if needed
supabase migration repair --status applied <version>
```

### Function errors
```bash
# Check logs
supabase functions logs <function-name>

# Test locally
supabase functions serve <function-name> --debug
```

## Skills to Read

- `${CLAUDE_PLUGIN_ROOT}/skills/supabase/SKILL.md`

## Example

```
User: /kodo supa-status

Claude: Checking Supabase status...

```bash
supabase status
```

**Local Development:** Running
- API: http://localhost:54321
- Studio: http://localhost:54323

**Migrations:**
```bash
supabase migration status
```
- 15 local / 15 remote - In sync

**Edge Functions:**
```bash
supabase functions list
```
- stripe-webhook OK
- send-email OK
- process-image OK

Everything looks good! Open Studio: http://localhost:54323

---

User: /kodo supa-status functions

Claude: Checking Edge Functions status...

```bash
supabase functions list
```

| Function | Status |
|----------|--------|
| stripe-webhook | Deployed |
| send-email | Deployed |

To view logs:
```bash
supabase functions logs stripe-webhook
```
```
