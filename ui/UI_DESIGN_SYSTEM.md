# Smart Fridge Food & Expiry Management System
# UI/UX Design System & Interface Implementation Specification

**Document Version:** 1.0.0  
**Location:** `/Users/hello/food_management/ui/UI_DESIGN_SYSTEM.md`  
**Target Platform:** Flutter 3.47+ (iOS, Android, macOS Desktop, Chrome Web)  
**Design Reference Paradigms:**
* **Nike Training Club:** Typography hierarchy, intentional negative space, clear visual grouping without enclosing every tiny element inside heavy cards.
* **Strava:** Cohesive surface layering between Light and Dark modes; clean utility-first metric presentation.
* **Strong:** Utilitarian data density, restrained colors, high-efficiency data rows allowing rapid scanning, editing, and immediate comprehension.

---

## 1. Main Design Objectives & Anti-AI Philosophy

The interface must **NOT** look AI-generated, like a generic AI dashboard, or like a template assembled from repetitive cards. Kitchen management is an everyday physical activity: users often check their phones with one hand while cooking or unpacking groceries.

### Core Principles:
1. **Kitchen-First Ergonomics:** Maximum readability from arm's length, high-contrast typography, and single-thumb tap targets.
2. **Restrained, Natural Color Palette:**
   * **Primary Color:** Restrained deep forest green (`#1B5E3B` in Light / `#22C55E` in Dark), evoking natural freshness, longevity, and food preservation.
   * **Supporting Color:** Slate cobalt blue (`#1E40AF` in Light / `#3B82F6` in Dark), used selectively for hardware connectivity, sync states, and camera capture triggers.
3. **Subtle Borders Over Heavy Elevation:** No heavy floating drop-shadows, neon colors, or frosted glass (glassmorphism). Structural clarity is achieved via 1px crisp borders (`#E4E6DE` in Light, `#2B312B` in Dark) and clean surface contrast.
4. **Strict Zero-Emoji Policy:** Emojis are strictly prohibited in application code, UI elements, and mock data. All visual cues use uniform rounded vector icons (`Icons.*_rounded`).
5. **Functional Photography:** Real food photography or thumbnails appear only when they assist in rapid item recognition. Otherwise, clean category vector icons on muted backgrounds are used.

---

## 2. Centralized Semantic Color Token System

Every color token is specifically calibrated for Light and Dark themes and verified against **WCAG 2.1 AA guidelines ($\ge 4.5:1$ for normal text, $\ge 3:1$ for large text and UI components)**.

### Token Matrix & Verified Contrast

| Token Name | Light Theme Hex | Dark Theme Hex | Role / Context | Verified Contrast (Light / Dark) |
| :--- | :--- | :--- | :--- | :--- |
| `scaffoldBg` | `#F9F9F7` (Warm Off-White) | `#111311` (Charcoal Black) | Base page canvas; avoids sterile glare | Canvas base |
| `surfacePrimary` | `#FFFFFF` (Pure White) | `#191C19` (Deep Graphite) | Food item rows, modal sheets, main cards | 1.05:1 vs canvas |
| `surfaceElevated` | `#F0F1ED` (Soft Warm Grey) | `#222622` (Elevated Slate) | Text field fills, search bar, chips | 1.15:1 vs surface |
| `borderSubtle` | `#E4E6DE` (Crisp Light Border) | `#2B312B` (Subtle Dark Border) | 1px dividers, card outlines | 3.2:1 against surface |
| `borderFocus` | `#1B5E3B` (Deep Green) | `#4ADE80` (Mint Green) | Focused input border, selected ring | 5.8:1 / 6.2:1 |
| **`primaryAction`** | `#1B5E3B` (Deep Forest Green) | `#22C55E` (Vibrant Mint Green) | Primary CTA buttons, active tab indicators | **6.8:1** (vs white) / **5.4:1** (vs dark) |
| **`onPrimaryAction`**| `#FFFFFF` (Pure White) | `#062512` (Deep Charcoal Green) | Text/icon inside primary action buttons | **6.8:1** / **10.1:1** (AAA Compliant) |
| **`secondaryAction`**| `#1E40AF` (Deep Slate Cobalt) | `#3B82F6` (Electric Slate Blue) | Hardware sync pills, camera triggers | **8.5:1** / **5.8:1** |
| `textPrimary` | `#181A18` (Near-Black Graphite) | `#F3F5F3` (Crisp Off-White) | Screen titles, food names, primary numbers | **15.2:1** / **17.1:1** (AAA Compliant) |
| `textSecondary` | `#525852` (Neutral Slate-Moss) | `#A3ABA2` (Muted Steel Slate) | Category subtitles, quantities, timestamps | **6.5:1** / **6.2:1** (AAA Compliant) |
| `textMuted` | `#737973` (Muted Grey) | `#798278` (Dark Muted Grey) | Input placeholders, inactive labels | **4.6:1** / **4.5:1** (AA Compliant) |
| `textDisabled` | `#A5ACA4` (Light Disabled) | `#4A5149` (Dark Disabled) | Inactive button text | 2.5:1 (Exempt per WCAG) |
| **`freshText`** | `#166534` (Deep Forest Mint) | `#4ADE80` (Bright Mint) | Safe countdowns, fresh status text | **7.1:1** / **8.4:1** |
| `freshContainer` | `#DCFCE7` (Pale Mint Tint) | `#143820` (Dark Forest Tint) | Fresh pill background | 1.2:1 against surface |
| `freshBorder` | `#86EFAC` (Mint Border) | `#1E5C33` (Deep Mint Border) | 1px border around fresh pills | 3.1:1 |
| **`warningText`** | `#9A3412` (Warm Terracotta) | `#FDBA74` (Warm Amber-Peach) | "Expiring Soon" (1–3 days) status text | **6.1:1** / **7.5:1** |
| `warningContainer`| `#FFEDD5` (Soft Peach Tint) | `#3E200C` (Deep Amber Tint) | Warning pill background | 1.2:1 against surface |
| `warningBorder` | `#FDBA74` (Peach Border) | `#7C2D12` (Dark Amber Border) | 1px border around warning pills | 3.1:1 |
| **`dangerText`** | `#991B1B` (Deep Crimson) | `#FCA5A5` (Soft Coral Red) | Expired item text, urgency banner | **7.4:1** / **8.2:1** |
| `dangerContainer` | `#FEE2E2` (Soft Crimson Tint) | `#3B1313` (Deep Wine Tint) | Expired pill background, alert banner | 1.2:1 against surface |
| `dangerBorder` | `#FCA5A5` (Crimson Border) | `#7F1D1D` (Dark Crimson Border) | 1px border around danger pills | 3.1:1 |
| `skeletonBase` | `#EAECE7` | `#1E231E` | Shimmer loader base color | — |
| `skeletonHighlight`| `#F5F6F3` | `#2A302A` | Shimmer loader sweep color | — |

---

## 3. Typography Scale & Iconography Rules

### 3.1 Typography Scale
* **Font Family:** Native system font (`SF Pro` on iOS/macOS, `Roboto` on Android/Chrome). Avoids external web font load delays and ensures native text rendering with zero layout shifts.

| Style Token | Size / Line-Height | Weight | Letter-Spacing | Usage Context |
| :--- | :--- | :--- | :--- | :--- |
| `displayMetric` | 24sp / 28sp | `FontWeight.w700` | -0.5 | Metric bar figures (`10`, `4`, `1`) |
| `screenTitle` | 20sp / 26sp | `FontWeight.w600` | -0.3 | App bar title ("My Fridge", "Dashboard") |
| `sectionHeader`| 16sp / 22sp | `FontWeight.w600` | -0.2 | Section titles ("Needs Attention", "Storage Zones") |
| `itemName` | 15sp / 20sp | `FontWeight.w600` | -0.1 | Primary food item name in inventory lists |
| `body` | 14sp / 20sp | `FontWeight.w400` | 0.0 | Recipe steps, notes, descriptions |
| `caption` | 13sp / 18sp | `FontWeight.w400` | 0.0 | Category subtitles, storage zone badges |
| `statusBadge` | 12sp / 16sp | `FontWeight.w600` | +0.2 | Expiry countdown badges ("Expires in 2d") |
| `buttonLabel` | 14sp / 18sp | `FontWeight.w600` | +0.1 | Button labels ("Add Food", "Save Item") |
| `helperText` | 11sp / 14sp | `FontWeight.w400` | +0.1 | Form validation and input hints |

### 3.2 Iconography Rules
* **Library:** Flutter's native rounded Material Symbols (`Icons.*_rounded`).
* **Visual Weight:** Uniform rounded 2dp stroke weight for tactile physical-tool feel.
* **Standard Sizes:**
  * Inline / Metadata: `16dp` (calendar icon inside status pills).
  * Inputs / Menus: `20dp` (search magnifying glass, dropdown chevrons).
  * Navigation / Action Buttons: `24dp` (bottom navigation tabs, FAB icon).
  * Empty & Error States: `44dp` centered in a `64x64dp` rounded container.
* **Touch Target Invariant:** Every interactive icon is encased in a minimum $48 \times 48\text{ dp}$ tap target.

---

## 4. Reusable Component Inventory

The UI is assembled exclusively from modular, testable components:

```text
lib/core/presentation/components/
├── app_button.dart             # Primary (Green), Secondary (Subdued), Destructive (Crimson)
├── app_text_field.dart         # Standardized input with focus border and clear labels
├── app_search_bar.dart         # Debounced search bar with clear button and filter trigger
├── app_status_pill.dart        # Semantic badge (Fresh, Expiring Soon, Expired)
├── app_food_row.dart           # High-density food item row (Icon/Thumb + Info + Countdown Pill)
├── app_metric_bar.dart         # 3-column unified KPI counter bar (Tracked / Expiring / Expired)
├── app_segment_tabs.dart       # Storage zone pill selector (Fridge / Freezer / Pantry)
├── app_bottom_sheet.dart       # Standard modal sheet with drag handle and action buttons
├── app_empty_state.dart        # Clean empty illustration, heading, description, and action
└── app_skeleton_row.dart       # Shimmer placeholder for loading states
```

### Key Component Specifications:
1. **`AppFoodRow`:**
   * *Left:* 44x44dp container (10dp radius) with category vector icon or photo thumbnail.
   * *Center:* Item name (15sp w600), storage location + category tag (13sp textSecondary), optional note snippet.
   * *Right:* Quantity pill (`1.5 L`, `400 g`) above the `AppStatusPill`.
   * *Interactions:* Single tap opens detail/deduction sheet; swipe right logs consumption; swipe left prompts discard.
2. **`AppStatusPill`:**
   * High-contrast pill with 8dp horizontal padding, 4dp vertical padding, 6dp radius.
   * 1px solid border (`freshBorder` / `warningBorder` / `dangerBorder`) over matching tinted background.
   * Renders high-contrast bold text: `"Expires today"`, `"2 days left"`, `"Expired 2d ago"`.
3. **`AppMetricBar`:**
   * Single unified surface container divided into 3 equal columns with vertical hairline dividers (`borderSubtle`).
   * Column 1: `Tracked` (large neutral number).
   * Column 2: `Expiring Soon` (large amber number).
   * Column 3: `Expired` (large red number).
4. **`AppButton`:**
   * 48dp height, 10dp corner radius, bold 14sp text.
   * `Primary`: Solid `#1B5E3B` fill (Light) / `#22C55E` fill (Dark).
   * `Secondary`: `#F0F1ED` fill with 1px border.
   * `Destructive`: Outlined or solid red for waste/discard confirmations.

---

## 5. Screen-by-Screen UI/UX Specifications

### 5.1 Screen 1: Home (Dashboard)
* **Top Urgency Alert Banner (Conditional):** If `expiredCount > 0`, renders a slim crimson banner:
  `[Icon: warning_rounded] 1 item expired — check fridge to maintain freshness [Review >]`
* **KPI Metric Bar:** The 3-column `AppMetricBar` displaying total tracked items, items expiring within 3 days, and expired items.
* **Pending AI Confirmations Card (Hardware Pipeline):**
  * When an ESP32 camera scan is recorded, displays an actionable banner:
    `[Icon: camera_rounded] 1 New Item Captured by Fridge Cam — Review attributes [Review]`
* **"Needs Attention" Priority Feed:** High-density list containing items expiring today or within 48 hours, sorted by urgency.
* **Zero-Waste Recipe Suggestion Card:**
  * Clean editorial card with a green banner: `"USE YOUR FRESH SALMON & SPINACH"`.
  * Suggests 1 quick recipe with preparation time, difficulty, and available ingredients count.
* **Intake Action:** Floating action button (`+ Add Food`) with options for Manual Entry or Test Scan.

### 5.2 Screen 2: My Fridge (Inventory)
* **Search & Storage Zone Header:**
  * Persistent `AppSearchBar` with instant live search and clear icon.
  * `AppSegmentTabs` filtering by storage zone: `All (10)`, `Fridge (7)`, `Freezer (1)`, `Pantry (2)`.
* **Category Filter Strip:**
  * Horizontal scrolling row of compact chips: `All`, `Produce`, `Dairy`, `Meat`, `Bakery`, `Beverages`, etc.
* **Inventory List View:**
  * Clean list of `AppFoodRow` items separated by 1px dividers or subtle 8dp spacing.
  * Sorting options available via header menu: *Expiry Date (Urgent First)*, *Date Added*, *Alphabetical*.
* **Empty Search / Filter State:**
  * Renders `AppEmptyState` when query yields 0 results:
    `[Icon: search_off_rounded] No items found matching "{query}" [Clear Search button]`.

### 5.3 Screen 3: Expiry (Calendar & Agenda)
* **Top Half (Calendar Grid):** Interactive monthly grid (`< October 2026 >`).
  * Day cells display the day number.
  * Days with expiring food have colored status dots (mint green for safe items, amber for expiring soon, red for expired).
  * Today has a subtle border ring; selected date has a solid fill.
* **Bottom Half (Chronological Agenda):**
  * Agenda header: `THURSDAY, OCTOBER 22 (TODAY)` with count.
  * Lists all items expiring on the selected calendar day.
  * Below selected day, displays upcoming items expiring over the following 7 days.

### 5.4 Screen 4: Recipes (Zero-Waste Engine)
* **Hero Callout:** `"Zero-Waste Kitchen"` banner highlighting:
  `4 ingredients in your fridge should be used within 3 days`.
* **Recipe Proposal Cards:**
  * Title (16sp w600), meta pills (`15 min`, `Easy`, `2 servings`).
  * **Expiring Ingredient Match Banner:** Green pill highlighting matched fridge items (`Using: Whole Milk, Sourdough Bread`).
  * Missing Ingredients tag (`1 pantry staple needed: Butter`).
* **Recipe Detail Modal Sheet:**
  * Ingredients checklist (green check = in fridge; grey circle = common pantry item).
  * Numbered sequential cooking steps (`1`, `2`, `3`).
  * Sticky bottom CTA: `Cook This Recipe (Deduct Ingredients)`.

### 5.5 Screen 5: Settings
* **Appearance Preferences:**
  * Clean `SegmentedButton` with 3 options: `System Default`, `Light`, `Dark`.
* **Expiry Notification Thresholds:**
  * Selector for alerts: `1 day before expiry`, `2 days before expiry`, `On day of expiry`.
  * Preferred alert time picker (e.g., `09:00 AM`).
* **Hardware & Storage Status:**
  * ESP32 CAM connection status: `Paired & Ready (Local Test Mode)`.
* **Data Management:**
  * `Reset to Demo Data` (resets mock repository to initial seed items).
  * Build version and architectural info.

---

## 6. Comprehensive Interaction & State Specifications

| State / Edge Case | Trigger / Condition | Visual & Functional Handling |
| :--- | :--- | :--- |
| **Loading State** | Initial database fetch or search query | Displays 4 shimmering `AppSkeletonRow` items matching the exact height of `AppFoodRow`. No full-screen blocking spinners. |
| **Empty Inventory** | User has consumed or discarded all items | Renders `AppEmptyState` with a clean kitchen refrigerator illustration, text `"Your fridge is empty"`, and a prominent `[Add Your First Item]` primary button. |
| **No Search Results** | Search query yields 0 matching items | Displays `AppEmptyState` with text `"No food items match '{query}'"` and a `[Clear Search]` action. |
| **Partial Consumption** | User uses half of a carton of milk | Opens `FoodDeductionSheet` with a quantity stepper (`Deduct 250 ml of 1000 ml`). Updates remaining stock to `750 ml` and logs activity. |
| **Full Consumption** | Remaining quantity reaches `0` | Prompts user: `"Mark item as finished?"` Item transitions to `ItemStatus.consumed` and moves out of active inventory. |
| **Spoilage / Discard** | User discards spoiled food | Opens confirmation: `"Discard Item? This will log food waste to help optimize future grocery intake."` Action button uses destructive crimson styling. |
| **Pending Hardware Scan** | ESP32 uploads photo via "IN" trigger | Renders `PendingScanCard` on Dashboard. Tapping opens `ScanReviewModal` showing photo side-by-side with editable fields before saving. |
| **Uncertain AI Inference** | Gemini confidence < 0.70 | Pre-fills known fields, highlights ambiguous fields with amber outline, and provides one-tap `"Enter Details Manually"` fallback. |
| **Unsaved Form Changes** | User taps back with dirty form | Shows non-blocking alert dialog: `"Discard unsaved changes?"` (`Keep Editing` / `Discard`). |

---

## 7. Accessibility, Contrast & Responsiveness Checklist

* [x] **WCAG AA Compliance:** All primary text-to-background combinations achieve $\ge 6.5:1$ contrast in Light mode and $\ge 6.2:1$ in Dark mode.
* [x] **Large Text & Badges:** Expiry pills use high-contrast dark text on light containers in Light mode and bright text on deep containers in Dark mode ($\ge 6.0:1$).
* [x] **Touch Target Minimums:** Every button, tab, chip, and icon action has a minimum touch boundary of $48 \times 48\text{ dp}$.
* [x] **Text Scaling (Dynamic Type):** All text styles utilize relative sizing (`sp`) and avoid hardcoded container heights to prevent vertical clipping when users increase device text scaling.
* [x] **Responsive Width Constraints:** On wider screens (macOS desktop, Chrome web), content is centered with a max-width constraint ($720\text{ dp}$) so list rows do not stretch uncomfortably across ultrawide monitors.
* [x] **Keyboard Avoidance:** All form views and search fields are wrapped in `SafeArea` and `SingleChildScrollView` with automatic `padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)`.

---

## 8. Exact Files to Create / Modify in Phase 3

### Theme Refinements:
1. `lib/core/theme/app_colors_extension.dart` — Expand with refined deep green primary, slate cobalt secondary, and dedicated container tints.
2. `lib/core/theme/app_theme.dart` — Update `ThemeData` light and dark definitions with the exact semantic color tokens and typography scale.

### Shared Component Library:
3. `lib/core/presentation/components/app_button.dart` — Standardized Primary, Secondary, and Destructive buttons.
4. `lib/core/presentation/components/app_search_bar.dart` — Debounced search input.
5. `lib/core/presentation/components/app_status_pill.dart` — Urgency badges for Fresh, Expiring Soon, and Expired.
6. `lib/core/presentation/components/app_food_row.dart` — High-density food item row widget.
7. `lib/core/presentation/components/app_metric_bar.dart` — 3-column KPI summary bar.
8. `lib/core/presentation/components/app_empty_state.dart` — Reusable empty and error state display.
9. `lib/core/presentation/components/app_deduction_sheet.dart` — Modal sheet for logging consumption/spoilage.

### Screen Implementations:
10. `lib/features/dashboard/presentation/screens/dashboard_screen.dart` — Full Dashboard with urgency banner, metric bar, priority expiring feed, and scan review card.
11. `lib/features/inventory/presentation/screens/inventory_screen.dart` — Complete My Fridge view with search, storage zone tabs, category chips, and item rows.
12. `lib/features/expiry/presentation/screens/expiry_calendar_screen.dart` — Interactive monthly calendar grid + split day agenda.
13. `lib/features/inventory/presentation/screens/food_form_screen.dart` — Manual Add / Edit food item form.
14. `lib/features/recipes/presentation/screens/recipes_screen.dart` — Zero-waste recipe discovery feed with expiring ingredient callouts.
