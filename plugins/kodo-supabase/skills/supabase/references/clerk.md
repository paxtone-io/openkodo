# Clerk Authentication Reference

## Overview

Clerk provides drop-in authentication with pre-built UI components, webhooks for database sync, and excellent DX. Use Clerk when you need polished auth UI fast, organization/team management, or are building a multi-tenant SaaS.

## When to Use Clerk vs Supabase Auth

| Factor | Use Clerk | Use Supabase Auth |
|--------|-----------|-------------------|
| **Pre-built UI** | Need polished components fast | Building custom UI anyway |
| **Organizations/Teams** | Complex multi-tenant needs | Simple user-only auth |
| **RLS Integration** | Can work, requires JWT template | Native, zero config |
| **Cost at scale** | Higher ($0.02/MAU after 10K) | Lower ($0.00325/MAU) |
| **Existing Supabase** | Adding to existing stack | Greenfield with Supabase |
| **Auth complexity** | MFA, SSO, org management | Basic auth flows |
| **Vendor lock-in** | Auth is separate service | Auth tied to database |

**Rule of thumb**: Use Clerk for complex multi-tenant SaaS with organizations. Use Supabase Auth for simpler apps or when deep RLS integration is priority.

## Installation

```bash
npm install @clerk/nextjs @clerk/themes
# or for React without Next.js
npm install @clerk/clerk-react
```

## Environment Variables

```env
# .env.local
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxx
CLERK_SECRET_KEY=sk_test_xxx
CLERK_WEBHOOK_SECRET=whsec_xxx

# Optional: Custom URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/onboarding
```

## Next.js App Router Setup

### Provider Setup

```typescript
// app/layout.tsx
import { ClerkProvider } from '@clerk/nextjs'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  )
}
```

### Middleware (Protect Routes)

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)'
])

export default clerkMiddleware((auth, req) => {
  if (!isPublicRoute(req)) {
    auth().protect()
  }
})

export const config = {
  matcher: ['/((?!.*\\..*|_next).*)', '/', '/(api|trpc)(.*)'],
}
```

### Pre-built Components

```typescript
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from '@clerk/nextjs'

export default function SignInPage() {
  return (
    <div className="flex justify-center py-24">
      <SignIn />
    </div>
  )
}

// app/sign-up/[[...sign-up]]/page.tsx
import { SignUp } from '@clerk/nextjs'

export default function SignUpPage() {
  return (
    <div className="flex justify-center py-24">
      <SignUp />
    </div>
  )
}
```

### User Button Component

```typescript
// components/header.tsx
import { UserButton, SignedIn, SignedOut, SignInButton } from '@clerk/nextjs'

export function Header() {
  return (
    <header className="flex justify-between p-4">
      <Logo />
      <SignedIn>
        <UserButton afterSignOutUrl="/" />
      </SignedIn>
      <SignedOut>
        <SignInButton mode="modal" />
      </SignedOut>
    </header>
  )
}
```

## Accessing User Data

### Client Components

```typescript
'use client'
import { useUser, useAuth } from '@clerk/nextjs'

export function Profile() {
  const { user, isLoaded, isSignedIn } = useUser()
  const { userId, sessionId, getToken } = useAuth()

  if (!isLoaded) return <div>Loading...</div>
  if (!isSignedIn) return <div>Not signed in</div>

  return (
    <div>
      <p>Hello, {user.firstName}</p>
      <p>Email: {user.primaryEmailAddress?.emailAddress}</p>
      <img src={user.imageUrl} alt="Profile" />
    </div>
  )
}
```

### Server Components (Next.js)

```typescript
// app/dashboard/page.tsx
import { currentUser, auth } from '@clerk/nextjs/server'

export default async function Dashboard() {
  const user = await currentUser()
  const { userId } = auth()

  if (!user) return <div>Not authenticated</div>

  return (
    <div>
      <h1>Welcome, {user.firstName}</h1>
      <p>User ID: {userId}</p>
    </div>
  )
}
```

### API Routes

```typescript
// app/api/user/route.ts
import { auth, currentUser } from '@clerk/nextjs/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const { userId } = auth()

  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const user = await currentUser()

  return NextResponse.json({
    id: userId,
    email: user?.primaryEmailAddress?.emailAddress
  })
}
```

## Webhook Integration (Database Sync)

### Webhook Endpoint

```typescript
// app/api/webhooks/clerk/route.ts
import { Webhook } from 'svix'
import { headers } from 'next/headers'
import { WebhookEvent } from '@clerk/nextjs/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function POST(req: Request) {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET!

  // Get headers
  const headerPayload = headers()
  const svix_id = headerPayload.get('svix-id')
  const svix_timestamp = headerPayload.get('svix-timestamp')
  const svix_signature = headerPayload.get('svix-signature')

  if (!svix_id || !svix_timestamp || !svix_signature) {
    return new Response('Missing svix headers', { status: 400 })
  }

  // Get body
  const payload = await req.json()
  const body = JSON.stringify(payload)

  // Verify webhook
  const wh = new Webhook(WEBHOOK_SECRET)
  let evt: WebhookEvent

  try {
    evt = wh.verify(body, {
      'svix-id': svix_id,
      'svix-timestamp': svix_timestamp,
      'svix-signature': svix_signature,
    }) as WebhookEvent
  } catch (err) {
    console.error('Webhook verification failed:', err)
    return new Response('Invalid signature', { status: 400 })
  }

  // Handle events
  const eventType = evt.type

  if (eventType === 'user.created') {
    const { id, email_addresses, first_name, last_name, image_url } = evt.data

    await supabase.from('users').insert({
      clerk_id: id,
      email: email_addresses[0]?.email_address,
      first_name,
      last_name,
      avatar_url: image_url,
      created_at: new Date().toISOString()
    })
  }

  if (eventType === 'user.updated') {
    const { id, email_addresses, first_name, last_name, image_url } = evt.data

    await supabase.from('users')
      .update({
        email: email_addresses[0]?.email_address,
        first_name,
        last_name,
        avatar_url: image_url,
        updated_at: new Date().toISOString()
      })
      .eq('clerk_id', id)
  }

  if (eventType === 'user.deleted') {
    const { id } = evt.data

    // Soft delete or hard delete based on your needs
    await supabase.from('users')
      .update({ deleted_at: new Date().toISOString() })
      .eq('clerk_id', id)
  }

  if (eventType === 'organization.created') {
    const { id, name, slug, created_by } = evt.data

    await supabase.from('organizations').insert({
      clerk_org_id: id,
      name,
      slug,
      created_by_clerk_id: created_by,
      created_at: new Date().toISOString()
    })
  }

  if (eventType === 'organizationMembership.created') {
    const { organization, public_user_data, role } = evt.data

    await supabase.from('organization_members').insert({
      clerk_org_id: organization.id,
      clerk_user_id: public_user_data.user_id,
      role,
      created_at: new Date().toISOString()
    })
  }

  return new Response('OK', { status: 200 })
}
```

### Enable Webhooks in Clerk Dashboard

1. Go to **Clerk Dashboard > Webhooks**
2. Add endpoint: `https://your-domain.com/api/webhooks/clerk`
3. Select events:
   - `user.created`
   - `user.updated`
   - `user.deleted`
   - `organization.created`
   - `organization.updated`
   - `organizationMembership.created`
   - `organizationMembership.updated`
   - `organizationMembership.deleted`
4. Copy webhook secret to `CLERK_WEBHOOK_SECRET`

### Database Schema for Clerk Sync

```sql
-- Users synced from Clerk
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_id text UNIQUE NOT NULL,
  email text,
  first_name text,
  last_name text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz,
  deleted_at timestamptz
);

CREATE INDEX idx_users_clerk_id ON users(clerk_id);

-- Organizations
CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_org_id text UNIQUE NOT NULL,
  name text NOT NULL,
  slug text,
  created_by_clerk_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz
);

-- Organization members
CREATE TABLE organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_org_id text NOT NULL,
  clerk_user_id text NOT NULL,
  role text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(clerk_org_id, clerk_user_id)
);
```

## Clerk + Supabase RLS Integration

### JWT Template in Clerk

1. Go to **Clerk Dashboard > JWT Templates**
2. Create new template named `supabase`
3. Add claims:

```json
{
  "sub": "{{user.id}}",
  "email": "{{user.primary_email_address}}",
  "user_metadata": {
    "clerk_id": "{{user.id}}"
  }
}
```

### Get Supabase Token from Clerk

```typescript
'use client'
import { useAuth } from '@clerk/nextjs'
import { createClient } from '@supabase/supabase-js'

export function useSupabaseClient() {
  const { getToken } = useAuth()

  const getSupabaseClient = async () => {
    const token = await getToken({ template: 'supabase' })

    return createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        global: {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      }
    )
  }

  return { getSupabaseClient }
}
```

### RLS Policies with Clerk ID

```sql
-- Get clerk_id from JWT
CREATE OR REPLACE FUNCTION auth.clerk_id()
RETURNS text
LANGUAGE sql STABLE
AS $$
  SELECT nullif(
    current_setting('request.jwt.claims', true)::json->>'sub',
    ''
  )::text
$$;

-- RLS policy using clerk_id
CREATE POLICY "Users can view own data"
ON user_data FOR SELECT
USING (clerk_user_id = auth.clerk_id());

CREATE POLICY "Users can insert own data"
ON user_data FOR INSERT
WITH CHECK (clerk_user_id = auth.clerk_id());
```

## Organizations (Multi-tenant)

### Organization Switcher

```typescript
import { OrganizationSwitcher } from '@clerk/nextjs'

export function OrgSwitcher() {
  return (
    <OrganizationSwitcher
      afterCreateOrganizationUrl="/dashboard"
      afterSelectOrganizationUrl="/dashboard"
      afterLeaveOrganizationUrl="/dashboard"
    />
  )
}
```

### Access Organization Data

```typescript
'use client'
import { useOrganization, useOrganizationList } from '@clerk/nextjs'

export function OrgInfo() {
  const { organization, membership } = useOrganization()
  const { userMemberships } = useOrganizationList({
    userMemberships: { infinite: true }
  })

  if (!organization) return <div>No organization selected</div>

  return (
    <div>
      <h2>{organization.name}</h2>
      <p>Your role: {membership?.role}</p>
      <p>Members: {organization.membersCount}</p>
    </div>
  )
}
```

### Server-side Organization Check

```typescript
import { auth } from '@clerk/nextjs/server'

export async function getOrgData() {
  const { orgId, orgRole, orgSlug } = auth()

  if (!orgId) {
    throw new Error('No organization selected')
  }

  // Check role
  if (orgRole !== 'org:admin') {
    throw new Error('Admin access required')
  }

  return { orgId, orgRole, orgSlug }
}
```

## Custom Session Claims

### Set Custom Claims (Clerk Dashboard)

Go to **Sessions > Customize session token** and add:

```json
{
  "metadata": "{{user.public_metadata}}",
  "org_id": "{{org.id}}",
  "org_role": "{{org_membership.role}}"
}
```

### Access Custom Claims

```typescript
import { auth } from '@clerk/nextjs/server'

export async function checkAccess() {
  const { sessionClaims } = auth()

  const role = sessionClaims?.org_role as string
  const metadata = sessionClaims?.metadata as Record<string, any>

  return { role, metadata }
}
```

## Fly.io Backend with Clerk

### Verify Clerk JWT

```typescript
// src/lib/clerk.ts
import { createClerkClient } from '@clerk/backend'

const clerk = createClerkClient({
  secretKey: process.env.CLERK_SECRET_KEY!
})

export async function verifyClerkToken(token: string) {
  try {
    const { sub, sid, org_id, org_role } = await clerk.verifyToken(token)
    return { userId: sub, sessionId: sid, orgId: org_id, orgRole: org_role }
  } catch (error) {
    throw new Error('Invalid token')
  }
}
```

### Express Middleware

```typescript
// src/middleware/clerk-auth.ts
import { Request, Response, NextFunction } from 'express'
import { verifyClerkToken } from '../lib/clerk'

export async function requireClerkAuth(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'No token provided' })
  }

  try {
    req.auth = await verifyClerkToken(token)
    next()
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' })
  }
}

// Usage
app.get('/api/protected', requireClerkAuth, (req, res) => {
  res.json({ userId: req.auth.userId })
})
```

## Theming

```typescript
import { ClerkProvider } from '@clerk/nextjs'
import { dark } from '@clerk/themes'

export default function RootLayout({ children }) {
  return (
    <ClerkProvider
      appearance={{
        baseTheme: dark,
        variables: {
          colorPrimary: '#6366f1',
          colorBackground: '#1f2937',
          colorInputBackground: '#374151',
          colorInputText: '#f9fafb'
        },
        elements: {
          formButtonPrimary: 'bg-indigo-600 hover:bg-indigo-700',
          card: 'bg-gray-800 shadow-xl'
        }
      }}
    >
      {children}
    </ClerkProvider>
  )
}
```

## Pricing Comparison

| Tier | Clerk | Supabase Auth |
|------|-------|---------------|
| Free | 10,000 MAU | 50,000 MAU |
| Cost/MAU | $0.02 | $0.00325 |
| 100K MAU | ~$1,800/mo | ~$163/mo |
| 500K MAU | ~$9,800/mo | ~$1,300/mo |

**Clerk advantages worth the premium:**
- Pre-built UI components
- Organization management
- Better DX for complex auth flows
- Dedicated auth infrastructure
