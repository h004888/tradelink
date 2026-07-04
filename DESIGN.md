---
name: TradeLink
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#43474e'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#74777f'
  outline-variant: '#c4c6cf'
  surface-tint: '#455f88'
  primary: '#002045'
  on-primary: '#ffffff'
  primary-container: '#1a365d'
  on-primary-container: '#86a0cd'
  inverse-primary: '#adc7f7'
  secondary: '#1b6b51'
  on-secondary: '#ffffff'
  secondary-container: '#a6f2d1'
  on-secondary-container: '#237157'
  tertiary: '#002336'
  on-tertiary: '#ffffff'
  tertiary-container: '#003a55'
  on-tertiary-container: '#1ba9ed'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#adc7f7'
  on-primary-fixed: '#001b3c'
  on-primary-fixed-variant: '#2d476f'
  secondary-fixed: '#a6f2d1'
  secondary-fixed-dim: '#8bd6b6'
  on-secondary-fixed: '#002116'
  on-secondary-fixed-variant: '#00513b'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
  container-max: 1280px
---

## Brand & Style

The design system is engineered to foster an environment of radical transparency and industrial-grade security for C2C transactions. The brand personality is **Reliable, Secure, and Transparent**, acting as a neutral but firm mediator between two parties.

The visual style follows a **Corporate / Modern** aesthetic with a lean toward **Minimalism** to reduce cognitive load during complex financial workflows. It utilizes a highly structured interface, emphasizing clarity over decoration. The emotional goal is to provide users with the "peace of mind" associated with institutional banking, while maintaining the accessibility and speed of a modern digital marketplace. High-quality whitespace and a strict adherence to grid systems reinforce the feeling of a controlled, secure environment.

## Colors

The color strategy uses functional color coding to provide immediate context for the user's current transaction state:

- **Sale Side (Primary):** Deep Blue (`#1A365D`) is used for all traditional currency-based "Sale" flows, signaling stability and institutional trust.
- **Trade Side (Secondary):** Teal/Emerald (`#065F46`) is used for bartering or "Trade" flows, providing a distinct visual pivot to keep users oriented.
- **Action/Info (Tertiary):** A brighter Blue (`#0EA5E9`) is used for general navigation and non-transactional system actions.
- **Neutral/Background:** A scale of soft grays (starting at `#F8FAFC`) is used for page backgrounds to allow crisp white (`#FFFFFF`) cards to pop, creating a clear sense of containment and organization.
- **Semantic Colors:** Standardized Red for disputes, Amber for escrow-pending, and Green for successful releases.

## Typography

The typography system relies on **Inter**, chosen for its exceptional legibility in data-heavy environments and its neutral, systematic character.

- **Hierarchy:** We use a tight scale to maintain a professional look. Headlines use a slightly tighter letter-spacing to appear more authoritative.
- **Usage:** Body-md is the workhorse for all marketplace listings. Label-md is strictly reserved for status indicators (e.g., "ESCROW ACTIVE") and small UI headers.
- **Clarity:** For monetary values, ensure `tabular-nums` (`tnum`) is enabled via CSS to ensure numbers align vertically in transaction ledgers.

## Layout & Spacing

This design system utilizes a **Fixed Grid** model for desktop to ensure transaction details remain readable and centered, and a **Fluid Grid** for mobile.

- **Desktop (12-column):** 1280px max-width, 24px gutters. Content is typically organized in cards spanning 4, 6, or 8 columns.
- **Tablet (8-column):** 16px gutters, 24px side margins.
- **Mobile (4-column):** 16px side margins.
- **Rhythm:** An 8px linear scale is used for all internal component padding (8px, 16px, 24px, 32px, 48px). Use 12px for tight clusters like avatar/username groupings.

## Elevation & Depth

To maintain a clean, trustworthy feel, the design system avoids heavy shadows. It uses **Tonal Layers** combined with **Low-contrast outlines**.

- **Surface Level 0:** The main application background (`#F8FAFC`).
- **Surface Level 1:** Primary content containers/cards (`#FFFFFF`). These use a 1px solid border (`#E2E8F0`) to define their boundary.
- **Surface Level 2:** Overlays, Modals, and Tooltips. These utilize a very soft, highly diffused ambient shadow: `0px 10px 15px -3px rgba(0, 0, 0, 0.05)`.
- **Interaction:** Buttons use a slight "press" effect (reducing elevation) rather than a "lift" effect, reinforcing the idea of a solid, grounded interface.

## Shapes

The shape language is **Soft** (0.25rem / 4px base radius). This choice strikes a balance between the "hard" corners of traditional finance and the "friendly" circles of modern social apps.

- **Base Radius (4px):** Standard inputs, small buttons, and checkboxes.
- **Large Radius (8px):** Primary cards and transaction modules.
- **Extra Large Radius (12px):** Hero sections and main modal containers.
- **Full Radius:** Exclusively reserved for status chips and user avatars.

## Components

### Buttons
- **Primary:** Filled `#1A365D` (Sale) or `#065F46` (Trade). White text.
- **Secondary:** Outlined with 1px border of the primary color.
- **CTA:** Use 16px vertical padding for high-importance transaction steps.

### Status Badges (The "Trust-Indicators")
- **Escrow Badge:** Uses a "Locked" icon. Background: Tinted Primary (10% opacity), Text: Primary Color.
- **Trade Badge:** Uses a "Swap" icon. Background: Tinted Secondary (10% opacity), Text: Secondary Color.
- **Verification Icons:** Always rendered in `#0EA5E9` to denote system-verified data.

### Cards
- Use white backgrounds with the Soft (4px) or Large (8px) radius.
- Headers within cards should have a subtle bottom divider (`#F1F5F9`).

### Input Fields
- Use a 1px `#CBD5E1` border. Focus state should use a 2px ring of `#0EA5E9` with 0px offset.

### Reputation Badges
- Small, circular avatars with a colored border ring indicating user tier (e.g., Gold, Silver). Paired with a numerical score in Body-sm (Bold).
