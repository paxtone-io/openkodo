# Accessibility Checklist

WCAG 2.2 compliance checklist for frontend components and pages.

---

## Design Bible Accessibility Standards

**Target: WCAG AAA (7:1 contrast)**

While WCAG AA (4.5:1) is the legal minimum, **AAA (7:1) is the professional standard** according to the Design Bible.

| Element | AA Minimum | AAA Target | **Bible Standard** |
|---------|------------|------------|-------------------|
| Body text | 4.5:1 | 7:1 | **7:1** |
| Large text (18px+) | 3:1 | 4.5:1 | **4.5:1** |
| UI components | 3:1 | 3:1 | **3:1** |
| Focus indicators | 3:1 | 3:1 | **3:1** |

### Non-Negotiable Requirements (Design Bible)

- [ ] **Color independence**: Never rely on color alone
- [ ] **Focus visible**: Clear, styled focus states
- [ ] **Touch targets**: Minimum 44x44px
- [ ] **Text scaling**: Works at 200% zoom
- [ ] **Keyboard navigation**: Full functionality
- [ ] **Screen reader**: Semantic HTML, ARIA labels
- [ ] **Reduced motion**: Respected via `prefers-reduced-motion`

---

## Perceivable

### 1.1 Text Alternatives

- [ ] **Images have alt text** describing their content or function
- [ ] **Decorative images** use `alt=""` or `aria-hidden="true"`
- [ ] **Complex images** (charts, diagrams) have extended descriptions
- [ ] **Icons with meaning** have accessible labels
- [ ] **Icon buttons** have `aria-label` or visually hidden text

```tsx
// Correct
<img src="chart.png" alt="Sales increased 25% from Q1 to Q2" />
<button aria-label="Close dialog"><X aria-hidden="true" /></button>

// Incorrect
<img src="chart.png" alt="chart" />
<button><X /></button>
```

### 1.3 Adaptable

- [ ] **Semantic HTML** used (header, nav, main, article, section, footer)
- [ ] **Headings** follow logical hierarchy (h1 -> h2 -> h3)
- [ ] **Lists** use proper list elements (ul, ol, dl)
- [ ] **Tables** have proper headers with `scope` attribute
- [ ] **Forms** use `<label>` elements properly associated with inputs
- [ ] **Landmarks** identify page regions (banner, navigation, main, contentinfo)

```tsx
// Correct structure
<header role="banner">
  <nav aria-label="Main navigation">...</nav>
</header>
<main id="main-content">
  <h1>Page Title</h1>
  <section aria-labelledby="section-1">
    <h2 id="section-1">Section Title</h2>
  </section>
</main>
<footer role="contentinfo">...</footer>
```

### 1.4 Distinguishable

#### Color Contrast

**Bible Standard: Target AAA (7:1) whenever possible**

- [ ] **Text contrast** minimum 4.5:1, **target 7:1** (normal text)
- [ ] **Large text contrast** minimum 3:1, **target 4.5:1** (18px+ or 14px bold)
- [ ] **UI component contrast** minimum 3:1 against background
- [ ] **Focus indicator contrast** minimum 3:1

| Element | AA Minimum | **Bible Target (AAA)** | Tool |
|---------|------------|------------------------|------|
| Body text | 4.5:1 | **7:1** | WebAIM Contrast Checker |
| Large text (18px+) | 3:1 | **4.5:1** | Figma Able plugin |
| UI components | 3:1 | 3:1 | Chrome DevTools |
| Focus indicators | 3:1 | 3:1 | axe DevTools |

#### Color Independence

- [ ] **Color not sole indicator** of meaning, state, or action
- [ ] **Links** distinguishable by more than color (underline)
- [ ] **Form errors** indicated by icon/text, not just red color
- [ ] **Charts** use patterns/labels in addition to colors

```tsx
// Correct - icon + text + color
<p className="text-destructive flex items-center gap-2">
  <AlertCircle aria-hidden="true" />
  Password must be at least 8 characters
</p>

// Incorrect - color only
<p className="text-red-500">Password must be at least 8 characters</p>
```

#### Text Sizing

- [ ] **Text resizes** up to 200% without loss of content
- [ ] **No horizontal scroll** at 320px viewport width
- [ ] **Line height** minimum 1.5x font size for body text
- [ ] **Paragraph spacing** minimum 2x font size
- [ ] **Letter spacing** minimum 0.12x font size
- [ ] **Word spacing** minimum 0.16x font size

---

## Operable

### 2.1 Keyboard Accessible

- [ ] **All interactive elements** reachable via keyboard
- [ ] **Tab order** follows logical reading order
- [ ] **No keyboard traps** - can navigate away from any element
- [ ] **Skip link** provided to bypass navigation
- [ ] **Shortcuts** don't conflict with browser/AT shortcuts

```tsx
// Skip link - first focusable element
<a href="#main-content" className="sr-only focus:not-sr-only ...">
  Skip to main content
</a>
```

#### Focus Indicators

- [ ] **Focus visible** on all interactive elements
- [ ] **Focus style** has 3:1 contrast minimum
- [ ] **Focus not obscured** by other elements
- [ ] **Custom focus styles** are clear and consistent

```css
/* Visible focus style */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Never do this */
:focus {
  outline: none;
}
```

### 2.4 Navigable

- [ ] **Page has title** describing its purpose
- [ ] **Focus order** preserves meaning and operability
- [ ] **Link purpose** clear from link text (no "click here")
- [ ] **Multiple ways** to find pages (nav, search, sitemap)
- [ ] **Headings** describe topic or purpose

```tsx
// Clear link purpose
<a href="/pricing">View pricing plans</a>

// Unclear
<a href="/pricing">Click here</a>
```

### 2.5 Input Modalities

- [ ] **Touch targets** minimum 44x44px (24x24px with spacing)
- [ ] **Pointer gestures** have single-pointer alternatives
- [ ] **Motion activation** can be disabled or has alternatives
- [ ] **Draggable items** have keyboard alternatives

```tsx
// Adequate touch target
<Button className="min-h-[44px] min-w-[44px] px-4">
  Save
</Button>
```

---

## Understandable

### 3.1 Readable

- [ ] **Page language** declared with `lang` attribute
- [ ] **Language changes** marked with `lang` attribute

```html
<html lang="en">
  <p>The French word for hello is <span lang="fr">bonjour</span>.</p>
</html>
```

### 3.2 Predictable

- [ ] **Focus doesn't trigger** unexpected context changes
- [ ] **Input doesn't trigger** unexpected submissions
- [ ] **Navigation consistent** across pages
- [ ] **Components consistent** in identification

### 3.3 Input Assistance

- [ ] **Error identification** clear and specific
- [ ] **Labels or instructions** provided for inputs
- [ ] **Error prevention** for legal/financial/data submissions
- [ ] **Suggestions** provided for fixing errors

```tsx
// Clear error with suggestion
<FormField
  error="Email must be a valid address (e.g., name@example.com)"
/>

// Vague error
<FormField error="Invalid input" />
```

---

## Robust

### 4.1 Compatible

- [ ] **Valid HTML** with proper nesting
- [ ] **Unique IDs** on page
- [ ] **ARIA used correctly** (valid roles, states, properties)
- [ ] **Status messages** announced to screen readers

```tsx
// Proper ARIA usage
<div role="alert" aria-live="polite">
  Your message has been sent.
</div>

// Status for screen readers
<span role="status" aria-live="polite" className="sr-only">
  {results.length} results found
</span>
```

---

## Component-Specific Checklists

### Buttons

- [ ] `<button>` element used (not div/span)
- [ ] Clear, descriptive text
- [ ] Loading state announced (`aria-busy`)
- [ ] Disabled state uses `disabled` attribute
- [ ] Icon-only buttons have `aria-label`

### Forms

- [ ] Each input has associated `<label>`
- [ ] Required fields indicated visually AND programmatically
- [ ] Error messages associated with inputs (`aria-describedby`)
- [ ] Form errors announced to screen readers
- [ ] Autocomplete attributes on appropriate inputs

### Modals/Dialogs

- [ ] Focus trapped within modal when open
- [ ] Focus returns to trigger when closed
- [ ] Escape key closes modal
- [ ] Background content has `aria-hidden="true"`
- [ ] Modal has accessible name (title)

### Menus/Dropdowns

- [ ] Arrow keys navigate options
- [ ] Enter/Space selects option
- [ ] Escape closes menu
- [ ] Current selection indicated with `aria-selected`
- [ ] Menu has `role="menu"` or `role="listbox"`

### Tabs

- [ ] Tab list has `role="tablist"`
- [ ] Tabs have `role="tab"`
- [ ] Panels have `role="tabpanel"`
- [ ] Arrow keys navigate between tabs
- [ ] Active tab indicated with `aria-selected="true"`

### Carousels

- [ ] Pause/play controls available
- [ ] Previous/next controls keyboard accessible
- [ ] Auto-play can be stopped
- [ ] Current position indicated
- [ ] Content accessible when JavaScript fails

---

## Testing Tools

### Automated Testing

| Tool | Type | What it catches |
|------|------|-----------------|
| axe DevTools | Browser extension | ~30% of issues |
| Lighthouse | Chrome built-in | Basic accessibility |
| eslint-plugin-jsx-a11y | Linter | Code-time issues |
| @axe-core/react | Runtime | Development warnings |

### Manual Testing

| Test | How |
|------|-----|
| Keyboard navigation | Unplug mouse, navigate entire page |
| Screen reader | Use VoiceOver (Mac) or NVDA (Windows) |
| Zoom | Test at 200% browser zoom |
| High contrast | Enable OS high contrast mode |
| Reduced motion | Enable prefers-reduced-motion |

### Screen Reader Testing

```bash
# MacOS - VoiceOver
Cmd + F5  # Toggle VoiceOver
Ctrl + Option + Arrow  # Navigate

# Windows - NVDA (free)
# Download from nvaccess.org
Insert + Down Arrow  # Read all
Tab  # Navigate interactive
```

---

## Quick Reference: ARIA Roles

### Landmark Roles
- `banner` - Site header
- `navigation` - Navigation
- `main` - Main content
- `complementary` - Sidebar
- `contentinfo` - Footer
- `search` - Search functionality
- `form` - Form landmark (if named)

### Widget Roles
- `button` - Clickable action
- `link` - Navigation link
- `checkbox` - Checkable option
- `radio` - Radio option
- `textbox` - Text input
- `listbox` - Selection list
- `menu` - Dropdown menu
- `dialog` - Modal dialog
- `alertdialog` - Alert modal
- `tab`, `tablist`, `tabpanel` - Tabs

### Live Region Roles
- `alert` - Important, time-sensitive
- `status` - Status update (polite)
- `log` - Sequential info
- `timer` - Time updates

---

## Resources

- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [MDN Accessibility Guide](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)
- [Inclusive Components](https://inclusive-components.design/)
