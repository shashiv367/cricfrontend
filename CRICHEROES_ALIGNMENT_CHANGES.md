# CricHeroes-Inspired Changes – Frontend (Color Palette Unchanged)

This document lists **proposed changes** to align the app’s structure and UX with patterns from the **CricHeroes** mobile app. Your **existing background and color palette will not be changed**; only layout, flows, and feature placement are in scope.

---

## 1. Research Summary: CricHeroes Mobile App

- **Product:** Free cricket scoring app (iOS/Android), 10M+ matches, 40M+ users, ~4.7★.
- **Design focus:** Simple, accessible, community-first.
- **Notable UX elements:**
  - **Cricket Feed** – Central feed: videos, news, quizzes, polls, stories, friends’ matches.
  - **Search** – Voice/search for players, tournaments, teams, clubs, grounds, academies.
  - **Tournaments** – Dedicated tournament pages, leaderboards, points table, schedule, boundary tracker, live scoring, NRR calculator.
  - **Live scoring** – Ball-by-ball, international-style scorecards.
  - **Profiles** – Player stats, badges, awards, leaderboard rankings.
  - **Social / login** – “Login with Facebook”, “Login with Google”; “Remember me”; “Forgot Password?”; “Not a member yet? Register now”.
  - **Community** – Find teams, opponents, players, umpires, grounds; book scorers/umpires/commentators/grounds.
  - **Recognition** – Badges, awards, leaderboard.
  - **CricInsights** – Performance analysis.
  - **Market** – Sell cricket products/services/skills.

Your app already has: Home (dashboard with matches), Looking (find scorers/opponents), My Cricket, Community, Store, auth (email login/signup, role-based routing). The proposals below map CricHeroes-style structure onto your current stack **without** touching `app_colors.dart` or your existing palette.

---

## 2. Your Current Color Palette (Do Not Change)

These remain **unchanged** for all work:

| Usage | Color / constant |
|-------|-------------------|
| Main backgrounds | `backgroundLight` (#F8FAFC), `backgroundWhite`, `lavenderBg`, `backgroundDark` (splash) |
| Primary / brand | `primaryElectric` / `primaryPurple` (#6D28D9), `primaryPurpleLight`, `primaryPurpleDark` |
| Accents | `accentSunset`, `accentRed`, `accentGreen`, `accentPurple`, `accentGlow`, `accentYellow` |
| Text | `textPrimary`, `textSecondary`, `textWhite`, `textMuted` |
| Cards / surfaces | `backgroundCard`, `backgroundCardAlt`, `cardLavender`, `cardPink`, etc. |
| Dividers / borders | `divider`, `border` |

All suggested UI changes must use **only** these (or existing theme values derived from them).

---

## 3. Proposed Changes (By Area)

### 3.1 Auth / Login Screen (`auth_screen.dart`)

**Current:** Single scrollable screen with “Welcome Back!” / “Join Innings”, Login vs Sign Up toggle, email/password, optional full name for signup, “Forgot Password?” (no action), primary CTA, “Or continue with” + Google/Apple. Role is fixed to `user` in UI (signup uses `_selectedRole` in code but there is no role selector visible).

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| A1 | **Copy / labels** | Optionally rename to “Sign in” / “Register” and add short line like “Continue your cricket journey” to match CricHeroes tone. |
| A2 | **Remember me** | Add a “Remember me” checkbox (state only or wired to secure storage) to mirror CricHeroes login. |
| A3 | **Forgot Password** | Implement or wire “Forgot Password?” to a recovery flow (e.g. Supabase reset) instead of leaving it no-op. |
| A4 | **Register prompt on login** | On login view, add a footer line: “Not a member yet? Register now” that switches to signup (no new screen). |
| A5 | **Social login labels** | Optionally offer “Login with Google” / “Login with Facebook” (or “Continue with Google/Facebook”) to match CricHeroes; keep existing Google/Apple buttons but ensure labels are clear. |
| A6 | **Signup role selector** | If you want CricHeroes-like “who are you?” clarity, add a visible role selector on signup (User / Player / Umpire) so `_selectedRole` is user-chosen. |

**Out of scope:** Changing background, gradients, or any colors; only layout, copy, and behavior.

---

### 3.2 Home / Feed (User Dashboard & Main)

**Current:** Main tab = `UserDashboardScreen` with sections “Matches of popular cricketers”, “From your tournaments”, search, “Find Cricketers”. App bar has logo, search, chat, notifications.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| H1 | **Feed-first section** | Add a “Feed” or “Cricket Feed” section at the top (or as first tab): short list of cards for “videos, news, quizzes, polls, stories, friends’ matches” (can be placeholders or API-driven later). |
| H2 | **Section titles** | Align section naming with CricHeroes where it fits: e.g. “Live & Upcoming”, “Your tournaments”, “From your tournaments” (you already have similar). |
| H3 | **Search scope** | Extend search (or search hints) to “players, tournaments, teams, clubs, grounds” in addition to teams, to mirror CricHeroes discovery. |
| H4 | **Voice search (optional)** | Later enhancement: add voice search entry point; no design change to palette. |

---

### 3.3 Navigation (Bottom Nav & Tabs)

**Current:** Main screen uses 5 tabs: Home, Looking, My Cricket, Community, Store. There is also a separate `BottomNavBar` widget (Home, Matches, Videos, News, More) used elsewhere or for reference.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| N1 | **Tab consistency** | Decide one canonical bottom nav: either current main (Home, Looking, My Cricket, Community, Store) or a CricHeroes-like set (e.g. Home/Feed, Matches, Videos/News, Community, More). Unify so one nav is used everywhere. |
| N2 | **“More” / “Menu”** | If you add a “More” tab, consider moving “Store”, “Ranking”, “Settings”, “Invite” there to match CricHeroes “More” pattern. |
| N3 | **FAB** | Keep “Start a match” FAB on My Cricket (or relevant tab); no color change. |

---

### 3.4 Tournaments

**Current:** “From your tournaments” on dashboard; series/detail screens exist.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| T1 | **Tournament hub** | Add a clear “Tournaments” entry (tab, drawer, or section) with: list of user’s tournaments, “Create tournament” CTA. |
| T2 | **Tournament page** | For each tournament: dedicated page with leaderboard, points table, schedule, boundary tracker (if data exists), link to live scoring. |
| T3 | **NRR / qualification** | Where relevant, surface “Smart NRR” or qualification margin (text or simple calc) using existing palette. |

---

### 3.5 Player Profiles & Recognition

**Current:** `PlayerDashboardScreen`, `profile_screen.dart`, stats and dashboard.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| P1 | **Profile as “cricket profile”** | Present profile as “Your cricket profile” with stats, form, and optional “recognition” section. |
| P2 | **Badges / awards** | Optional section for badges, awards, or leaderboard rank (can be placeholder UI first). |
| P3 | **CricInsights-style block** | Optional “Insights” or “Performance” block: form, preferred positions, simple comparisons (use existing lavender/card colors). |

---

### 3.6 Community & “Looking”

**Current:** Looking screen: “Looking for Scorer?”, filters (location, Opponent, Team to Join, Pitch), list of “looking” cards. Community screen exists.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| C1 | **Discovery scope** | Add or surface discovery of: teams, opponents, players, umpires, grounds (in addition to scorers). |
| C2 | **Booking / ecosystem** | Optional “Book scorers, umpires, commentators, grounds” entry point (can be placeholder or link to existing screens). |
| C3 | **Academies / shops** | Optional “Find academies/shops near you” (placeholder or link). |

---

### 3.7 Live Scoring & Match Experience

**Current:** Live match, scoreboard, umpire flows, commentary.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| L1 | **Scorecard prominence** | Ensure “international-grade” scorecard is easy to reach from live match (you may already have this). |
| L2 | **Broadcast / share** | Optional “Broadcast score live” or “Share scorecard” entry point. |

---

### 3.8 Store / Market

**Current:** “Store” tab, `InningsStoreScreen`.

**Proposed (CricHeroes-style, palette unchanged):**

| # | Change | Description |
|---|--------|-------------|
| S1 | **Market positioning** | Optionally rebadge or describe as “Market” – sell cricket products, services, or skills (copy/label only). |

---

## 4. Summary Table – What You Can Approve

| Area | Proposed changes | Palette |
|------|-------------------|--------|
| **Auth** | Remember me, Forgot Password flow, Register prompt, optional role selector, social labels | Unchanged |
| **Home/Feed** | Feed section, section titles, search scope (and optional voice) | Unchanged |
| **Nav** | Unify tabs; optional “More” with Store/Ranking/Settings | Unchanged |
| **Tournaments** | Tournament hub, tournament page (leaderboard, table, schedule), NRR | Unchanged |
| **Profiles** | Cricket profile framing, badges/awards, Insights block | Unchanged |
| **Community/Looking** | Discovery scope, book scorers/umpires/grounds, academies/shops | Unchanged |
| **Live** | Scorecard prominence, broadcast/share | Unchanged |
| **Store** | Market copy/label | Unchanged |

---

## 5. Next Step

- Review this document and **tell me which sections (e.g. 3.1 only, or 3.1 + 3.2, or “all of 3.1–3.8”) you want implemented**.
- I will then implement **only** those changes in the `frontend` folder and keep your **background and color palette exactly as in `app_colors.dart`** (and existing theme usage).

No color or palette changes will be made unless you explicitly ask for them later.
