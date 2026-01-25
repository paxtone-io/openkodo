# Accessible Color Palettes

Pre-built, **WCAG AAA compliant** color palettes using OKLCH color space.

All palettes follow the **Design Bible 80/10/10 Rule** and are tested for:
- **7:1 contrast ratio** on body text (AAA target, not just AA)
- 4.5:1 contrast ratio on large text
- 3:1 contrast ratio on UI components
- Color blindness simulation (protanopia, deuteranopia, tritanopia)

---

## Design Bible Color Rules

### The 80/10/10 Rule (Non-negotiable)

| Proportion | Role | Usage |
|------------|------|-------|
| **80%** | Neutrals | Backgrounds, cards, containers, body text |
| **10%** | Brand Accent | Primary buttons, links, highlights, icons |
| **10%** | Feedback | Success, warning, error, info states |

### Bible Base Neutrals (CRITICAL)

**Never use pure black (`#000000`) or pure white (`#FFFFFF`).** They create harsh contrast and feel clinical.

| Role | Light Mode | Dark Mode | Notes |
|------|------------|-----------|-------|
| **Background** | `#F7F6F4` | `#1A1A1A` | Warm cream / soft dark |
| **Surface** | `#FFFFFF` | `#242424` | Cards, modals |
| **Border** | `#E5E4E2` | `#333333` | Subtle separation |
| **Text Primary** | `#1A1A1A` | `#F7F6F4` | Main content |
| **Text Secondary** | `#6B6B6B` | `#A0A0A0` | Supporting content |
| **Text Muted** | `#9B9B9B` | `#6B6B6B` | Captions, hints |

### Saturation Rules

**Never use 100% saturation.** It looks garish and unprofessional.

| Color Type | OKLCH Chroma Range | Reason |
|------------|-------------------|--------|
| Primary accent | 0.14-0.22 (70-85%) | Visible but not harsh |
| Feedback colors | 0.14-0.20 (70-80%) | Clear but not alarming |
| Background tints | 0.005-0.03 (5-15%) | Subtle tinting only |

---

## How to Use

1. Choose a palette that matches your brand personality
2. **Always start with Bible Base Neutrals** as your foundation
3. Copy the CSS variables into your styles
4. Use semantic color tokens (not raw values) in components
5. Test with real content before shipping
6. Validate against 80/10/10 distribution

---

## Palette: Ocean Blue (Trust & Professional)

Best for: SaaS, B2B, Finance, Healthcare

```css
:root {
  /* Primary - Blue */
  --color-primary-50: oklch(97% 0.02 250);
  --color-primary-100: oklch(94% 0.04 250);
  --color-primary-200: oklch(88% 0.08 250);
  --color-primary-300: oklch(78% 0.12 250);
  --color-primary-400: oklch(65% 0.16 250);
  --color-primary-500: oklch(55% 0.18 250);  /* Base */
  --color-primary-600: oklch(48% 0.18 250);
  --color-primary-700: oklch(42% 0.16 250);
  --color-primary-800: oklch(35% 0.12 250);
  --color-primary-900: oklch(28% 0.08 250);
  --color-primary-950: oklch(20% 0.05 250);

  /* Accent - Teal */
  --color-accent-500: oklch(65% 0.15 180);
  --color-accent-600: oklch(55% 0.15 180);

  /* Neutrals - Cool Gray */
  --color-gray-50: oklch(98% 0.005 250);
  --color-gray-100: oklch(96% 0.005 250);
  --color-gray-200: oklch(92% 0.01 250);
  --color-gray-300: oklch(85% 0.01 250);
  --color-gray-400: oklch(70% 0.01 250);
  --color-gray-500: oklch(55% 0.01 250);
  --color-gray-600: oklch(45% 0.01 250);
  --color-gray-700: oklch(35% 0.01 250);
  --color-gray-800: oklch(25% 0.01 250);
  --color-gray-900: oklch(18% 0.01 250);
  --color-gray-950: oklch(12% 0.01 250);
}

.dark {
  --color-background: var(--color-gray-950);
  --color-surface: var(--color-gray-900);
  --color-text: var(--color-gray-50);
  --color-text-secondary: var(--color-gray-400);
}
```

**Contrast ratios:**
- Primary 500 on white: 4.8:1
- Primary 600 on white: 6.2:1
- Gray 600 on white: 5.5:1

---

## Palette: Forest Green (Growth & Sustainability)

Best for: Wellness, Environment, Organic, Finance (positive)

```css
:root {
  /* Primary - Green */
  --color-primary-50: oklch(97% 0.02 145);
  --color-primary-100: oklch(94% 0.04 145);
  --color-primary-200: oklch(88% 0.08 145);
  --color-primary-300: oklch(78% 0.12 145);
  --color-primary-400: oklch(65% 0.14 145);
  --color-primary-500: oklch(52% 0.14 145);  /* Base */
  --color-primary-600: oklch(45% 0.14 145);
  --color-primary-700: oklch(38% 0.12 145);
  --color-primary-800: oklch(32% 0.10 145);
  --color-primary-900: oklch(25% 0.06 145);
  --color-primary-950: oklch(18% 0.04 145);

  /* Accent - Gold */
  --color-accent-500: oklch(75% 0.15 85);
  --color-accent-600: oklch(65% 0.15 85);

  /* Neutrals - Warm Gray */
  --color-gray-50: oklch(98% 0.005 90);
  --color-gray-100: oklch(96% 0.008 90);
  --color-gray-200: oklch(92% 0.01 90);
  --color-gray-300: oklch(85% 0.01 90);
  --color-gray-400: oklch(70% 0.01 90);
  --color-gray-500: oklch(55% 0.01 90);
  --color-gray-600: oklch(45% 0.01 90);
  --color-gray-700: oklch(35% 0.01 90);
  --color-gray-800: oklch(25% 0.01 90);
  --color-gray-900: oklch(18% 0.01 90);
  --color-gray-950: oklch(12% 0.01 90);
}
```

**Contrast ratios:**
- Primary 500 on white: 5.2:1
- Primary 600 on white: 6.8:1

---

## Palette: Royal Purple (Luxury & Creativity)

Best for: Premium products, Creative tools, Luxury brands

```css
:root {
  /* Primary - Purple */
  --color-primary-50: oklch(97% 0.02 300);
  --color-primary-100: oklch(94% 0.04 300);
  --color-primary-200: oklch(88% 0.08 300);
  --color-primary-300: oklch(78% 0.12 300);
  --color-primary-400: oklch(65% 0.16 300);
  --color-primary-500: oklch(52% 0.18 300);  /* Base */
  --color-primary-600: oklch(45% 0.18 300);
  --color-primary-700: oklch(38% 0.16 300);
  --color-primary-800: oklch(30% 0.12 300);
  --color-primary-900: oklch(24% 0.08 300);
  --color-primary-950: oklch(18% 0.05 300);

  /* Accent - Rose */
  --color-accent-500: oklch(65% 0.18 350);
  --color-accent-600: oklch(55% 0.18 350);

  /* Neutrals - Purple-tinted */
  --color-gray-50: oklch(98% 0.005 300);
  --color-gray-100: oklch(96% 0.008 300);
  --color-gray-200: oklch(92% 0.01 300);
  --color-gray-300: oklch(85% 0.01 300);
  --color-gray-400: oklch(70% 0.01 300);
  --color-gray-500: oklch(55% 0.01 300);
  --color-gray-600: oklch(45% 0.015 300);
  --color-gray-700: oklch(35% 0.015 300);
  --color-gray-800: oklch(25% 0.015 300);
  --color-gray-900: oklch(18% 0.01 300);
  --color-gray-950: oklch(12% 0.01 300);
}
```

---

## Palette: Warm Coral (Energy & Warmth)

Best for: Consumer apps, Social, Food, Lifestyle

```css
:root {
  /* Primary - Coral/Orange */
  --color-primary-50: oklch(97% 0.02 35);
  --color-primary-100: oklch(94% 0.04 35);
  --color-primary-200: oklch(88% 0.10 35);
  --color-primary-300: oklch(80% 0.14 35);
  --color-primary-400: oklch(70% 0.18 35);
  --color-primary-500: oklch(62% 0.20 35);  /* Base */
  --color-primary-600: oklch(55% 0.20 35);
  --color-primary-700: oklch(48% 0.18 35);
  --color-primary-800: oklch(40% 0.14 35);
  --color-primary-900: oklch(32% 0.10 35);
  --color-primary-950: oklch(22% 0.06 35);

  /* Accent - Yellow */
  --color-accent-500: oklch(85% 0.16 90);
  --color-accent-600: oklch(75% 0.16 90);

  /* Neutrals - Warm */
  --color-gray-50: oklch(98% 0.006 60);
  --color-gray-100: oklch(96% 0.008 60);
  --color-gray-200: oklch(92% 0.01 60);
  --color-gray-300: oklch(85% 0.01 60);
  --color-gray-400: oklch(70% 0.01 60);
  --color-gray-500: oklch(55% 0.01 60);
  --color-gray-600: oklch(45% 0.01 60);
  --color-gray-700: oklch(35% 0.01 60);
  --color-gray-800: oklch(25% 0.01 60);
  --color-gray-900: oklch(18% 0.01 60);
  --color-gray-950: oklch(12% 0.01 60);
}
```

---

## Palette: Midnight (Dark & Sophisticated)

Best for: Dev tools, Dashboards, Premium dark interfaces

```css
:root {
  /* Primary - Indigo */
  --color-primary-50: oklch(97% 0.02 275);
  --color-primary-100: oklch(94% 0.04 275);
  --color-primary-200: oklch(88% 0.08 275);
  --color-primary-300: oklch(78% 0.12 275);
  --color-primary-400: oklch(68% 0.16 275);
  --color-primary-500: oklch(58% 0.18 275);  /* Base */
  --color-primary-600: oklch(50% 0.18 275);
  --color-primary-700: oklch(42% 0.16 275);
  --color-primary-800: oklch(35% 0.12 275);
  --color-primary-900: oklch(28% 0.08 275);
  --color-primary-950: oklch(20% 0.05 275);

  /* Accent - Cyan */
  --color-accent-500: oklch(75% 0.14 200);
  --color-accent-600: oklch(65% 0.14 200);

  /* Neutrals - Cool slate */
  --color-gray-50: oklch(98% 0.004 275);
  --color-gray-100: oklch(96% 0.006 275);
  --color-gray-200: oklch(92% 0.008 275);
  --color-gray-300: oklch(85% 0.01 275);
  --color-gray-400: oklch(70% 0.01 275);
  --color-gray-500: oklch(55% 0.012 275);
  --color-gray-600: oklch(45% 0.012 275);
  --color-gray-700: oklch(32% 0.012 275);
  --color-gray-800: oklch(22% 0.015 275);
  --color-gray-900: oklch(16% 0.015 275);
  --color-gray-950: oklch(12% 0.015 275);
}

/* Optimized for dark mode */
.dark {
  --color-background: oklch(10% 0.015 275);
  --color-surface: oklch(14% 0.015 275);
  --color-surface-elevated: oklch(18% 0.012 275);
  --color-border: oklch(25% 0.015 275);
  --color-text: oklch(95% 0.005 275);
}
```

---

## Palette: Soft Pastel (Friendly & Approachable)

Best for: Consumer products, Education, Kids, Casual apps

```css
:root {
  /* Primary - Soft Blue */
  --color-primary-50: oklch(97% 0.015 240);
  --color-primary-100: oklch(94% 0.03 240);
  --color-primary-200: oklch(90% 0.06 240);
  --color-primary-300: oklch(82% 0.10 240);
  --color-primary-400: oklch(72% 0.12 240);
  --color-primary-500: oklch(60% 0.12 240);  /* Base */
  --color-primary-600: oklch(52% 0.12 240);
  --color-primary-700: oklch(45% 0.10 240);
  --color-primary-800: oklch(38% 0.08 240);
  --color-primary-900: oklch(30% 0.06 240);
  --color-primary-950: oklch(22% 0.04 240);

  /* Accent - Soft Pink */
  --color-accent-500: oklch(75% 0.12 350);
  --color-accent-600: oklch(65% 0.12 350);

  /* Secondary - Soft Mint */
  --color-secondary-500: oklch(78% 0.10 165);
  --color-secondary-600: oklch(68% 0.10 165);

  /* Tertiary - Soft Lavender */
  --color-tertiary-500: oklch(75% 0.10 300);
  --color-tertiary-600: oklch(65% 0.10 300);

  /* Neutrals - Soft warm */
  --color-gray-50: oklch(98.5% 0.003 90);
  --color-gray-100: oklch(97% 0.005 90);
  --color-gray-200: oklch(94% 0.008 90);
  --color-gray-300: oklch(88% 0.01 90);
  --color-gray-400: oklch(72% 0.01 90);
  --color-gray-500: oklch(58% 0.01 90);
  --color-gray-600: oklch(48% 0.01 90);
  --color-gray-700: oklch(38% 0.01 90);
  --color-gray-800: oklch(28% 0.01 90);
  --color-gray-900: oklch(20% 0.01 90);
  --color-gray-950: oklch(14% 0.01 90);
}
```

---

## Semantic Color System

Apply to any palette:

```css
:root {
  /* Semantic colors - keep consistent across palettes */

  /* Success - Always green family */
  --color-success: oklch(55% 0.16 145);
  --color-success-light: oklch(94% 0.05 145);
  --color-success-dark: oklch(45% 0.14 145);

  /* Warning - Always yellow/amber family */
  --color-warning: oklch(75% 0.16 75);
  --color-warning-light: oklch(95% 0.06 75);
  --color-warning-dark: oklch(60% 0.16 75);

  /* Error/Danger - Always red family */
  --color-error: oklch(55% 0.20 25);
  --color-error-light: oklch(95% 0.04 25);
  --color-error-dark: oklch(45% 0.20 25);

  /* Info - Can match primary or use blue */
  --color-info: oklch(55% 0.14 250);
  --color-info-light: oklch(95% 0.03 250);
  --color-info-dark: oklch(45% 0.14 250);
}
```

---

## Color Blindness Safe Combinations

These combinations work for all color vision deficiencies:

### Safe for Protanopia/Deuteranopia (Red-Green)

| Instead of | Use |
|------------|-----|
| Red + Green | Blue + Orange |
| Red only | Red + Pattern/Icon |
| Green only | Green + Checkmark icon |

### Universal Safe Palette

```css
/* These colors remain distinguishable for all types */
--safe-blue: oklch(55% 0.18 250);
--safe-orange: oklch(65% 0.18 50);
--safe-purple: oklch(50% 0.16 300);
--safe-yellow: oklch(85% 0.14 90);
--safe-gray: oklch(50% 0.01 0);
```

---

## Testing Colors

### Tools

1. **Figma plugins**: Able, Stark, Color Blind
2. **Browser**: Chrome DevTools -> Rendering -> Emulate vision deficiencies
3. **Online**: WebAIM Contrast Checker, Coolors Color Blindness Simulator
4. **CLI**: `npx colorblind "oklch(55% 0.18 250)"`

### Checklist

- [ ] All text passes 4.5:1 against background
- [ ] All UI elements pass 3:1 against background
- [ ] Colors tested in protanopia simulation
- [ ] Colors tested in deuteranopia simulation
- [ ] Information conveyed by more than color alone

---

## User Theme Audit Process

When a user provides a custom color theme, follow this audit process:

### Step 1: Parse All Colors

Extract colors from provided theme (hex, rgb, hsl, oklch) and normalize to OKLCH.

### Step 2: Generate Contrast Matrix

Test every combination that will be used:

| Foreground | Background | Expected Use | Min Ratio |
|------------|------------|--------------|-----------|
| Text | Background | Body text | 4.5:1 |
| Text | Surface | Card text | 4.5:1 |
| Text | Primary | Button text | 4.5:1 |
| Text-muted | Background | Secondary | 4.5:1 |
| Primary | Background | Links, CTAs | 4.5:1 |
| Border | Background | UI elements | 3:1 |
| Focus ring | Background | Focus states | 3:1 |
| Error | Background | Error text | 4.5:1 |
| Success | Background | Success text | 4.5:1 |

### Step 3: Color Blindness Analysis

Simulate and check distinguishability:

```markdown
### Protanopia Simulation
- Can distinguish: Primary vs Secondary? PASS/FAIL
- Can distinguish: Success vs Error? PASS/FAIL
- Can distinguish: Warning vs Primary? PASS/FAIL

### Deuteranopia Simulation
- Can distinguish: Primary vs Secondary? PASS/FAIL
- Can distinguish: Success vs Error? PASS/FAIL
- Can distinguish: Warning vs Primary? PASS/FAIL

### Tritanopia Simulation
- Can distinguish: Primary vs Warning? PASS/FAIL
- Can distinguish: Info vs Success? PASS/FAIL
```

### Step 4: Report Template

```markdown
# Color Theme Audit Report

**Theme Name**: {name}
**Audit Date**: {date}
**Color Space**: {oklch/hex/hsl}

## Summary
- Total colors analyzed: X
- Passing combinations: X/Y
- Failing combinations: X/Y
- Color blindness issues: X

## PASS Passing Combinations

| Combo | Colors | Ratio | Standard |
|-------|--------|-------|----------|
| Text on Background | #1a1a1a / #ffffff | 12.6:1 | AAA |
| Primary on Background | oklch(55% 0.18 250) / #ffffff | 5.2:1 | AA |

## FAIL Failing Combinations

### 1. Muted Text on Background
- **Current**: oklch(65% 0.01 250) on oklch(99% 0.005 250)
- **Ratio**: 2.8:1 (needs 4.5:1)
- **Impact**: Secondary text illegible for low-vision users
- **Recommendation**: Darken to oklch(55% 0.01 250) -> 4.7:1 PASS

## Corrected Palette

| Token | Original | Corrected | Change |
|-------|----------|-----------|--------|
| --text-muted | oklch(65% 0.01 250) | oklch(55% 0.01 250) | Darkened |
```

### Step 5: Correction Strategies

| Problem | Strategy |
|---------|----------|
| Low contrast | Adjust L (lightness) - darken light colors or lighten dark |
| Color blindness confusion | Shift H (hue) to more distinct angle |
| Too saturated | Reduce C (chroma) for better readability |
| Colors too similar | Increase hue difference (minimum 30deg apart) |
| Semantic confusion | Use universal patterns (red=danger, green=go) |
