# Auth Reference

## Overview

Supabase Auth provides user authentication with deep RLS integration. 50K MAU free, then $0.00325/MAU.

**Alternative**: If you need pre-built UI components, organization/team management, or are already using Clerk in existing projects, see [clerk.md](clerk.md) for Clerk integration patterns including webhook-based DB sync and Supabase RLS integration.

## Supported Providers

### Email/Password

```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword',
  options: {
    data: {
      first_name: 'John',
      last_name: 'Doe'
    }
  }
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securepassword'
})
```

### Magic Link

```typescript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://app.example.com/auth/callback'
  }
})
```

### Phone OTP

```typescript
// Send OTP
const { data, error } = await supabase.auth.signInWithOtp({
  phone: '+1234567890'
})

// Verify OTP
const { data, error } = await supabase.auth.verifyOtp({
  phone: '+1234567890',
  token: '123456',
  type: 'sms'
})
```

### Social OAuth

```typescript
// Google
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://app.example.com/auth/callback',
    scopes: 'email profile'
  }
})

// GitHub
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'github'
})

// Available providers:
// google, github, gitlab, bitbucket, azure, discord, facebook,
// figma, kakao, keycloak, linkedin, notion, slack, spotify,
// twitch, twitter, workos, zoom
```

### SAML SSO (Pro+)

Configure in Dashboard: Authentication > Providers > SAML 2.0

```typescript
const { data, error } = await supabase.auth.signInWithSSO({
  domain: 'company.com'
})
```

## Session Management

### Get Current Session

```typescript
const { data: { session }, error } = await supabase.auth.getSession()

// Get user
const { data: { user }, error } = await supabase.auth.getUser()
```

### Session Listener

```typescript
supabase.auth.onAuthStateChange((event, session) => {
  console.log('Auth event:', event)
  // INITIAL_SESSION, SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED,
  // USER_UPDATED, PASSWORD_RECOVERY, MFA_CHALLENGE_VERIFIED

  if (event === 'SIGNED_IN') {
    // User signed in
  }
  if (event === 'SIGNED_OUT') {
    // User signed out
  }
})
```

### Sign Out

```typescript
// Current session
await supabase.auth.signOut()

// All sessions (global sign out)
await supabase.auth.signOut({ scope: 'global' })
```

## Custom Claims via Hooks

Add custom data to JWT without database queries. Configure in Dashboard: Authentication > Hooks.

### Custom Access Token Hook (Edge Function)

```typescript
// supabase/functions/custom-claims/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const payload = await req.json()
  const { user_id } = payload

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Fetch user's role from database
  const { data: profile } = await supabase
    .from('profiles')
    .select('role, org_id')
    .eq('id', user_id)
    .single()

  return new Response(JSON.stringify({
    claims: {
      role: profile?.role || 'user',
      org_id: profile?.org_id
    }
  }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Access Claims in RLS

```sql
-- Efficient: uses JWT claim (no DB lookup)
CREATE POLICY "Users can view own org data"
ON documents FOR SELECT
USING (
  org_id = (auth.jwt() ->> 'org_id')::uuid
);

-- Role-based access
CREATE POLICY "Admins can delete"
ON documents FOR DELETE
USING (
  (auth.jwt() ->> 'role') = 'admin'
);
```

**Important**: Claims don't auto-update. Users must re-login after role changes.

## RLS Helper Functions

```sql
-- Get current user ID
auth.uid() -- Returns uuid

-- Get JWT payload
auth.jwt() -- Returns jsonb

-- Get specific claim
auth.jwt() ->> 'role' -- Returns text

-- Get email from JWT
auth.jwt() ->> 'email' -- Returns text
```

## Password Management

### Reset Password

```typescript
// Request reset email
const { data, error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  { redirectTo: 'https://app.example.com/reset-password' }
)

// Update password (after clicking email link)
const { data, error } = await supabase.auth.updateUser({
  password: 'newpassword'
})
```

### Update User

```typescript
const { data, error } = await supabase.auth.updateUser({
  email: 'newemail@example.com',
  password: 'newpassword',
  data: { display_name: 'New Name' }
})
```

## Multi-Factor Authentication

### Enroll TOTP

```typescript
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: 'totp',
  friendlyName: 'Authenticator App'
})

// data.totp contains:
// - qr_code: base64 QR code image
// - secret: manual entry secret
// - uri: otpauth:// URI
```

### Verify MFA

```typescript
const { data, error } = await supabase.auth.mfa.challenge({
  factorId: 'factor-uuid'
})

const { data: verifyData, error: verifyError } = await supabase.auth.mfa.verify({
  factorId: 'factor-uuid',
  challengeId: data.id,
  code: '123456'
})
```

### Check MFA Status in RLS

```sql
CREATE POLICY "Require MFA for sensitive operations"
ON sensitive_data FOR ALL
USING (
  (auth.jwt() -> 'amr') ? 'totp'
);
```

## Auth Callback Handling (Next.js/React)

### Server-Side (Next.js App Router)

```typescript
// app/auth/callback/route.ts
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = createRouteHandlerClient({ cookies })
    await supabase.auth.exchangeCodeForSession(code)
  }

  return NextResponse.redirect(requestUrl.origin)
}
```

### Client-Side Listener (React)

```typescript
useEffect(() => {
  const { data: { subscription } } = supabase.auth.onAuthStateChange(
    async (event, session) => {
      if (event === 'SIGNED_IN') {
        router.push('/dashboard')
      }
      if (event === 'SIGNED_OUT') {
        router.push('/login')
      }
    }
  )

  return () => subscription.unsubscribe()
}, [])
```

## Email Templates

Customize in Dashboard: Authentication > Email Templates

Available templates:
- Confirm signup
- Magic Link
- Change Email Address
- Reset Password
- Invite user

Variables available: `{{ .SiteURL }}`, `{{ .Token }}`, `{{ .TokenHash }}`, `{{ .Email }}`

## Server-Side Auth (Fly.io)

Verify Supabase JWT on your backend:

```typescript
import jwt from 'jsonwebtoken'
import jwksClient from 'jwks-rsa'

const client = jwksClient({
  jwksUri: `https://${PROJECT_REF}.supabase.co/auth/v1/.well-known/jwks.json`,
  cache: true,
  cacheMaxAge: 600000
})

export async function verifyToken(token: string) {
  const decoded = jwt.decode(token, { complete: true })
  if (!decoded || !decoded.header.kid) {
    throw new Error('Invalid token')
  }

  const key = await client.getSigningKey(decoded.header.kid)

  return jwt.verify(token, key.getPublicKey(), {
    audience: 'authenticated',
    issuer: `https://${PROJECT_REF}.supabase.co/auth/v1`
  })
}

// Express middleware
export async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'No token provided' })
  }

  try {
    req.user = await verifyToken(token)
    next()
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' })
  }
}
```

## When to Use Clerk Instead

Consider Clerk (see [clerk.md](clerk.md)) when:

- **Pre-built UI**: Need polished sign-in/sign-up components fast
- **Organizations**: Complex multi-tenant with teams, roles, invitations
- **Faster setup**: Want auth working in minutes with good DX
- **Existing usage**: Already using Clerk in other projects

Clerk can integrate with Supabase via webhooks for DB sync and JWT templates for RLS.

## When to Use Custom Auth

Consider custom auth when:

- **Acting as OIDC Provider**: Need to issue tokens for third-party apps
- **M2M Authentication**: API key-based access without user context
- **Advanced Threat Detection**: Login anomaly detection, device fingerprinting
- **Complex Organization Management**: Beyond Supabase team features
- **Existing Auth Integration**: Must integrate with enterprise identity provider not supported

For these cases, consider Auth0, Clerk, or custom implementation with Passport.js.
