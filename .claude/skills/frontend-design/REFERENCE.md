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

---

## Good vs Bad Comparisons

**❌ BAD**: Gradient background, centered, rounded-full button, generic headline
```jsx
<section className="bg-gradient-to-br from-indigo-500 to-purple-600 py-20">
  <div className="max-w-4xl mx-auto text-center">
    <h1 className="text-5xl font-bold text-white mb-6">Welcome to Our Product</h1>
    <button className="bg-white text-purple-600 px-8 py-3 rounded-full font-semibold">Learn More</button>
  </div>
</section>
```

**✅ GOOD**: Warm color, asymmetric grid, specific font, descriptive headline
```jsx
<section className="bg-[#FFF8F0] py-32">
  <div className="grid grid-cols-12 gap-8 px-8">
    <div className="col-span-8">
      <h1 className="text-[64px] font-['Satoshi'] leading-tight text-[#2D3436]">
        Build products that <span className="text-[#FF6B6B]">matter</span>
      </h1>
      <button className="mt-8 bg-[#FF6B6B] text-white px-8 py-4 rounded-[8px]">Start building</button>
    </div>
  </div>
</section>
```

---

## Common Patterns

**Dashboard Sidebar** (Admin panels, SaaS apps):
```jsx
<div className="flex">
  <aside className="w-64 border-r border-[rgba(0,0,0,0.08)]">
    <nav className="p-4 space-y-1"><NavItem href="/dashboard" label="Dashboard" /></nav>
  </aside>
  <main className="flex-1 p-8">{/* Content */}</main>
</div>
```

**Warm Card Grid** (Feature sections, pricing):
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

| Problem | Diagnosis | Solution |
|---------|-----------|----------|
| **Generic** | Inter font / purple gradients / centered layouts / flat surfaces | Use aesthetic decision framework with specific choices |
| **Cluttered** | Inconsistent spacing / too many colors / unclear hierarchy | 8px grid system / 2-3 colors / clear size contrast |
| **Boring** | Too symmetric / muted colors / no texture / safe fonts | Add asymmetry / bold accent / texture / display fonts |
| **Chaotic** | Too many fonts / inconsistent spacing / clashing colors / excessive animation | Max 2 fonts / consistent scale / single-hue palette |

---

## Quick Reference: Design Tokens

```css
/* Typography */
--font-size-xs: 12px; --font-size-sm: 14px; --font-size-base: 16px;
--font-size-lg: 18px; --font-size-xl: 20px; --font-size-2xl: 24px;
--font-size-3xl: 32px; --font-size-4xl: 48px; --font-size-5xl: 64px; --font-size-6xl: 72px;

/* Spacing */
--space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px;
--space-5: 20px; --space-6: 24px; --space-8: 32px; --space-10: 40px;
--space-12: 48px; --space-16: 64px; --space-20: 80px;

/* Border Radius */
--radius-sm: 2px; --radius-base: 4px; --radius-md: 8px;
--radius-lg: 12px; --radius-xl: 16px; --radius-2xl: 24px; --radius-full: 9999px;

/* Shadows */
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow-base: 0 1px 3px rgba(0,0,0,0.08);
--shadow-md: 0 2px 8px rgba(0,0,0,0.08);
--shadow-lg: 0 4px 16px rgba(0,0,0,0.1);
--shadow-hard: 4px 4px 0 black;
```

---

**Version**: 1.0
**Last Updated**: 2026-01-18
