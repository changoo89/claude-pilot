---
name: frontend-design
description: Production-grade frontend design skill for distinctive, non-generic UI development. Avoids "AI slop" aesthetics through specific aesthetic direction guidelines.
license: MIT
---

# Frontend Design Skill

> **Purpose**: Create production-grade, distinctive UI that stands out from generic AI-generated designs
> **Target**: Frontend development tasks requiring visual design and styling

---

## Quick Start

### When to Use This Skill

- Building web UI components, pages, or applications
- Creating dashboard interfaces, landing pages, or marketing sites
- Styling React components, HTML/CSS layouts, or design systems
- Any task where visual quality and distinctive aesthetics matter

### Quick Reference

| Category | Key Principle | Action |
|----------|---------------|--------|
| **Fonts** | Avoid defaults | Never use Inter as default font |
| **Colors** | Avoid gradients | No purple-to-blue gradients |
| **Layout** | Embrace asymmetry | Break from rigid grids |
| **Details** | Add texture | Use noise, patterns, borders |

---

## What This Skill Covers

### In Scope

- **Aesthetic Direction**: How to choose and execute a visual style
- **Design Decisions**: Typography, color, layout, motion, spatial composition
- **Implementation**: CSS, Tailwind, shadcn/ui, React components
- **Anti-Patterns**: What to avoid to prevent generic "AI slop"

### Out of Scope

- Backend logic and API integration → Use coder skill
- Accessibility compliance basics → Follow WCAG guidelines
- Responsive design best practices → Use web-dev skills

---

## Core Principles

### 1. Choose an Aesthetic Direction

**Before writing any code, pick a specific direction:**

| Direction | Characteristics | Examples |
|-----------|----------------|----------|
| **Minimalist** | Clean, sparse, purposeful | Stripe, Linear |
| **Maximalist** | Bold, expressive, layered | Brutalist sites |
| **Warm/Human** | Organic textures, soft edges | Notion, Gumroad |
| **Technical/Precise** | Sharp edges, monospace, high contrast | Vercel, GitHub |
| **Playful** | Bright colors, rounded, animated | Discord, Slack |

**Action**: Start your response with "I'll use a **[direction]** aesthetic for this."

### 2. Make Every Detail Intentional

- **Default fonts** are the enemy → Never accept Inter as the default
- **Gradients** are a red flag → Purple-to-blue is the most overused gradient in AI-generated UI
- **Center alignment** is lazy → Explore asymmetry and interesting layouts
- **Flat colors** are boring → Add texture, noise, patterns, or subtle borders

### 3. Match Implementation Complexity

**Match the detail level to the task:**

| Task Type | Detail Level |
|-----------|--------------|
| Quick prototype | Functional but styled |
| Production component | Polished, micro-interactions |
| Landing page | Aesthetically distinctive, memorable |
| Dashboard | Clear hierarchy, data-focused |

### 4. Be Specific, Not Generic

**Bad**: "Use a nice color scheme"
**Good**: "Use a warm palette with coral (#FF6B6B) as primary, cream (#FFF8F0) background"

**Bad**: "Make it look modern"
**Good**: "Use a minimalist aesthetic with generous whitespace, thin borders, and subtle shadows"

---

## Typography

### Font Selection

**⚠️ NEVER use Inter as the default font**. It's the most overused font in AI-generated UI.

**Choose fonts with intention:**

| Category | Font Families | When to Use |
|----------|---------------|-------------|
| **Serif** | GT Super, Charter, Georgia, Merriweather | Editorial, premium feel |
| **Sans-Serif** | Geist, Satoshi, System UI, Helvetica | Clean, modern (not Inter!) |
| **Monospace** | Geist Mono, JetBrains Mono, Fira Code | Technical, code-like |
| **Display** | Clash Display, Syne, Abril Display | Headlines, personality |

**Font Pairing Principles:**
- Pair 2 fonts max (e.g., display + body, or serif + sans)
- Match mood (playful with playful, technical with technical)
- Consider readability for body text (16px minimum)

**Implementation Example:**
```css
/* Good: Specific font choice */
font-family: 'Satoshi', system-ui, sans-serif;

/* Bad: Generic fallback */
font-family: sans-serif;
```

### Typography Hierarchy

- **Headlines**: 40-72px, tight tracking (-1% to -3%)
- **Subheadlines**: 24-36px, moderate tracking
- **Body**: 16-18px, loose tracking (0% to +2%)
- **Captions/Labels**: 12-14px, uppercase or all-caps for emphasis

**Action**: Use `leading-tight` for headlines, `leading-relaxed` for body text.

---

## Color & Theme

### ⚠️ Anti-Pattern: Purple-to-Blue Gradients

**Avoid the most overused gradient in AI-generated UI:**
```css
/* BAD: This is everywhere */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Color Strategy

**1. Start with a mood:**
- **Warm**: Coral, peach, cream, terracotta
- **Cool**: Teal, sage, slate, sky blue
- **Bold**: Red, yellow, black (high contrast)
- **Muted**: Olive, rust, navy, charcoal

**2. Build a palette:**
```css
/* Example: Warm, human palette */
--primary: #FF6B6B;      /* Coral */
--secondary: #4ECDC4;    /* Teal accent */
--background: #FFF8F0;   /* Cream */
--surface: #FFFFFF;      /* White */
--text: #2D3436;         /* Dark gray */
--border: #E8E8E8;       /* Light gray */
```

**3. Use CSS variables:**
- Makes theme switching easy
- Provides semantic naming
- Enables consistent usage

### Color Usage Rules

| Use | Approach |
|-----|----------|
| **Backgrounds** | Off-white, cream, or dark (never pure #FFF) |
| **Borders** | Subtle (opacity 0.1-0.2) or sharp black/white |
| **Accents** | Single accent color, use sparingly |
| **Text** | High contrast (WCAG AA minimum) |
| **Gradients** | Subtle, same-hue shifts (no purple-to-blue!) |

---

## Motion

### Animation Principles

**1. Purposeful motion:**
- Every animation should have a reason (feedback, guidance, delight)
- Default duration: 200-300ms for micro-interactions
- Use easing: `ease-out` for entry, `ease-in` for exit

**2. Spring physics (preferred):**
```css
/* Good: Natural-feeling spring */
transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);

/* Acceptable: Standard easing */
transition: all 0.2s ease-out;
```

**3. Motion examples:**
- **Hover**: Scale up slightly (1.02), add shadow
- **Click**: Scale down slightly (0.98), provide feedback
- **Entry**: Fade in + slide up (20px)
- **Loading**: Subtle pulse or skeleton screens

### ⚠️ Anti-Pattern: Over-Animation

**Avoid:**
- Spinning loaders (use pulse instead)
- Bounce effects (dated, cartoonish)
- Slow fade-ins (>500ms feels sluggish)

---

## Spatial Composition

### Layout Strategy

**1. Break from centered alignment:**
- Explore asymmetric layouts
- Use grid systems creatively
- Consider editorial layouts (magazine-style)

**2. Whitespace is a design element:**
- Generous padding = premium feel
- Tight spacing = density, information density
- Inconsistent spacing = intentional rhythm

**3. Grid systems:**
```css
/* Example: 12-column grid */
.container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
}

/* Use asymmetric spans */
.span-7 { grid-column: span 7; }
.span-5 { grid-column: span 5; }
```

### Component Spacing

| Context | Spacing |
|---------|---------|
| **Section to section** | 80-120px |
| **Component to component** | 24-32px |
| **Element to element** | 8-16px |
| **Text line height** | 1.5-1.7 for body |

---

## Backgrounds & Visual Details

### Add Texture and Depth

**1. Noise textures:**
```css
/* Subtle noise for depth */
background: #F8F8F8;
background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.05'/%3E%3C/svg%3E");
```

**2. Subtle gradients:**
```css
/* Good: Same-hue shift */
background: linear-gradient(180deg, #F8F8F8 0%, #F0F0F0 100%);

/* Bad: Purple-to-blue (overused) */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

**3. Borders and outlines:**
- Use 1px borders with low opacity (0.1-0.2)
- Consider double borders for emphasis
- Add subtle border-radius (4-8px for modern, 0-2px for brutalist)

**4. Shadows:**
```css
/* Good: Subtle, multi-layer */
box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.05);

/* Bad: Heavy, single shadow */
box-shadow: 0 10px 20px rgba(0,0,0,0.2);
```

---

## Anti-Patterns: NEVER Use These

### The "AI Slop" Checklist

**If your design has these, it's generic AI slop:**

- [ ] **Inter font** as default → Change to something intentional
- [ ] **Purple-to-blue gradient** → Use a different color scheme
- [ ] **Perfectly centered everything** → Explore asymmetry
- [ ] **Pure white (#FFF) backgrounds** → Add off-white or texture
- [ ] **Generic shadows** → Use subtle, multi-layer shadows
- [ ] **No borders/dividers** → Add subtle separation
- [ ] **Rounded-xl (24px+) on everything** → Vary border-radius
- [ ] **No texture/noise** → Add subtle visual interest

### Before Finalizing, Check:

1. **Font**: Is Inter the default? Change it.
2. **Color**: Is there a purple gradient? Remove it.
3. **Layout**: Is everything centered? Add asymmetry.
4. **Details**: Are surfaces flat? Add noise, borders, or subtle shadows.

---

## Examples

### Example 1: Minimalist Dashboard

```css
/* Aesthetic: Minimalist, technical */
:root {
  --font: 'Geist Mono', monospace;
  --primary: #0066FF;
  --background: #FAFAFA;
  --border: rgba(0,0,0,0.08);
}

.card {
  background: white;
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
```

### Example 2: Warm Landing Page

```css
/* Aesthetic: Warm, human */
:root {
  --font: 'Satoshi', sans-serif;
  --primary: #FF6B6B; /* Coral */
  --background: #FFF8F0; /* Cream */
  --accent: #4ECDC4; /* Teal */
}

.hero {
  background: var(--background);
  padding: 120px 0;
  text-align: left; /* Asymmetric layout */
}
```

### Example 3: Brutalist Portfolio

```css
/* Aesthetic: Brutalist, bold */
:root {
  --font: 'Space Mono', monospace;
  --primary: #000000;
  --background: #FFFFFF;
  --accent: #FF0000;
}

.container {
  border: 3px solid black;
  box-shadow: 8px 8px 0 black;
}
```

---

## Implementation Tips

### Tailwind CSS

**Use arbitrary values for specificity:**
```jsx
/* Good: Specific values */
className="text-[17px] leading-[1.6] text-[#2D3436]"

/* Bad: Generic defaults */
className="text-base leading-normal text-gray-900"
```

### React Components

**Extract design tokens:**
```jsx
const theme = {
  fonts: {
    heading: 'Satoshi',
    body: 'System UI',
  },
  colors: {
    primary: '#FF6B6B',
    background: '#FFF8F0',
  },
};

// Use in components
<button style={{ backgroundColor: theme.colors.primary }} />
```

---

## Quality Checklist

Before considering the design complete:

- [ ] Aesthetic direction chosen and stated
- [ ] Font is NOT Inter default
- [ ] NO purple-to-blue gradients
- [ ] Layout uses asymmetry or interesting composition
- [ ] Colors have intentional mood/warmth
- [ ] Spacing is consistent (whitespace used intentionally)
- [ ] Textures/noise added for depth (not flat)
- [ ] Typography has clear hierarchy
- [ ] Motion is purposeful (not over-animated)
- [ ] Design feels distinctive, not generic

---

## Further Reading

**Internal**: @.claude/skills/frontend-design/REFERENCE.md - Detailed examples, patterns, case studies

**External**: [Refactoring UI](https://www.refactoringui.com/) | [Design Systems Handbook](https://www.designsystems.com/) | [Frontend Masters](https://frontendmasters.com/)
