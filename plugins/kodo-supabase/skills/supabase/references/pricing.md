# Pricing Reference

## Plan Comparison

| Feature | Free | Pro ($25/mo) | Team ($599/mo) |
|---------|------|--------------|----------------|
| Projects | 2 | Unlimited | Unlimited |
| Database | 500 MB | 8 GB | 8 GB |
| Storage | 1 GB | 100 GB | 100 GB |
| Bandwidth | 5 GB | 250 GB | 250 GB |
| MAU | 50,000 | 100,000 | 100,000 |
| Edge Invocations | 500K | 2M | 2M |
| Realtime Connections | 200 | 500 | 500 |
| Daily Backups | No | 7 days | 14 days |
| Support | Community | Email | Priority |
| SOC 2 | No | No | Yes |
| SSO/SAML | No | Yes | Yes |

**Pro includes $10/month compute credit** covering one Micro instance.

## Compute Pricing

| Size | CPU | RAM | Monthly | Connections |
|------|-----|-----|---------|-------------|
| Micro | 2-core shared | 1 GB | ~$10 | 60 direct / 200 pooler |
| Small | 2-core shared | 2 GB | ~$15 | 90 direct / 400 pooler |
| Medium | 2-core shared | 4 GB | ~$30 | 120 direct / 600 pooler |
| Large | 2-core dedicated | 8 GB | ~$110 | 160 direct / 800 pooler |
| XL | 4-core dedicated | 16 GB | ~$210 | 240 direct / 1,000 pooler |
| 2XL | 8-core dedicated | 32 GB | ~$450 | 380 direct / 1,500 pooler |
| 4XL | 16-core dedicated | 64 GB | ~$960 | 480 direct / 3,000 pooler |

**Note**: Shared CPU instances may throttle under sustained load. Use Large+ for production.

## Usage-Based Pricing (Pro+)

| Resource | Included | Overage |
|----------|----------|---------|
| Database | 8 GB | $0.125/GB |
| Storage | 100 GB | $0.021/GB |
| Bandwidth | 250 GB | $0.09/GB |
| MAU | 100K | $0.00325/user |
| Edge Invocations | 2M | $2/million |
| Realtime Messages | 5M | $2.50/million |
| Realtime Connections | 500 | $10/1,000 |
| Image Transforms | 100 origins | $5/1,000 origins |

## Cost Scenarios

### MVP/Startup (Free Tier)

```
Monthly cost: $0
- 500 MB database
- 50K users
- 500K Edge Function calls
- 200 concurrent Realtime connections
```

### Growing SaaS (Pro)

```
Monthly cost: ~$50-100
- Pro plan: $25
- Small compute: $15
- Additional storage 50GB: $1.05
- 150K MAU overage: $163
- Total: ~$204
```

### Production App (Pro + Dedicated)

```
Monthly cost: ~$250-500
- Pro plan: $25
- Large compute: $110
- 500GB storage: $8.40
- 500GB bandwidth: $22.50
- 500K MAU: $1,300
- Total: ~$1,466
```

### Enterprise (Team)

```
Monthly cost: $599+
- Team plan: $599
- XL compute: $210
- SOC 2 compliance included
- Priority support
- SSO/SAML included
```

## Feature-Specific Costs

### Auth

- **Free**: 50K MAU
- **Pro**: 100K MAU included
- **Overage**: $0.00325/MAU (~$3.25 per 1,000 users)

**Comparison**: Auth0 ~$0.07/MAU, Firebase ~$0.06/MAU

### Edge Functions

- **Free**: 500K invocations
- **Pro**: 2M invocations
- **Overage**: $2/million

**CPU time limit**: 2 seconds (no additional charge, just hard limit)

### Realtime

- **Concurrent connections**: 200 (Free) / 500 (Pro)
- **Overage**: $10 per 1,000 additional connections
- **Messages**: 2M (Free) / 5M (Pro)
- **Overage**: $2.50/million messages

### Storage

- **Space**: $0.021/GB beyond included
- **Bandwidth**: $0.09/GB beyond included
- **Image transforms**: $5/1,000 origin images

## Cost Optimization Strategies

### Database
- Monitor with pg_stat_statements
- Add indexes for RLS policy columns
- Use read replicas for analytics (Team+)
- Archive old data to cold storage

### Edge Functions
- Batch operations to reduce invocations
- Cache with Upstash Redis
- Use Database Functions for data-only operations
- Move heavy AI to Fly.io

### Realtime
- Use Broadcast for ephemeral messages (no DB persistence)
- Disconnect idle clients
- Monitor peak connections

### Storage
- Compress before upload
- Cache transformed images externally
- Implement lifecycle policies
- Use R2 for high-egress scenarios

### Auth
- Consolidate test users
- Implement proper user cleanup
- Use anonymous auth sparingly

## When to Consider Alternatives

### High Auth Volume (>1M MAU)
At $0.00325/user, 1M MAU = $3,250/month just for auth.
Consider: Self-hosted Keycloak, custom auth

### High Storage/Egress
50GB storage + 500GB egress = ~$47.50/month
Cloudflare R2: ~$0.75/month (zero egress)

### High Compute Needs
4XL ($960) may not be enough for:
- Heavy analytical queries
- Large vector operations
- High concurrency

Consider: Dedicated PostgreSQL on Fly.io, RDS

### Multi-Region Requirements
Supabase is single-region per project.
For global distribution: Consider CockroachDB, PlanetScale

## Spend Cap (Important!)

**Enabled by default on Pro**. Prevents unexpected charges by pausing project when limits exceeded.

```
Dashboard > Project Settings > Billing > Spend Cap
```

**Warning**: Disabling spend cap means unlimited charges based on usage.

## Break-Even Analysis: Self-Hosting

Include total cost of ownership:
- DevOps engineer: $120-240K/year
- Infrastructure: Variable
- Maintenance time: 20-40 hours/month
- On-call rotation

**Rule of thumb**: Self-hosting rarely saves money for teams <10 engineers without existing DevOps expertise.

Supabase cost at scale:
- $25 base + $960 (4XL) + $500 usage = ~$1,500/month
- vs. $15-20K/month DevOps salary allocation

Only consider self-hosting when:
- Have dedicated infrastructure team
- Regulatory requirements mandate it
- Scale exceeds Supabase Enterprise offerings
- Specific customization requirements
