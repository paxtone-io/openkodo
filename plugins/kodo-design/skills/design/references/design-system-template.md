# Design System Template

Use this template to create `./docs/rules/design-system.md` for your project.

---

# {Project Name} Design System

Last updated: {YYYY-MM-DD}

## Overview

**Aesthetic direction**: {Refined Minimal | Warm Organic | Bold Editorial | Luxury Premium | Playful Delightful | Technical Precision}

### Design Bible Philosophy

> "Reduce to the essential, then refine the essential." - Jony Ive

**Core principles**:
1. **Simplicity** - Remove until it breaks, then add back one thing
2. **Intentionality** - Every pixel has a purpose
3. **Consistency** - Same problem = same solution
4. **Hierarchy** - Guide the eye, don't compete for attention
5. **Restraint** - Elegance comes from what you leave out

### Color Distribution (80/10/10 Rule)

| Proportion | Role | Examples |
|------------|------|----------|
| **80%** | Neutrals | Backgrounds, cards, containers, body text |
| **10%** | Brand Accent | Primary buttons, links, highlights |
| **10%** | Feedback | Success, warning, error, info |

---

## Typography

### Font Stack

```css
--font-sans: 'Plus Jakarta Sans', system-ui, sans-serif;
--font-display: 'Outfit', system-ui, sans-serif;
--font-mono: 'JetBrains Mono', ui-monospace, monospace;
```

### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `text-display-2xl` | 4.5rem (72px) | 700 | 1.0 | -0.02em | Hero headlines |
| `text-display-xl` | 3.75rem (60px) | 700 | 1.1 | -0.02em | Page heroes |
| `text-display-lg` | 3rem (48px) | 600 | 1.1 | -0.01em | Section heroes |
| `text-display` | 2.25rem (36px) | 600 | 1.2 | -0.01em | Major headings |
| `text-heading-1` | 1.875rem (30px) | 600 | 1.3 | 0 | H1 |
| `text-heading-2` | 1.5rem (24px) | 600 | 1.35 | 0 | H2 |
| `text-heading-3` | 1.25rem (20px) | 600 | 1.4 | 0 | H3 |
| `text-heading-4` | 1.125rem (18px) | 600 | 1.4 | 0 | H4 |
| `text-body-lg` | 1.125rem (18px) | 400 | 1.6 | 0 | Lead paragraphs |
| `text-body` | 1rem (16px) | 400 | 1.5 | 0 | Body text |
| `text-body-sm` | 0.875rem (14px) | 400 | 1.5 | 0 | Secondary text |
| `text-caption` | 0.75rem (12px) | 500 | 1.4 | 0.01em | Labels, captions |
| `text-overline` | 0.75rem (12px) | 600 | 1.4 | 0.1em | Overlines, tags |

### Typography Rules

- **Headings**: Use display font (Outfit) for display sizes, sans font for heading-1 through heading-4
- **Body**: Always use sans font (Plus Jakarta Sans)
- **Code**: Use mono font (JetBrains Mono) for all code, data, and technical content
- **Line length**: 45-75 characters for optimal readability
- **Paragraph spacing**: 1.5x the line height between paragraphs

---

## Colors

### Color Space

All colors use **OKLCH** for perceptual uniformity:
- L: Lightness (0-100%)
- C: Chroma (0-0.4, saturation)
- H: Hue (0-360deg)

### Core Palette

#### Brand Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `--color-primary` | oklch(55% 0.20 250) | oklch(70% 0.18 250) | Primary actions, links |
| `--color-primary-hover` | oklch(48% 0.22 250) | oklch(75% 0.16 250) | Hover state |
| `--color-primary-active` | oklch(42% 0.24 250) | oklch(65% 0.20 250) | Active/pressed state |
| `--color-secondary` | oklch(50% 0.15 180) | oklch(65% 0.12 180) | Secondary actions |
| `--color-accent` | oklch(70% 0.25 45) | oklch(75% 0.22 45) | Highlights, badges |

#### Neutral Colors (Bible Standards)

**CRITICAL**: Never use pure black (`#000000`) or pure white (`#FFFFFF`). They create harsh contrast.

| Token | Light Mode | Dark Mode | Hex Fallback | Usage |
|-------|------------|-----------|--------------|-------|
| `--color-background` | oklch(97% 0.005 70) | oklch(12% 0.01 250) | `#F7F6F4` / `#1A1A1A` | Page background |
| `--color-surface` | oklch(100% 0 0) | oklch(16% 0.01 250) | `#FFFFFF` / `#242424` | Cards, panels |
| `--color-surface-elevated` | oklch(100% 0 0) | oklch(20% 0.01 250) | `#FFFFFF` / `#2E2E2E` | Modals, dropdowns |
| `--color-border` | oklch(91% 0.008 70) | oklch(25% 0.01 250) | `#E5E4E2` / `#333333` | Borders, dividers |
| `--color-border-strong` | oklch(80% 0.02 250) | oklch(40% 0.02 250) | - | Strong borders |
| `--color-text` | oklch(15% 0.02 250) | oklch(97% 0.005 70) | `#1A1A1A` / `#F7F6F4` | Primary text |
| `--color-text-secondary` | oklch(45% 0.01 250) | oklch(70% 0.01 250) | `#6B6B6B` / `#A0A0A0` | Secondary text |
| `--color-text-muted` | oklch(62% 0.01 250) | oklch(45% 0.01 250) | `#9B9B9B` / `#6B6B6B` | Muted text |

#### Semantic Colors

| Token | Color | Usage |
|-------|-------|-------|
| `--color-success` | oklch(55% 0.18 145) | Success states, confirmations |
| `--color-success-bg` | oklch(95% 0.05 145) | Success backgrounds |
| `--color-warning` | oklch(70% 0.18 70) | Warnings, caution |
| `--color-warning-bg` | oklch(95% 0.08 70) | Warning backgrounds |
| `--color-error` | oklch(55% 0.22 25) | Errors, destructive |
| `--color-error-bg` | oklch(95% 0.05 25) | Error backgrounds |
| `--color-info` | oklch(55% 0.15 250) | Information |
| `--color-info-bg` | oklch(95% 0.03 250) | Info backgrounds |

### Contrast Requirements (Bible Standard: WCAG AAA)

**Target AAA compliance, not just AA minimum.**

| Element | AA Minimum | AAA Target (Bible Standard) |
|---------|------------|------------------------------|
| Body text | 4.5:1 | **7:1** |
| Large text (18px+ or 14px bold) | 3:1 | **4.5:1** |
| UI components | 3:1 | **3:1** |
| Focus indicators | 3:1 | **3:1** |

### Saturation Rules

**Never use 100% saturation.** It looks garish and unprofessional.

| Color Type | Max Saturation | Reason |
|------------|----------------|--------|
| Primary accent | 70-85% | Visible but not harsh |
| Feedback colors | 70-80% | Clear but not alarming |
| Backgrounds | 5-15% | Subtle tinting only |

---

## Spacing

### Base Unit: 4px

| Token | Value | Usage |
|-------|-------|-------|
| `--space-0` | 0 | Reset |
| `--space-0.5` | 2px | Micro adjustments |
| `--space-1` | 4px | Tight spacing |
| `--space-1.5` | 6px | Small gaps |
| `--space-2` | 8px | Default small |
| `--space-2.5` | 10px | Between small & medium |
| `--space-3` | 12px | Medium-small |
| `--space-4` | 16px | Default medium |
| `--space-5` | 20px | Medium |
| `--space-6` | 24px | Default gap |
| `--space-8` | 32px | Large gap |
| `--space-10` | 40px | Section padding |
| `--space-12` | 48px | Large section |
| `--space-16` | 64px | Hero padding |
| `--space-20` | 80px | Page sections |
| `--space-24` | 96px | Major sections |
| `--space-32` | 128px | Full sections |

### Spacing Principles

1. **Consistent rhythm**: Use the scale, don't invent values
2. **Visual grouping**: Related items closer, unrelated farther
3. **Breathing room**: When in doubt, add more space
4. **Mobile consideration**: Reduce by ~25% on mobile

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-none` | 0 | Sharp corners |
| `--radius-sm` | 0.375rem (6px) | Subtle rounding |
| `--radius-md` | 0.5rem (8px) | Buttons, inputs |
| `--radius-lg` | 0.75rem (12px) | Cards, small panels |
| `--radius-xl` | 1rem (16px) | Large cards |
| `--radius-2xl` | 1.25rem (20px) | Modals, sheets |
| `--radius-3xl` | 1.5rem (24px) | Hero sections |
| `--radius-full` | 9999px | Pills, avatars |

---

## Shadows

### Elevation Scale

```css
/* Subtle shadow for cards */
--shadow-sm:
  0 1px 2px oklch(20% 0 0 / 0.05);

/* Default shadow */
--shadow-md:
  0 4px 6px -1px oklch(20% 0 0 / 0.07),
  0 2px 4px -2px oklch(20% 0 0 / 0.05);

/* Elevated elements */
--shadow-lg:
  0 10px 15px -3px oklch(20% 0 0 / 0.08),
  0 4px 6px -4px oklch(20% 0 0 / 0.05);

/* Modals, dropdowns */
--shadow-xl:
  0 20px 25px -5px oklch(20% 0 0 / 0.1),
  0 8px 10px -6px oklch(20% 0 0 / 0.05);

/* Floating elements */
--shadow-2xl:
  0 25px 50px -12px oklch(20% 0 0 / 0.25);

/* Focus rings */
--shadow-focus:
  0 0 0 3px oklch(55% 0.20 250 / 0.4);
```

---

## Motion

### Duration Scale (Bible Standards)

| Token | Value | Usage | Bible Category |
|-------|-------|-------|----------------|
| `--duration-instant` | 0ms | Immediate feedback | - |
| `--duration-micro` | 150ms | Hovers, toggles, focus | **Micro (150-200ms)** |
| `--duration-fast` | 200ms | Quick interactions | **Micro (150-200ms)** |
| `--duration-normal` | 250ms | State changes | **State (250-300ms)** |
| `--duration-moderate` | 300ms | Accordions, tabs | **State (250-300ms)** |
| `--duration-slow` | 400ms | Page transitions | **Page (300-400ms)** |
| `--duration-emphasis` | 500ms | Celebrations only | **Special use only** |

### Easing Functions

```css
/* Default - smooth start and end */
--ease-default: cubic-bezier(0.4, 0, 0.2, 1);

/* Enter - starts slow, ends fast */
--ease-in: cubic-bezier(0.4, 0, 1, 1);

/* Exit - starts fast, ends slow */
--ease-out: cubic-bezier(0, 0, 0.2, 1);

/* Bounce - slight overshoot */
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);

/* Spring - natural feel */
--ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);
```

### Animation Principles

1. **Purposeful**: Every animation should communicate something
2. **Quick**: Most interactions under 300ms
3. **Consistent**: Same type of animation for same type of action
4. **Respectful**: Honor `prefers-reduced-motion`

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Components (Bible Specifications)

### Buttons

| Variant | Usage | Styling |
|---------|-------|---------|
| Primary | Main CTA | Solid primary color |
| Secondary | Alternative actions | Outlined or ghost |
| Destructive | Delete, remove | Error color |
| Ghost | Tertiary actions | Transparent, text color |
| Link | Inline actions | Underline on hover |

**Bible Button Specs:**

| Property | Value | Notes |
|----------|-------|-------|
| Height (default) | 40px | Touch-friendly minimum |
| Height (large) | 48px | Primary CTAs |
| Height (small) | 32px | Inline, secondary |
| Border radius | 8px | Consistent, not pill-shaped |
| Padding X | 16-24px | Proportional to height |
| Font weight | 500-600 | Medium to semibold |
| Min width | 80px | Prevent cramped buttons |

**Required States** (all buttons):
- Default
- Hover (subtle lift or darken)
- Active/Pressed (slight inset)
- Focus (visible ring, 2px offset, 3:1 contrast)
- Disabled (50% opacity, no pointer events)
- Loading (spinner, preserve width)

### Inputs

**Bible Input Specs:**

| Property | Value | Notes |
|----------|-------|-------|
| Height | 40-48px | Match button height |
| Border radius | 8px | Match buttons |
| Border | 1px solid | `#E5E4E2` light / `#333333` dark |
| Padding X | 12-16px | Comfortable typing |
| Font size | 16px | **Prevents iOS zoom** |

**Required States**:
- Default
- Hover (border darkens)
- Focus (brand color ring, 2px)
- Error (red border + icon + message)
- Disabled (grayed background)
- Filled (subtle background change)

### Cards

| Property | Value | Notes |
|----------|-------|-------|
| Border radius | 12-16px | Larger than buttons |
| Padding | 20-24px | Generous whitespace |
| Shadow | Subtle, layered | Not harsh drop shadows |
| Border | 1px optional | Use if no shadow |
| Background | `--color-surface` | Cards, panels |

### Navigation

| Property | Value | Notes |
|----------|-------|-------|
| Height (desktop) | 64-72px | Substantial presence |
| Height (mobile) | 56-64px | Thumb-reachable |
| Item padding | 12-16px | Clickable area |
| Active indicator | 2-3px | Underline or background |

---

## Responsive Breakpoints (Extended for 4K)

| Breakpoint | Width | Target Devices |
|------------|-------|----------------|
| `sm` | 640px | Large phones |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops |
| `xl` | 1280px | Laptops |
| `2xl` | 1536px | Desktop monitors |
| `3xl` | 1920px | Full HD monitors |
| `4xl` | 2560px | QHD / 2K monitors |
| `5xl` | 3000px | 4K monitors |

### Tailwind Config

```typescript
// tailwind.config.ts
export default {
  theme: {
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
      '3xl': '1920px',
      '4xl': '2560px',
      '5xl': '3000px',
    },
  },
}
```

### Mobile-First Approach

```css
/* Base styles for mobile */
.component { ... }

/* Tablet and up */
@media (min-width: 768px) { ... }

/* Desktop and up */
@media (min-width: 1024px) { ... }

/* Large screens and up */
@media (min-width: 1920px) { ... }

/* 4K screens */
@media (min-width: 2560px) { ... }
```

### Large Screen Typography Scaling

```css
/* Base: 16px */
html { font-size: 16px; }

/* Full HD: 18px */
@media (min-width: 1920px) {
  html { font-size: 18px; }
}

/* 2K/QHD: 20px */
@media (min-width: 2560px) {
  html { font-size: 20px; }
}

/* 4K: 22px */
@media (min-width: 3000px) {
  html { font-size: 22px; }
}
```

### Large Screen Layout Patterns

```tsx
// Content container with max-width for readability
<div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 3xl:max-w-[1600px] 4xl:max-w-[1800px]">

// Responsive grid scaling to 4K
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 3xl:grid-cols-5 4xl:grid-cols-6 gap-4 lg:gap-6 3xl:gap-8">

// Responsive spacing
<section className="py-16 lg:py-24 3xl:py-32 4xl:py-40">
```

### 4K Design Considerations

1. **Content Width**: Max 1600-1800px for optimal line length
2. **Typography**: Scale base font size proportionally
3. **Spacing**: Increase margins/padding at large breakpoints
4. **Images**: Require 3x resolution for crisp display
5. **Grid Columns**: Add more columns at larger breakpoints
6. **Touch Targets**: Maintain 44px minimum even when scaled

---

## Accessibility Checklist (Bible Standard: AAA)

### Required for all components:

- [ ] Color contrast meets WCAG **AAA (7:1 text)**, not just AA minimum
- [ ] Focus states visible with 3:1 contrast minimum
- [ ] Touch targets minimum 44x44px
- [ ] Works with keyboard navigation
- [ ] Semantic HTML elements used
- [ ] ARIA labels where needed
- [ ] Respects `prefers-reduced-motion`
- [ ] Scales properly at 200% zoom
- [ ] Color independence: never rely on color alone
- [ ] No pure black (`#000000`) or pure white (`#FFFFFF`)

---

## File Organization

```
src/
  styles/
    tokens/
      colors.css
      typography.css
      spacing.css
      motion.css
    base/
      reset.css
      global.css
    index.css
  components/
    ui/           # shadcn/ui components
    [feature]/    # Feature-specific components
  lib/
    utils.ts      # cn(), etc.
```
