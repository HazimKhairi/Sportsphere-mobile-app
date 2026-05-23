# Player Train Hub — UIUX Design
**Date:** 2026-05-24  
**Status:** Approved  
**Scope:** Player app — Train tab redesign + 4 new feature screens

---

## Context

SportSphere mobile currently has a player Train screen that shows Drill of Day + horizontal category-scrollable drill cards. With 4 new features (Training Plans, Strength Training, Recovery Techniques, Nutrition Guidance), the Train tab becomes a full **Performance Hub**.

Research basis: Deep research conducted across Nike Training Club, TeamSnap, WHOOP, Recover Athletics, JEFIT, TeamBuildr, FC Barcelona Innovation Hub, PMC peer-reviewed studies on futsal/football conditioning.

---

## Navigation Architecture

**Decision:** All 4 features live under the Train tab. Bottom nav unchanged (5 tabs).

```
Bottom Nav: [ Home ] [ Train ] [ Schedule ] [ Sphere AI ] [ Profile ]
```

Train tab → 2×2 glassmorphism dashboard grid → each card pushes to feature screen.

Nutrition is merged into Recovery (Recovery + Nutrition screen). Scientifically justified: post-match nutrition IS recovery.

---

## Train Hub Screen (redesigned)

### Layout
1. Header: `displayLarge` "Train" + `bodyMedium` muted subtitle
2. **2×2 feature grid** — glassmorphism cards, equal height (~156px)
3. Section divider: "Today's Drill"
4. Existing Drill of Day card (unchanged)
5. Existing drill category horizontal scrolls (unchanged)

### Feature Grid Cards

| Position | Feature | Accent Color | Live Metric |
|---|---|---|---|
| Top-left | Skills | `#37F513` (brand green) | Drills available count |
| Top-right | Strength | `#F97316` (amber/orange) | Assigned workouts count + completion ring |
| Bottom-left | Plans | `#3B82F6` (blue) | Current week / total weeks |
| Bottom-right | Recovery + Nutrition | `#8B5CF6` (purple) | Wellness score % |

### Card Anatomy (per card)
- **Background:** `surfaceElev1` @ 60% opacity + `BackdropFilter` blur sigmaX/Y 20
- **Border:** 1px — top-left corner accent color @ 40%, remaining sides `white.withValues(alpha: 0.08)`
- **Icon:** 24px Lucide, accent color
- **Title:** Lexend 600 14px, `onSurface`
- **Subtitle:** Geist 400 11px, `onSurfaceMuted`
- **Metric widget:** progress bar (Plans, Skills) or mini ring (Strength) or score text (Recovery)
- **Glow:** `BoxShadow` with accent color @ 15% opacity, blurRadius 20, spread 0

### Entrance Animation
Cards stagger via existing `SphereEntrance` widget:
- Skills: `delayMs: 80`
- Strength: `delayMs: 140`
- Plans: `delayMs: 200`
- Recovery: `delayMs: 260`

---

## Strength Screen (`/train/strength`)

### Layout
1. ← back header "Strength"
2. **Assigned Workout card** — coach-assigned template name, due date, estimated duration, `Start Workout →` CTA
3. Section: "Exercises" — vertical list, each row: exercise name + sets×reps + weight + `>` chevron
4. Section: "Your Progress" — 4-week sparkline per exercise (fl_chart)

### Active Workout Mode (full screen takeover)
- Exercise name + GIF/image demo
- Set logger: tap + to add set, reps/weight input
- Rest timer countdown (stop_watch_timer)
- `wakelock_plus` keeps screen on
- Audio beep on rest end (audioplayers)
- Progress: "Exercise 2 of 5 · Set 3 of 3"

---

## Plans Screen (`/train/plans`)

### Layout
1. ← back header "Training Plans"
2. **Active Plan card** — plan name, phase badge, horizontal week strip (W1✓ W2✓ W3● W4…)
3. "This Week" section — vertical session list: day label + focus type + duration + `>`
4. Empty state if no plan assigned: "Your coach hasn't assigned a plan yet."

### Session Detail (`/train/plans/:planId`)
- Plan header with progress (Week X of Y, X% complete)
- Week tabs: collapsible week list, current week open
- Session cards: focus color-coded dot + title + duration + Mark Complete button

### Focus Color Coding
| Focus | Color |
|---|---|
| Technical | `#37F513` (green) |
| Tactical | `#3B82F6` (blue) |
| Physical/Fitness | `#F97316` (orange) |
| Rest | `onSurfaceMuted` (gray) |

---

## Recovery + Nutrition Screen (`/train/recovery`)

### Layout
1. ← back header "Recovery & Nutrition"
2. **Wellness card** — today's score (if logged) or "Log today →" CTA with progress bar
3. Section: "Recovery" — content library list (stretch guides, foam rolling, ice bath)
4. Section: "Nutrition" — Malaysian-specific guides (pre-match meal, position macros, Ramadan guide)

### Wellness Check-in (`/train/recovery/check-in`)
- 5 Hooper Index sliders (1–7 scale): Sleep quality, Fatigue, Muscle soreness, Stress, Mood
- Body soreness zone selector (simplified — 8 tappable zones)
- Composite score computed client-side: `100 - ((sum - 5) / 30 × 100)`
- Score displayed with color: ≥70% green, 50–69% amber, <50% red
- **Disclaimer:** "For general sporting guidance only. Not a substitute for a qualified sports professional."

### Content Detail (`/train/recovery/content/:id`)
- Title + category badge + duration
- Step-by-step instructions
- YouTube link via `url_launcher` (already in pubspec)
- Evidence level badge (Strong / Moderate)

---

## Micro-interactions

| Moment | Implementation |
|---|---|
| Grid cards load | `SphereEntrance` stagger (existing widget) |
| Card tap | `InkWell` + `HapticFeedback.lightImpact()` |
| Progress bar fill | `TweenAnimationBuilder` 600ms `Curves.easeOut` |
| Wellness score | `SphereCountUp` widget (already exists) |
| Week checkmark complete | `AnimatedScale` bounce (scale 1.0 → 1.3 → 1.0) |
| Set logged | Brief green flash overlay + `HapticFeedback.mediumImpact()` |

---

## New Routes (add to existing GoRouter)

```
/train                       → TrainHubScreen (replaces current TrainScreen)
/train/strength              → StrengthScreen
/train/strength/workout/:id  → ActiveWorkoutScreen
/train/plans                 → PlansScreen
/train/plans/:planId         → PlanDetailScreen
/train/recovery              → RecoveryScreen
/train/recovery/check-in     → WellnessCheckInScreen
/train/recovery/content/:id  → RecoveryContentDetailScreen
```

---

## New Packages Required

```yaml
stop_watch_timer: ^3.1.1      # rest timer countdown
wakelock_plus: ^1.2.8         # screen on during workout
audioplayers: ^6.1.0          # rest-end beep
cached_network_image: ^3.4.1  # GIF/image caching for exercises
fl_chart: ^0.70.2             # strength progress + recovery trend charts
```

---

## New Firestore Collections

| Collection | Purpose |
|---|---|
| `/exercises/{id}` | Global exercise catalog |
| `clubs/{clubId}/workoutTemplates/{id}` | Coach-assigned strength programs |
| `users/{uid}/workoutLogs/{id}` | Player workout session logs |
| `users/{uid}/personalBests/{exerciseId}` | PR tracking per exercise |
| `clubs/{clubId}/training_plans/{planId}/weeks/{wkId}/sessions/{sId}` | Training plan hierarchy |
| `users/{uid}/recovery_logs/{id}` | Daily Hooper Index check-in |
| `recovery_content/{id}` | Global recovery content library |
| `nutrition_articles/{id}` | Malaysian football nutrition articles |
| `nutrition_meal_plans/{id}` | Position/phase-based meal templates |

---

## What Does NOT Change

- Bottom nav bar (5 tabs, unchanged)
- Player home screen (keep as-is)
- Existing `/train` drill system (Skills sub-section, content unchanged)
- Staff home, roster, approvals — untouched
- SphereAI tab — untouched
- Theme tokens, spacing, radius — reuse as-is

---

## Legal Notes (Nutrition + Recovery)

- PDPA 2024 Malaysia: health data requires explicit consent modal on first open of Recovery check-in
- All nutrition content uses general guidance language only — no prescriptive medical claims
- Disclaimer required on every nutrition/recovery screen
- Halal-first: all food/supplement recommendations are JAKIM-compliant
