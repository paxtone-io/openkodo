# Component Patterns

Accessible, production-ready patterns for common UI components.
All patterns assume React + TypeScript + Tailwind CSS + shadcn/ui.

---

## Design Bible Component Specifications

These specifications come from the Design Bible and should be treated as **professional standards**. The plugin will **challenge** user choices that deviate significantly from these values.

### Buttons (Bible Standard)

| Property | Value | Notes |
|----------|-------|-------|
| Height (default) | 40px | Touch-friendly |
| Height (large) | 48px | Primary CTAs |
| Height (small) | 32px | Inline, secondary |
| Border radius | 8px | Consistent, not pill-shaped |
| Padding X | 16px-24px | Proportional to height |
| Font weight | 500-600 | Medium to semibold |
| Min width | 80px | Prevent cramped buttons |

**Required States** (all buttons must have):
- Default
- Hover (subtle lift or darken)
- Active/Pressed (slight inset)
- Focus (visible ring, 2px offset, 3:1 contrast)
- Disabled (50% opacity, no pointer)
- Loading (spinner, preserve width)

### Inputs (Bible Standard)

| Property | Value | Notes |
|----------|-------|-------|
| Height | 40-48px | Match button height |
| Border radius | 8px | Consistent with buttons |
| Border | 1px solid | `#E5E4E2` light / `#333333` dark |
| Padding X | 12-16px | Comfortable typing |
| Font size | 16px | **Prevents iOS zoom** |

**Required States**:
- Default
- Hover (border darkens)
- Focus (brand color ring)
- Error (red border + icon)
- Disabled (grayed background)
- Filled (subtle background change)

### Cards (Bible Standard)

| Property | Value | Notes |
|----------|-------|-------|
| Border radius | 12-16px | Larger than buttons |
| Padding | 20-24px | Generous whitespace |
| Shadow | Subtle, layered | Not harsh drop shadows |
| Border | Optional | 1px if no shadow |

### Navigation (Bible Standard)

| Property | Value | Notes |
|----------|-------|-------|
| Height (desktop) | 64-72px | Substantial presence |
| Height (mobile) | 56-64px | Thumb-reachable |
| Item padding | 12-16px | Clickable area |
| Active indicator | 2-3px | Underline or background |

### Touch Targets

**Minimum 44x44px** for all interactive elements (WCAG AAA).

---

## Navigation

### Header with Skip Link

```tsx
export function Header() {
  return (
    <>
      {/* Skip link - first focusable element */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4
                   focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-primary-foreground
                   focus:rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2"
      >
        Skip to main content
      </a>

      <header role="banner" className="sticky top-0 z-40 border-b bg-background/80 backdrop-blur-sm">
        <nav aria-label="Main navigation" className="container flex h-16 items-center justify-between">
          {/* Logo */}
          <a href="/" className="flex items-center gap-2" aria-label="Home">
            <Logo className="h-8 w-8" />
            <span className="font-display font-semibold text-lg">Brand</span>
          </a>

          {/* Navigation links */}
          <ul className="hidden md:flex items-center gap-8" role="list">
            <li><NavLink href="/features">Features</NavLink></li>
            <li><NavLink href="/pricing">Pricing</NavLink></li>
            <li><NavLink href="/docs">Docs</NavLink></li>
          </ul>

          {/* Actions */}
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm">Sign in</Button>
            <Button size="sm">Get Started</Button>
          </div>
        </nav>
      </header>

      <main id="main-content" tabIndex={-1} className="outline-none">
        {/* Page content */}
      </main>
    </>
  )
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  const isActive = usePathname() === href
  return (
    <a
      href={href}
      className={cn(
        "text-sm font-medium transition-colors hover:text-primary",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 rounded-sm",
        isActive ? "text-primary" : "text-muted-foreground"
      )}
      aria-current={isActive ? "page" : undefined}
    >
      {children}
    </a>
  )
}
```

### Mobile Navigation with Drawer

```tsx
export function MobileNav() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <Button
        variant="ghost"
        size="icon"
        className="md:hidden"
        onClick={() => setIsOpen(true)}
        aria-expanded={isOpen}
        aria-controls="mobile-nav"
        aria-label="Open menu"
      >
        <Menu className="h-5 w-5" />
      </Button>

      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent side="left" id="mobile-nav">
          <SheetHeader>
            <SheetTitle>Navigation</SheetTitle>
          </SheetHeader>
          <nav aria-label="Mobile navigation" className="mt-8">
            <ul className="flex flex-col gap-4" role="list">
              <li><MobileNavLink href="/features" onClick={() => setIsOpen(false)}>Features</MobileNavLink></li>
              <li><MobileNavLink href="/pricing" onClick={() => setIsOpen(false)}>Pricing</MobileNavLink></li>
              <li><MobileNavLink href="/docs" onClick={() => setIsOpen(false)}>Docs</MobileNavLink></li>
            </ul>
          </nav>
        </SheetContent>
      </Sheet>
    </>
  )
}
```

---

## Forms

### Accessible Form Field

```tsx
interface FormFieldProps {
  id: string
  label: string
  description?: string
  error?: string
  required?: boolean
  children: React.ReactNode
}

export function FormField({ id, label, description, error, required, children }: FormFieldProps) {
  const descriptionId = description ? `${id}-description` : undefined
  const errorId = error ? `${id}-error` : undefined

  return (
    <div className="space-y-2">
      <Label
        htmlFor={id}
        className={cn(error && "text-destructive")}
      >
        {label}
        {required && <span className="text-destructive ml-1" aria-hidden="true">*</span>}
        {required && <span className="sr-only">(required)</span>}
      </Label>

      {description && (
        <p id={descriptionId} className="text-sm text-muted-foreground">
          {description}
        </p>
      )}

      {/* Clone children to add aria attributes */}
      {React.cloneElement(children as React.ReactElement, {
        id,
        'aria-describedby': cn(descriptionId, errorId).trim() || undefined,
        'aria-invalid': error ? true : undefined,
        'aria-required': required,
      })}

      {error && (
        <p id={errorId} className="text-sm text-destructive flex items-center gap-1.5" role="alert">
          <AlertCircle className="h-4 w-4" aria-hidden="true" />
          {error}
        </p>
      )}
    </div>
  )
}

// Usage
<FormField
  id="email"
  label="Email address"
  description="We'll never share your email"
  error={errors.email?.message}
  required
>
  <Input type="email" placeholder="you@example.com" {...register('email')} />
</FormField>
```

### Password Input with Toggle

```tsx
export function PasswordInput({ className, ...props }: InputProps) {
  const [showPassword, setShowPassword] = useState(false)

  return (
    <div className="relative">
      <Input
        type={showPassword ? "text" : "password"}
        className={cn("pr-10", className)}
        {...props}
      />
      <Button
        type="button"
        variant="ghost"
        size="icon"
        className="absolute right-0 top-0 h-full px-3 hover:bg-transparent"
        onClick={() => setShowPassword(!showPassword)}
        aria-label={showPassword ? "Hide password" : "Show password"}
        aria-pressed={showPassword}
      >
        {showPassword ? (
          <EyeOff className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
        ) : (
          <Eye className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
        )}
      </Button>
    </div>
  )
}
```

---

## Feedback

### Toast Notifications

```tsx
// Accessible toast with proper ARIA
export function toast({ title, description, variant = "default" }: ToastProps) {
  return (
    <div
      role="alert"
      aria-live={variant === "destructive" ? "assertive" : "polite"}
      className={cn(
        "pointer-events-auto relative flex w-full items-center justify-between gap-4",
        "rounded-lg border p-4 shadow-lg",
        "transition-all data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-80 data-[state=open]:fade-in-0",
        "data-[state=closed]:slide-out-to-right-full data-[state=open]:slide-in-from-top-full",
        variants[variant]
      )}
    >
      <div className="flex items-start gap-3">
        {variant === "destructive" && <AlertCircle className="h-5 w-5 text-destructive" aria-hidden="true" />}
        {variant === "success" && <CheckCircle className="h-5 w-5 text-success" aria-hidden="true" />}
        <div className="grid gap-1">
          {title && <p className="text-sm font-semibold">{title}</p>}
          {description && <p className="text-sm text-muted-foreground">{description}</p>}
        </div>
      </div>
      <Button
        variant="ghost"
        size="icon"
        className="h-6 w-6"
        aria-label="Dismiss notification"
      >
        <X className="h-4 w-4" />
      </Button>
    </div>
  )
}
```

### Loading States

```tsx
// Skeleton with proper aria
export function CardSkeleton() {
  return (
    <div
      className="rounded-lg border bg-card p-6"
      aria-busy="true"
      aria-label="Loading content"
    >
      <div className="space-y-4">
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-4 w-full" />
        <Skeleton className="h-4 w-5/6" />
      </div>
    </div>
  )
}

// Button loading state
<Button disabled={isLoading}>
  {isLoading ? (
    <>
      <Loader2 className="mr-2 h-4 w-4 animate-spin" aria-hidden="true" />
      <span>Processing...</span>
      <span className="sr-only">Please wait</span>
    </>
  ) : (
    "Submit"
  )}
</Button>
```

### Empty State

```tsx
export function EmptyState({
  icon: Icon,
  title,
  description,
  action,
}: EmptyStateProps) {
  return (
    <div
      className="flex flex-col items-center justify-center py-16 px-4 text-center"
      role="status"
    >
      <div className="rounded-full bg-muted p-4 mb-6">
        <Icon className="h-8 w-8 text-muted-foreground" aria-hidden="true" />
      </div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-muted-foreground max-w-sm mb-6">{description}</p>
      {action}
    </div>
  )
}

// Usage
<EmptyState
  icon={Inbox}
  title="No messages yet"
  description="When you receive messages, they'll appear here. Start a conversation to get going."
  action={<Button>Send your first message</Button>}
/>
```

---

## Data Display

### Accessible Data Table

```tsx
export function DataTable<T>({ columns, data, caption }: DataTableProps<T>) {
  return (
    <div className="rounded-lg border overflow-hidden">
      <Table>
        {caption && <caption className="sr-only">{caption}</caption>}
        <TableHeader>
          <TableRow>
            {columns.map((column) => (
              <TableHead
                key={column.id}
                scope="col"
                className={cn(column.sortable && "cursor-pointer select-none")}
                aria-sort={column.sortDirection}
              >
                <div className="flex items-center gap-2">
                  {column.header}
                  {column.sortable && (
                    <ArrowUpDown className="h-4 w-4" aria-hidden="true" />
                  )}
                </div>
              </TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.length === 0 ? (
            <TableRow>
              <TableCell colSpan={columns.length} className="h-24 text-center">
                No results found.
              </TableCell>
            </TableRow>
          ) : (
            data.map((row, index) => (
              <TableRow key={index}>
                {columns.map((column) => (
                  <TableCell key={column.id}>
                    {column.cell(row)}
                  </TableCell>
                ))}
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  )
}
```

### Stats Card

```tsx
export function StatCard({ label, value, change, changeType, icon: Icon }: StatCardProps) {
  return (
    <div className="rounded-xl border bg-card p-6">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-muted-foreground">{label}</p>
        <div className="rounded-lg bg-primary/10 p-2">
          <Icon className="h-4 w-4 text-primary" aria-hidden="true" />
        </div>
      </div>
      <div className="mt-4">
        <p className="text-3xl font-bold tracking-tight">{value}</p>
        {change && (
          <p className={cn(
            "mt-2 flex items-center gap-1 text-sm",
            changeType === "positive" ? "text-success" : "text-destructive"
          )}>
            {changeType === "positive" ? (
              <TrendingUp className="h-4 w-4" aria-hidden="true" />
            ) : (
              <TrendingDown className="h-4 w-4" aria-hidden="true" />
            )}
            <span>
              {change}
              <span className="sr-only">
                {changeType === "positive" ? "increase" : "decrease"}
              </span>
            </span>
            <span className="text-muted-foreground">vs last period</span>
          </p>
        )}
      </div>
    </div>
  )
}
```

---

## Modals & Dialogs

### Confirmation Dialog

```tsx
export function ConfirmDialog({
  open,
  onOpenChange,
  title,
  description,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  variant = "default",
  onConfirm,
}: ConfirmDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{cancelLabel}</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            className={cn(variant === "destructive" && "bg-destructive text-destructive-foreground hover:bg-destructive/90")}
          >
            {confirmLabel}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
```

---

## Animation Patterns

### Staggered List Animation (Framer Motion)

```tsx
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
}

const item = {
  hidden: { opacity: 0, y: 20 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.4, ease: [0.4, 0, 0.2, 1] }
  },
}

export function StaggeredList({ children }: { children: React.ReactNode }) {
  return (
    <motion.ul
      variants={container}
      initial="hidden"
      animate="show"
      className="space-y-4"
    >
      {React.Children.map(children, (child) => (
        <motion.li variants={item}>{child}</motion.li>
      ))}
    </motion.ul>
  )
}
```

### Page Transition

```tsx
const pageTransition = {
  initial: { opacity: 0, y: 8 },
  animate: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.3, ease: [0.4, 0, 0.2, 1] }
  },
  exit: {
    opacity: 0,
    y: -8,
    transition: { duration: 0.2 }
  },
}

export function PageWrapper({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial="initial"
      animate="animate"
      exit="exit"
      variants={pageTransition}
    >
      {children}
    </motion.div>
  )
}
```

---

## Dark Mode Pattern

```tsx
// Theme provider setup
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </NextThemesProvider>
  )
}

// Theme toggle
export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      aria-label={`Switch to ${theme === "dark" ? "light" : "dark"} mode`}
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-transform dark:-rotate-90 dark:scale-0" aria-hidden="true" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-transform dark:rotate-0 dark:scale-100" aria-hidden="true" />
    </Button>
  )
}
```
