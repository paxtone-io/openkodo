# PostHog Session Recording Reference

Comprehensive guide for session recording configuration, privacy controls, and masking strategies.

## Overview

Session recordings capture user interactions to help understand behavior, debug issues, and improve UX.

### What Gets Recorded

| Element | Default | Configurable |
|---------|---------|--------------|
| Mouse movements | Captured | N/A |
| Clicks | Captured | N/A |
| Scrolling | Captured | N/A |
| Form inputs | Masked | Yes |
| Text content | Visible | Yes (maskable) |
| Console logs | Off | Yes |
| Network requests | Off | Yes |

## Configuration

### Basic Setup

```typescript
// lib/posthog.ts
import posthog from 'posthog-js';

posthog.init(POSTHOG_KEY, {
  api_host: POSTHOG_HOST,

  // Session recording configuration
  session_recording: {
    // Mask all input fields by default (recommended)
    maskAllInputs: true,

    // Additional text masking via CSS selector
    maskTextSelector: '[data-mask], .sensitive-text',

    // Block specific elements entirely (not recorded)
    blockSelector: '[data-block], .do-not-record',

    // Ignore specific input fields from masking
    maskInputOptions: {
      password: true,    // Always mask passwords
      email: false,      // Show emails (if needed for support)
      text: false,       // Show regular text inputs
      number: false,     // Show number inputs
      tel: true,         // Mask phone numbers
      date: false,       // Show dates
    },
  },
});
```

### Advanced Configuration

```typescript
posthog.init(POSTHOG_KEY, {
  session_recording: {
    // Sampling (record subset of sessions)
    sampleRate: 0.5,  // Record 50% of sessions

    // Minimum session duration to record (milliseconds)
    minimumDurationMilliseconds: 3000,  // 3 seconds

    // Console log capture
    consoleLogRecordingEnabled: true,
    consoleLevels: ['error', 'warn'],  // Only capture errors and warnings

    // Network request capture
    networkPayloadCapture: {
      requestHeaders: true,
      responseHeaders: true,
      requestBody: true,
      responseBody: true,
    },

    // Network URL filtering
    networkRequestOptions: {
      // Block sensitive endpoints from capture
      blockedURLs: [
        '/api/auth',
        '/api/payment',
        /\/api\/user\/\d+\/profile/,  // Regex pattern
      ],
    },

    // Canvas recording for diagrams/drawings
    canvas: {
      enabled: true,
      quality: 'low',  // 'low' | 'medium' | 'high'
    },
  },
});
```

## Privacy Controls

### Data Masking Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **maskAllInputs** | All form fields masked | Default, most secure |
| **maskTextSelector** | Specific text elements masked | Sensitive content areas |
| **blockSelector** | Elements not recorded at all | PII, financial data |

### HTML Data Attributes

Use data attributes for precise control:

```html
<!-- Mask text content -->
<span data-mask>John Doe</span>
<p class="sensitive-text">SSN: 123-45-6789</p>

<!-- Block entire element from recording -->
<div data-block>
  <h3>Payment Details</h3>
  <p>Card: **** **** **** 1234</p>
</div>

<!-- CSS class-based masking -->
<div class="ph-no-capture">This entire section is blocked</div>
<input class="ph-mask" type="text" placeholder="Masked input" />
```

### Built-in CSS Classes

PostHog recognizes these classes automatically:

| Class | Effect |
|-------|--------|
| `ph-no-capture` | Block element entirely |
| `ph-mask` | Mask input/text content |
| `ph-ignore-input` | Don't mask this specific input |

### Component-Level Masking

```typescript
// components/SensitiveData.tsx
interface SensitiveDataProps {
  children: React.ReactNode;
  block?: boolean;
}

export function SensitiveData({ children, block = false }: SensitiveDataProps) {
  if (block) {
    return (
      <div data-block className="ph-no-capture">
        {children}
      </div>
    );
  }

  return (
    <span data-mask className="ph-mask">
      {children}
    </span>
  );
}

// Usage
<SensitiveData>John Doe</SensitiveData>
<SensitiveData block>
  <CreditCardForm />
</SensitiveData>
```

## Consent Management

### Opt-In Recording

```typescript
// Start with recording disabled
posthog.init(POSTHOG_KEY, {
  disable_session_recording: true,
});

// Enable after user consent
function handleConsentGranted() {
  posthog.startSessionRecording();
}

// Disable if user opts out
function handleConsentRevoked() {
  posthog.stopSessionRecording();
}
```

### Consent Banner Integration

```typescript
// hooks/useRecordingConsent.ts
import { useEffect, useState } from 'react';
import posthog from 'posthog-js';

export function useRecordingConsent() {
  const [consented, setConsented] = useState<boolean | null>(null);

  useEffect(() => {
    // Check stored consent
    const storedConsent = localStorage.getItem('recording_consent');
    if (storedConsent !== null) {
      const hasConsent = storedConsent === 'true';
      setConsented(hasConsent);
      if (hasConsent) {
        posthog.startSessionRecording();
      }
    }
  }, []);

  const grantConsent = () => {
    localStorage.setItem('recording_consent', 'true');
    setConsented(true);
    posthog.startSessionRecording();
  };

  const revokeConsent = () => {
    localStorage.setItem('recording_consent', 'false');
    setConsented(false);
    posthog.stopSessionRecording();
  };

  return { consented, grantConsent, revokeConsent };
}
```

### GDPR Compliance

```typescript
// Respect Do Not Track header
posthog.init(POSTHOG_KEY, {
  respect_dnt: true,

  // Opt-out cookie name for compliance tools
  opt_out_capturing_cookie_prefix: 'ph_optout',

  // Disable persistence for strict privacy
  disable_persistence: false,  // Set true for strictest compliance
});

// Check if user has opted out
if (posthog.has_opted_out_capturing()) {
  console.log('User has opted out of tracking');
}

// Programmatic opt-out
posthog.opt_out_capturing();

// Programmatic opt-in
posthog.opt_in_capturing();
```

## Network Request Privacy

### Blocking Sensitive Endpoints

```typescript
posthog.init(POSTHOG_KEY, {
  session_recording: {
    networkPayloadCapture: {
      requestBody: true,
      responseBody: true,
    },
    networkRequestOptions: {
      // Block these URLs from network capture
      blockedURLs: [
        // Auth endpoints
        '/api/auth/login',
        '/api/auth/token',
        '/api/auth/refresh',

        // Payment endpoints
        '/api/payments',
        '/api/stripe',
        '/api/billing',

        // Sensitive data endpoints
        '/api/user/profile',
        '/api/user/settings',

        // Third-party sensitive APIs
        'https://api.stripe.com',
        'https://api.plaid.com',

        // Regex patterns
        /\/api\/users\/\d+\/documents/,
      ],
    },
  },
});
```

### Header Filtering

```typescript
posthog.init(POSTHOG_KEY, {
  session_recording: {
    networkPayloadCapture: {
      requestHeaders: (headers) => {
        // Remove sensitive headers
        const filtered = { ...headers };
        delete filtered['Authorization'];
        delete filtered['X-API-Key'];
        delete filtered['Cookie'];
        return filtered;
      },
      responseHeaders: true,
    },
  },
});
```

## Console Log Privacy

### Selective Console Capture

```typescript
posthog.init(POSTHOG_KEY, {
  session_recording: {
    consoleLogRecordingEnabled: true,
    consoleLevels: ['error', 'warn'],  // Skip info, log, debug
  },
});
```

### Log Sanitization

Before logging sensitive data, sanitize it:

```typescript
// utils/logger.ts
function sanitizeForLogging(data: Record<string, unknown>): Record<string, unknown> {
  const sensitiveKeys = ['password', 'token', 'apiKey', 'secret', 'ssn', 'creditCard'];
  const sanitized = { ...data };

  for (const key of Object.keys(sanitized)) {
    if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk))) {
      sanitized[key] = '[REDACTED]';
    }
  }

  return sanitized;
}

// Usage
console.error('Payment failed:', sanitizeForLogging(paymentData));
```

## Sampling Strategies

### Percentage-Based Sampling

```typescript
posthog.init(POSTHOG_KEY, {
  session_recording: {
    // Record 10% of all sessions
    sampleRate: 0.1,
  },
});
```

### Conditional Recording

```typescript
// Record based on user properties
posthog.init(POSTHOG_KEY, {
  disable_session_recording: true,  // Start disabled
});

// Enable for specific users
function initRecordingForUser(user: User) {
  const shouldRecord =
    user.plan === 'enterprise' ||  // Always record enterprise
    user.isInternalTester ||       // Record testers
    Math.random() < 0.1;           // 10% sample for others

  if (shouldRecord) {
    posthog.startSessionRecording();
  }
}
```

### Error-Triggered Recording

```typescript
// Record sessions where errors occur
window.addEventListener('error', (event) => {
  // Start recording on first error
  if (!posthog.sessionRecordingStarted()) {
    posthog.startSessionRecording();
  }

  // Capture the error event
  posthog.capture('error_occurred', {
    message: event.message,
    filename: event.filename,
    lineno: event.lineno,
  });
});
```

## Best Practices

### Privacy Checklist

- [ ] Enable `maskAllInputs: true` by default
- [ ] Add `data-mask` to elements containing PII
- [ ] Add `data-block` or `ph-no-capture` to financial/health data
- [ ] Block sensitive API endpoints from network capture
- [ ] Filter out Authorization headers
- [ ] Only capture console errors, not all logs
- [ ] Implement consent management for GDPR regions
- [ ] Use sampling to reduce data volume
- [ ] Review recordings periodically for unmasked PII

### What to Mask

| Data Type | Masking Level | Attribute |
|-----------|---------------|-----------|
| Passwords | Auto-masked | `type="password"` |
| Credit cards | Block | `data-block` |
| SSN/Tax IDs | Block | `data-block` |
| Phone numbers | Mask | `data-mask` |
| Email addresses | Configurable | `maskInputOptions.email` |
| Names | Mask in forms | `data-mask` |
| Addresses | Mask | `data-mask` |
| Health info | Block | `data-block`, `ph-no-capture` |
| Financial data | Block | `data-block`, `ph-no-capture` |

### What NOT to Mask

- UI navigation (buttons, links)
- Non-sensitive form labels
- Product names/descriptions
- Public content
- Error messages (sanitized)
- Feature interactions

## Troubleshooting

### Recording Not Starting

1. Check if `disable_session_recording` is set
2. Verify user hasn't opted out
3. Check consent state
4. Verify PostHog is initialized

```typescript
// Debug recording state
console.log('Recording enabled:', posthog.sessionRecordingStarted());
console.log('Opted out:', posthog.has_opted_out_capturing());
```

### Masked Content Not Hiding

1. Verify selector matches element
2. Check for CSS specificity issues
3. Ensure `data-mask` attribute is on correct element
4. Test with `ph-mask` class as fallback

### Large Recording Sizes

1. Enable sampling (`sampleRate`)
2. Set minimum duration
3. Disable canvas recording if not needed
4. Reduce network payload capture
5. Limit console log levels

### Performance Impact

1. Use `recordCrossOriginIframes: false` unless needed
2. Disable canvas recording for complex apps
3. Reduce network capture verbosity
4. Consider sampling for high-traffic apps

## MCP Integration

Session recording is automatically enabled when PostHog is configured. Use these MCP tools for recording management:

```
# View recent recordings via PostHog dashboard
# (Recordings accessed through PostHog UI, not direct MCP commands)

# Track events that trigger recording analysis
mcp__posthog__query-run with:
- query for sessions with specific events or errors
```
