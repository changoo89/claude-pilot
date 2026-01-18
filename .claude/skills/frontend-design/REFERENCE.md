# Frontend Design Reference

> **Companion to**: @.claude/skills/frontend-design/SKILL.md
> **Purpose**: Detailed examples, patterns, and case studies for distinctive frontend design

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Aesthetic Directions](#aesthetic-directions)
3. [Example Outputs](#example-outputs)
4. [Good vs Bad Comparisons](#good-vs-bad-comparisons)
5. [Common Patterns](#common-patterns)
6. [Troubleshooting](#troubleshooting)

---

## Design Philosophy

### The Problem: "AI Slop"

AI-generated frontend code often suffers from generic, cookie-cutter aesthetics:

**Symptoms:**
- Inter font as default
- Purple-to-blue gradients
- Perfectly centered layouts
- Flat, untextured surfaces
- Generic shadows
- Heavy rounded corners everywhere

**Root Cause:**
- LLMs trained on popular UI examples (Vercel, Linear, Stripe)
- Lack of specific aesthetic direction
- Safe, conservative design choices

### Our Approach

**Principle**: Intentionality over defaults

1. **Always choose a direction** - Never default to "modern"
2. **Make specific choices** - "Coral (#FF6B6B)" not "a nice color"
3. **Add visual interest** - Texture, noise, borders, asymmetry
4. **Match complexity to task** - Prototype vs production vs landing page

### The Aesthetic Decision Framework

Before writing any UI code, answer:

1. **Mood**: Warm/Human, Technical/Precise, Playful, Bold?
2. **Primary Font**: Serif, Sans-serif (not Inter!), Monospace, Display?
3. **Color Strategy**: Warm palette, cool muted, bold high-contrast?
4. **Layout Style**: Asymmetric editorial, centered minimalist, brutalist bold?
5. **Visual Details**: Noise texture, sharp borders, subtle shadows, flat?

**Write these down.** They guide every subsequent decision.

---

## Aesthetic Directions

### 1. Minimalist (Stripe, Linear-inspired)

**Characteristics:**
- Clean, sparse, purposeful
- Generous whitespace
- Thin borders, subtle shadows
- Monospace or geometric sans-serif fonts
- Cool color palette (blues, grays, whites)

**When to use:**
- Developer tools
- SaaS dashboards
- Professional services
- Financial products

**Code Example:**
```css
:root {
  --font: 'Geist Mono', monospace;
  --primary: #0066FF;
  --background: #FAFAFA;
  --border: rgba(0,0,0,0.08);
  --text: #1A1A1A;
}

.card {
  background: white;
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
```

### 2. Warm/Human (Notion, Gumroad-inspired)

**Characteristics:**
- Organic textures, soft edges
- Warm color palette (coral, peach, cream)
- Rounded corners (8-16px)
- Humanist sans-serif or serif fonts
- Subtle noise/grain textures

**When to use:**
- Consumer apps
- Creative tools
- Community platforms
- Educational content

**Code Example:**
```css
:root {
  --font: 'Satoshi', sans-serif;
  --primary: #FF6B6B; /* Coral */
  --background: #FFF8F0; /* Cream */
  --surface: #FFFFFF;
  --text: #2D3436;
}

.button {
  background: var(--primary);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 12px 24px;
  font-weight: 500;
  transition: transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.button:hover {
  transform: scale(1.02);
}
```

### 3. Brutalist (Bold, experimental)

**Characteristics:**
- Sharp edges, no border-radius
- High contrast (black, white, bold accent)
- Monospace fonts
- Heavy borders (2-3px)
- Asymmetric layouts
- No gradients or shadows

**When to use:**
- Portfolios
- Artistic projects
- Bold brand statements
- Experimental interfaces

**Code Example:**
```css
:root {
  --font: 'Space Mono', monospace;
  --primary: #000000;
  --accent: #FF0000;
  --background: #FFFFFF;
}

.container {
  border: 3px solid black;
  box-shadow: 8px 8px 0 black;
  padding: 32px;
}

.button {
  background: black;
  color: white;
  border: none;
  padding: 16px 32px;
  font-family: var(--font);
  text-transform: uppercase;
  letter-spacing: 1px;
}
```

### 4. Maximalist (Layered, expressive)

**Characteristics:**
- Bold colors, patterns
- Multiple fonts (display + body)
- Decorative elements
- Strong shadows, gradients (intentional)
- Dense information layout

**When to use:**
- Marketing sites
- Editorial content
- Fashion/lifestyle brands
- Entertainment

**Code Example:**
```css
:root {
  --font-display: 'Clash Display', sans-serif;
  --font-body: 'Charter', serif;
  --primary: #FF006E;
  --secondary: #8338EC;
  --background: #FB5607;
}

.hero {
  background: linear-gradient(45deg, var(--primary), var(--secondary));
  color: white;
  padding: 80px 40px;
  font-family: var(--font-display);
  font-size: 72px;
  text-shadow: 4px 4px 0 black;
}
```

---

## Example Outputs

### Example 1: SaaS Dashboard (Minimalist)

**Context**: Project management tool for developers

**Aesthetic Direction:**
- Mood: Technical/Precise
- Font: Geist Mono (monospace)
- Color: Cool blue (#0066FF), gray, white
- Layout: Asymmetric sidebar + main content
- Details: Thin borders, subtle shadows

```jsx
// Dashboard Component
function Dashboard() {
  return (
    <div className="flex h-screen bg-[#FAFAFA]">
      {/* Asymmetric sidebar */}
      <aside className="w-64 border-r border-[rgba(0,0,0,0.08)] p-6">
        <nav className="space-y-2">
          <NavItem label="Projects" />
          <NavItem label="Tasks" />
          <NavItem label="Team" />
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1 p-8">
        <header className="mb-8">
          <h1 className="text-[40px] font-['Geist_Mono'] tracking-tight">
            Projects
          </h1>
        </header>

        <div className="grid grid-cols-3 gap-6">
          <MetricCard label="Active" value="12" />
          <MetricCard label="Completed" value="48" />
          <MetricCard label="Overdue" value="3" />
        </div>
      </main>
    </div>
  );
}

function MetricCard({ label, value }) {
  return (
    <div className="bg-white border border-[rgba(0,0,0,0.08)] rounded-[4px] p-6 shadow-[0_1px_3px_rgba(0,0,0,0.05)]">
      <div className="text-[#666] text-[14px] mb-2">{label}</div>
      <div className="text-[32px] font-['Geist_Mono']">{value}</div>
    </div>
  );
}
```

**Why this works:**
- Monospace font = technical feel
- Thin borders (0.08 opacity) = refined
- 4px border-radius = modern but not generic
- Subtle shadow = depth without weight

### Example 2: Landing Page (Warm/Human)

**Context**: Creative writing app for indie authors

**Aesthetic Direction:**
- Mood: Warm/Human
- Font: Satoshi (humanist sans-serif)
- Color: Coral (#FF6B6B), cream, teal accent
- Layout: Asymmetric hero, feature cards
- Details: Soft rounded corners, subtle shadows

```jsx
// Landing Page Component
function LandingPage() {
  return (
    <div className="min-h-screen bg-[#FFF8F0]">
      {/* Asymmetric hero section */}
      <section className="grid grid-cols-12 gap-8 px-8 py-32">
        <div className="col-span-7">
          <h1 className="text-[64px] font-['Satoshi'] leading-tight text-[#2D3436] mb-6">
            Write stories that <span className="text-[#FF6B6B]">matter</span>
          </h1>
          <p className="text-[20px] text-[#636E72] mb-8 leading-relaxed">
            The creative writing tool for indie authors who care about craft.
          </p>
          <button className="bg-[#FF6B6B] text-white px-8 py-4 rounded-[12px] font-semibold hover:scale-[1.02] transition-transform">
            Start writing free
          </button>
        </div>

        {/* Empty col-span-5 creates asymmetry */}
        <div className="col-span-5" />
      </section>

      {/* Feature cards */}
      <section className="px-8 pb-32">
        <div className="grid grid-cols-3 gap-8">
          <FeatureCard
            icon="✨"
            title="Distraction-free"
            description="Just you and your words"
          />
          <FeatureCard
            icon="📚"
            title="Story organization"
            description="Keep your plotlines organized"
          />
          <FeatureCard
            icon="🎯"
            title="Daily goals"
            description="Build a writing habit"
          />
        </div>
      </section>
    </div>
  );
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="bg-white p-8 rounded-[16px] shadow-[0_2px_8px_rgba(0,0,0,0.06)]">
      <div className="text-[32px] mb-4">{icon}</div>
      <h3 className="text-[20px] font-semibold text-[#2D3436] mb-2">{title}</h3>
      <p className="text-[#636E72]">{description}</p>
    </div>
  );
}
```

**Why this works:**
- Warm color palette (coral, cream)
- Asymmetric grid (7/5 split) breaks from centered
- 12-16px border-radius = soft, human feel
- Coral CTA = distinctive, not generic blue

### Example 3: Portfolio (Brutalist)

**Context**: Creative developer portfolio

**Aesthetic Direction:**
- Mood: Bold, experimental
- Font: Space Mono (monospace)
- Color: Black, white, red accent
- Layout: Sharp edges, heavy borders
- Details: No rounded corners, hard shadows

```jsx
// Portfolio Component
function Portfolio() {
  return (
    <div className="min-h-screen bg-white">
      {/* Brutalist header */}
      <header className="border-b-3 border-black p-8">
        <nav className="flex justify-between items-center">
          <h1 className="text-[24px] font-['Space_Mono'] uppercase tracking-widest">
            DEV_PORTFOLIO
          </h1>
          <div className="flex gap-8">
            <a href="#" className="uppercase text-[14px]">Work</a>
            <a href="#" className="uppercase text-[14px]">About</a>
            <a href="#" className="uppercase text-[14px]">Contact</a>
          </div>
        </nav>
      </header>

      {/* Hero with hard shadow */}
      <section className="p-8">
        <div className="border-3 border-black shadow-[8px_8px_0_black] p-12">
          <h2 className="text-[48px] font-['Space_Mono'] uppercase mb-6">
            I build <span className="text-[#FF0000]">websites</span>
          </h2>
          <p className="text-[20px] font-['Space_Mono'] leading-relaxed">
            Creative developer focused on distinctive interfaces.
            Based in Seoul. Available for freelance.
          </p>
        </div>
      </section>

      {/* Project grid */}
      <section className="p-8">
        <div className="grid grid-cols-2 gap-8">
          <ProjectCard title="Project One" year="2024" />
          <ProjectCard title="Project Two" year="2024" />
        </div>
      </section>
    </div>
  );
}

function ProjectCard({ title, year }) {
  return (
    <div className="border-3 border-black p-6 hover:bg-black hover:text-white transition-colors">
      <div className="text-[12px] uppercase mb-2">{year}</div>
      <h3 className="text-[24px] font-['Space_Mono'] uppercase">{title}</h3>
    </div>
  );
}
```

**Why this works:**
- 3px borders = brutalist statement
- Hard shadow (no blur) = bold
- Red accent = high contrast
- No border-radius = sharp, intentional
- Uppercase typography = confident

---

## Good vs Bad Comparisons

### Comparison 1: Button Styling

**❌ BAD: Generic AI Slop**
```jsx
<button className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-3 rounded-xl font-medium hover:scale-105 transition-all">
  Click me
</button>
```
**Problems:**
- Purple-to-blue gradient (most overused)
- Heavy rounded-xl (generic)
- Scale-105 (cartoonish animation)

**✅ GOOD: Intentional Design**
```jsx
<button className="bg-[#FF6B6B] text-white px-8 py-4 rounded-[8px] font-semibold hover:scale-[1.02] transition-transform">
  Get started free
</button>
```
**Why it works:**
- Specific color (#FF6B6B coral)
- Moderate border-radius (8px)
- Subtle animation (1.02 scale)
- Descriptive label

### Comparison 2: Card Component

**❌ BAD: Generic**
```jsx
<div className="bg-white rounded-2xl p-6 shadow-lg">
  <h3 className="text-xl font-semibold text-gray-900">Title</h3>
  <p className="text-gray-600">Description</p>
</div>
```
**Problems:**
- Inter font (default)
- Generic shadow (shadow-lg)
- Rounded-2xl (over-rounded)
- Gray colors (boring)

**✅ GOOD: Distinctive**
```jsx
<div className="bg-white border border-[rgba(0,0,0,0.1)] rounded-[4px] p-6 shadow-[0_1px_3px_rgba(0,0,0,0.05)]">
  <h3 className="text-[20px] font-['Satoshi'] text-[#2D3436]">Title</h3>
  <p className="text-[#636E72]">Description</p>
</div>
```
**Why it works:**
- Specific font (Satoshi)
- Thin border for definition
- 4px radius = refined
- Multi-layer subtle shadow
- Warm gray palette

### Comparison 3: Hero Section

**❌ BAD: Centered & Generic**
```jsx
<section className="bg-gradient-to-br from-indigo-500 to-purple-600 py-20">
  <div className="max-w-4xl mx-auto text-center">
    <h1 className="text-5xl font-bold text-white mb-6">
      Welcome to Our Product
    </h1>
    <button className="bg-white text-purple-600 px-8 py-3 rounded-full font-semibold">
      Learn More
    </button>
  </div>
</section>
```
**Problems:**
- Gradient background (overused)
- Centered alignment (boring)
- Rounded-full button (dated)
- "Welcome" headline (generic)

**✅ GOOD: Asymmetric & Intentional**
```jsx
<section className="bg-[#FFF8F0] py-32">
  <div className="grid grid-cols-12 gap-8 px-8">
    <div className="col-span-8">
      <h1 className="text-[64px] font-['Satoshi'] leading-tight text-[#2D3436]">
        Build products that <span className="text-[#FF6B6B]">matter</span>
      </h1>
      <button className="mt-8 bg-[#FF6B6B] text-white px-8 py-4 rounded-[8px]">
        Start building
      </button>
    </div>
    <div className="col-span-4" />
  </div>
</section>
```
**Why it works:**
- Warm background color
- Asymmetric grid (8/4 split)
- Specific font (Satoshi)
- Descriptive headline
- Coral accent color

---

## Common Patterns

### Pattern 1: The Editorial Layout

**Use for**: Landing pages, marketing sites, editorial content

**Structure:**
- Asymmetric grid (e.g., 7/5 column split)
- Magazine-style typography
- High-quality imagery
- Generous whitespace

```jsx
<div className="grid grid-cols-12 gap-8 px-8">
  <div className="col-span-7">
    <h1 className="text-[72px] leading-[0.9]">Headline</h1>
  </div>
  <div className="col-span-4 col-start-9">
    <p className="text-[18px] leading-relaxed">
      Body text with interesting layout.
    </p>
  </div>
</div>
```

### Pattern 2: The Dashboard Sidebar

**Use for**: Admin panels, SaaS apps, developer tools

**Structure:**
- Fixed-width sidebar (240-280px)
- Thin border separator
- Monospace font for technical feel
- Subtle hover states

```jsx
<div className="flex">
  <aside className="w-64 border-r border-[rgba(0,0,0,0.08)]">
    <nav className="p-4 space-y-1">
      <NavItem href="/dashboard" label="Dashboard" />
      <NavItem href="/projects" label="Projects" />
    </nav>
  </aside>
  <main className="flex-1 p-8">
    {/* Content */}
  </main>
</div>
```

### Pattern 3: The Brutalist Container

**Use for**: Portfolios, experimental projects, bold statements

**Structure:**
- Heavy borders (2-3px)
- Hard shadows (no blur)
- Sharp corners (0px radius)
- High contrast colors

```jsx
<div className="border-3 border-black shadow-[8px_8px_0_black]">
  <div className="p-8">
    <h2 className="font-['Space_Mono'] uppercase">
      Brutalist Content
    </h2>
  </div>
</div>
```

### Pattern 4: The Warm Card Grid

**Use for**: Feature sections, pricing, testimonials

**Structure:**
- Warm color palette
- Soft rounded corners (12-16px)
- Subtle shadows
- Cream/off-white background

```jsx
<div className="bg-[#FFF8F0] p-8">
  <div className="grid grid-cols-3 gap-6">
    <div className="bg-white p-6 rounded-[12px] shadow-[0_2px_8px_rgba(0,0,0,0.06)]">
      <h3 className="text-[#2D3436] font-semibold mb-2">Feature</h3>
      <p className="text-[#636E72]">Description</p>
    </div>
  </div>
</div>
```

---

## Troubleshooting

### Problem: Design feels generic

**Diagnosis checklist:**
- [ ] Is Inter the default font? → Change to specific font
- [ ] Are there purple gradients? → Use intentional color palette
- [ ] Is everything centered? → Add asymmetry
- [ ] Are surfaces flat? → Add noise, borders, or subtle shadows

**Solution:** Start over with aesthetic decision framework.

### Problem: Design feels cluttered

**Diagnosis checklist:**
- [ ] Is spacing consistent? → Use 8px grid system
- [ ] Are there too many colors? → Limit to 2-3 colors
- [ ] Is typography hierarchy clear? → Use size/weight contrast

**Solution:** Simplify palette, increase whitespace, clear hierarchy.

### Problem: Design feels boring

**Diagnosis checklist:**
- [ ] Is layout too symmetric? → Add asymmetry
- [ ] Are colors too muted? → Add bold accent
- [ ] Is there no texture? → Add noise or pattern
- [ ] Are fonts too safe? → Use display font for headlines

**Solution:** Add visual interest through texture, asymmetry, or bold accent.

### Problem: Design feels chaotic

**Diagnosis checklist:**
- [ ] Are there too many fonts? → Limit to 2 max
- [ ] Is spacing inconsistent? → Use consistent scale
- [ ] Are colors clashing? → Use single-hue palette
- [ ] Is too much animation? → Reduce to essential motion

**Solution:** Simplify to 2 fonts, consistent spacing, single accent color.

---

## Quick Reference: Design Tokens

### Typography Scale

```css
--font-size-xs: 12px;
--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 18px;
--font-size-xl: 20px;
--font-size-2xl: 24px;
--font-size-3xl: 32px;
--font-size-4xl: 48px;
--font-size-5xl: 64px;
--font-size-6xl: 72px;
```

### Spacing Scale

```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
--space-10: 40px;
--space-12: 48px;
--space-16: 64px;
--space-20: 80px;
```

### Border Radius Scale

```css
--radius-sm: 2px;
--radius-base: 4px;
--radius-md: 8px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-2xl: 24px;
--radius-full: 9999px;
```

### Shadow Scale

```css
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow-base: 0 1px 3px rgba(0,0,0,0.08);
--shadow-md: 0 2px 8px rgba(0,0,0,0.08);
--shadow-lg: 0 4px 16px rgba(0,0,0,0.1);
--shadow-hard: 4px 4px 0 black; /* Brutalist */
```

---

**Version**: 1.0
**Last Updated**: 2026-01-18
