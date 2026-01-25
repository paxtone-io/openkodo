# Design Bible Principles

Core design principles for the kodo-design plugin. This document serves as the **challenger reference** - the plugin uses these principles to question and validate design choices.

---

## Philosophy

### The Jony Ive Approach

> "Reduce to the essential, then refine the essential."

Every design decision should pass through this filter:
1. **Is this element essential?** If not, remove it.
2. **Is this the simplest form?** If not, simplify it.
3. **Does this serve the user?** If not, reconsider it.

### Core Tenets

| Principle | Description |
|-----------|-------------|
| **Simplicity** | Remove until it breaks, then add back one thing |
| **Intentionality** | Every pixel has a purpose |
| **Consistency** | Same problem = same solution |
| **Hierarchy** | Guide the eye, don't compete for attention |
| **Restraint** | Elegance comes from what you leave out |

---

## Color System

### The 80/10/10 Rule

This is **non-negotiable** for professional design:

| Proportion | Role | Examples |
|------------|------|----------|
| **80%** | Neutrals | Backgrounds, cards, containers, body text |
| **10%** | Brand Accent | Primary buttons, links, highlights, icons |
| **10%** | Feedback | Success, warning, error, info states |

### Base Neutrals (CRITICAL)

**Never use pure black or pure white.** They create harsh contrast and feel clinical.

| Role | Light Mode | Dark Mode | Notes |
|------|------------|-----------|-------|
| **Background** | `#F7F6F4` | `#1A1A1A` | Warm cream / soft dark |
| **Surface** | `#FFFFFF` | `#242424` | Cards, modals |
| **Border** | `#E5E4E2` | `#333333` | Subtle separation |
| **Text Primary** | `#1A1A1A` | `#F7F6F4` | Main content |
| **Text Secondary** | `#6B6B6B` | `#A0A0A0` | Supporting content |
| **Text Muted** | `#9B9B9B` | `#6B6B6B` | Captions, hints |

### Brand Color Saturation

**Never use 100% saturation.** It looks garish and unprofessional.

| Color Type | Saturation Range | Reason |
|------------|------------------|--------|
| Primary accent | 70-85% | Visible but not harsh |
| Feedback colors | 70-80% | Clear but not alarming |
| Backgrounds | 5-15% | Subtle tinting |

### Feedback Colors

Must maintain **WCAG AAA (7:1)** contrast with their backgrounds:

| State | Light Mode | Dark Mode | Use |
|-------|------------|-----------|-----|
| Success | `#2E7D32` | `#66BB6A` | Confirmations, completed |
| Warning | `#ED6C02` | `#FFA726` | Caution, attention needed |
| Error | `#D32F2F` | `#EF5350` | Problems, validation |
| Info | `#0288D1` | `#4FC3F7` | Tips, guidance |

---

## Typography

### Hierarchy Scale

Consistent sizing creates visual order:

| Level | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| **H1** | 44-56px | 600-700 | 1.1-1.2 | Page titles, hero |
| **H2** | 28-32px | 600 | 1.2-1.3 | Section headers |
| **H3** | 20-24px | 600 | 1.3 | Subsections |
| **H4** | 18px | 600 | 1.4 | Card titles |
| **Body** | 16px | 400 | 1.5-1.6 | Main content |
| **Small** | 14px | 400 | 1.5 | Secondary info |
| **Tiny** | 12px | 500 | 1.4 | Labels, captions |

### Font Pairing Strategies

These are **learning guides**, not requirements. Understand the principle, then choose fonts that fit your project:

| Style | Display Font | Body Font | Character |
|-------|--------------|-----------|-----------|
| **Modern Pro** | Inter | Inter | Clean, neutral, universal |
| **Luxury** | Playfair Display | DM Sans | Elegant, refined, premium |
| **Tech Forward** | Geist | Geist | Developer-focused, precise |
| **Editorial** | Crimson Text | Space Grotesk | Content-focused, readable |
| **Friendly** | Outfit | Plus Jakarta Sans | Approachable, warm |

### Typography Rules

- **Line length**: 45-75 characters (ideal: 65)
- **Paragraph spacing**: 1.5x the line height
- **No orphans**: Avoid single words on last line
- **Alignment**: Left-align body text (never justify on web)

---

## Component Specifications

### Buttons

| Property | Value | Notes |
|----------|-------|-------|
| Height (default) | 40px | Touch-friendly |
| Height (large) | 48px | Primary CTAs |
| Height (small) | 32px | Inline, secondary |
| Border radius | 8px | Consistent, not pill-shaped |
| Padding X | 16px-24px | Proportional to height |
| Font weight | 500-600 | Medium to semibold |
| Min width | 80px | Prevent cramped buttons |

**States** (all buttons must have):
- Default
- Hover (subtle lift or darken)
- Active/Pressed (slight inset)
- Focus (visible ring, 2px offset)
- Disabled (50% opacity, no pointer)
- Loading (spinner, preserve width)

### Inputs

| Property | Value | Notes |
|----------|-------|-------|
| Height | 40-48px | Match button height |
| Border radius | 8px | Consistent with buttons |
| Border | 1px solid | `#E5E4E2` light / `#333333` dark |
| Padding X | 12-16px | Comfortable typing |
| Font size | 16px | Prevents iOS zoom |

**States**:
- Default
- Hover (border darkens)
- Focus (brand color ring)
- Error (red border + icon)
- Disabled (grayed background)
- Filled (subtle background change)

### Cards

| Property | Value | Notes |
|----------|-------|-------|
| Border radius | 12-16px | Larger than buttons |
| Padding | 20-24px | Generous whitespace |
| Shadow | Subtle, layered | Not harsh drop shadows |
| Border | Optional | 1px if no shadow |

### Navigation

| Property | Value | Notes |
|----------|-------|-------|
| Height (desktop) | 64-72px | Substantial presence |
| Height (mobile) | 56-64px | Thumb-reachable |
| Item padding | 12-16px | Clickable area |
| Active indicator | 2-3px | Underline or background |

---

## Glassmorphism Guidelines

### When to Use

- Floating action buttons (FABs)
- Modal overlays
- Navigation bars
- Tooltips and popovers
- Feature highlights

### When NOT to Use

- Body text containers (readability suffers)
- Form inputs (users need clarity)
- Data tables (precision required)
- Long-form content
- Mobile primary UI

### Implementation

```css
/* Proper glassmorphism */
.glass {
  background: oklch(100% 0 0 / 0.7);  /* 70% opacity */
  backdrop-filter: blur(12px);
  border: 1px solid oklch(100% 0 0 / 0.2);
}

/* Dark mode */
.glass-dark {
  background: oklch(20% 0 0 / 0.7);
  backdrop-filter: blur(12px);
  border: 1px solid oklch(100% 0 0 / 0.1);
}
```

---

## Animation & Motion

### Timing Standards

| Type | Duration | Easing | Use |
|------|----------|--------|-----|
| **Micro** | 150-200ms | ease-out | Hovers, toggles, focus |
| **State** | 250-300ms | ease-in-out | Accordions, tabs, modals |
| **Page** | 300-400ms | ease-out | Route transitions |
| **Emphasis** | 400-600ms | spring | Celebrations, attention |

### Animation Principles

1. **Purpose**: Every animation must serve UX, not decoration
2. **Performance**: Use `transform` and `opacity` only (GPU-accelerated)
3. **Respect Motion**: Always honor `prefers-reduced-motion`
4. **Direction**: Follow natural reading flow (LTR: left-to-right)
5. **Consistency**: Same action = same animation

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Dark Mode Strategy

### Philosophy

Dark mode is **parallel design**, not color inversion.

### Conversion Rules

| Light Mode | Dark Mode | Rule |
|------------|-----------|------|
| White background | Near-black (`#1A1A1A`) | Never pure black |
| Light gray surface | Dark gray (`#242424`) | Elevation via lightness |
| Dark text | Light text | Maintain contrast ratio |
| Shadows | Reduce/remove | Shadows don't work on dark |
| Vibrant colors | Desaturate 10-20% | Reduce eye strain |

### Luminosity Respect

Maintain the same luminosity hierarchy:
- Background is darkest
- Cards/surfaces slightly lighter
- Interactive elements pop appropriately
- Text has maximum readability

---

## Accessibility Standards

### Target: WCAG AAA

While AA (4.5:1) is the legal minimum, **AAA (7:1) is the professional standard**.

| Element | AA Minimum | AAA Target | Bible Standard |
|---------|------------|------------|----------------|
| Body text | 4.5:1 | 7:1 | **7:1** |
| Large text (18px+) | 3:1 | 4.5:1 | **4.5:1** |
| UI components | 3:1 | 3:1 | **3:1** |
| Focus indicators | 3:1 | 3:1 | **3:1** |

### Non-Negotiable Requirements

- [ ] **Color independence**: Never rely on color alone
- [ ] **Focus visible**: Clear, styled focus states
- [ ] **Touch targets**: Minimum 44x44px
- [ ] **Text scaling**: Works at 200% zoom
- [ ] **Keyboard navigation**: Full functionality
- [ ] **Screen reader**: Semantic HTML, ARIA labels
- [ ] **Reduced motion**: Respected via media query

---

## Challenge Mode

### When to Challenge User Choices

The plugin should **question** the user when:

1. **Color choices violate 80/10/10**: Too many accent colors
2. **Pure black/white used**: `#000000` or `#FFFFFF` detected
3. **Saturation too high**: Colors at 100% saturation
4. **Contrast too low**: Below AAA (7:1) for text
5. **Inconsistent sizing**: Components don't follow scale
6. **Typography violations**: Wrong hierarchy, line lengths
7. **Animation excess**: Decorative animations, long durations
8. **Dark mode issues**: Color inversion instead of parallel design

### Challenge Prompts

When detecting a violation, prompt the user:

```
Design Bible Challenge: [Issue detected]

Your choice: [What user selected]
Bible recommendation: [What the Bible suggests]
Reason: [Why this matters]

Options:
1. Apply Bible recommendation
2. Modify my choice
3. I'm certain - proceed with my choice (not recommended)
```

### User Override

Only accept override when user explicitly confirms:
> "I am definitive and sure I want to ignore plugin recommendations"

Log overrides for future reference using `kodo reflect`.

---

## QA Checklist

### Before Shipping

**Visual**
- [ ] Colors follow 80/10/10 rule
- [ ] No pure black or white
- [ ] Typography hierarchy is clear
- [ ] Spacing is consistent
- [ ] Components align to grid

**Interaction**
- [ ] All states defined (hover, active, focus, disabled)
- [ ] Animations are purposeful
- [ ] Reduced motion supported
- [ ] Loading states present

**Accessibility**
- [ ] AAA contrast achieved
- [ ] Keyboard navigation works
- [ ] Screen reader tested
- [ ] Focus states visible
- [ ] Touch targets adequate

**Responsive**
- [ ] Mobile-first approach
- [ ] Breakpoints tested
- [ ] Touch interactions work
- [ ] Text remains readable

**Dark Mode**
- [ ] Parallel design (not inverted)
- [ ] Contrast maintained
- [ ] Images adapted
- [ ] Shadows removed/adjusted

---

## Quick Reference Card

```
COLOR:        80% neutral / 10% brand / 10% feedback
NEUTRALS:     #F7F6F4 (light) / #1A1A1A (dark)
SATURATION:   70-85% (never 100%)
CONTRAST:     7:1 AAA target

TYPOGRAPHY:   H1=44-56 / H2=28-32 / H3=20-24 / Body=16 / Small=14
LINE LENGTH:  45-75 characters

BUTTONS:      40-48px height / 8px radius / 16-24px padding
INPUTS:       40-48px height / 8px radius / 16px font
CARDS:        12-16px radius / 20-24px padding

ANIMATION:    Micro=150-200ms / State=250-300ms / Page=300-400ms
MOTION:       Always respect prefers-reduced-motion

DARK MODE:    Parallel design, not inversion
              Reduce saturation 10-20%
              Remove/reduce shadows
```

---

## Resources

- WCAG 2.2 Guidelines: https://www.w3.org/WAI/WCAG22/quickref/
- Contrast Checker: https://webaim.org/resources/contrastchecker/
- Color Blindness Simulator: https://www.color-blindness.com/coblis-color-blindness-simulator/
- Animation Performance: https://web.dev/animations-guide/
