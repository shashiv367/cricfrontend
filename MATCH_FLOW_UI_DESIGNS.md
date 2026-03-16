## Match flow – modern UI designs (Innings style)

This document describes **visual and interaction designs only** (no code) for the full match flow:

- Create / start a match
- Select / create teams and players
- Select ground & umpires
- Live scoring (batting, bowling, overs, commentary)
- Post–match summary

All designs **must keep**:

- The global **DefaultPageBackground** (soft white + pastel purple/pink blurs)
- The existing **Innings color palette** from `AppColors` (primary electric purple, teal, etc.)

---

## 1. Create Match – Home entry & wizard

### 1.1 Entry surfaces

- **Home “Start a Match” card**
  - Card anchored in Home screen feed, with:
    - Title: “Want to start a match?”
    - Subtitle: “Create a match and start scoring in 30 seconds.”
    - Two buttons side‑by‑side:
      - **Primary (teal, filled)**: “Start a match”
      - **Outlined**: “View all matches”
  - Tapping primary opens the **Create Match wizard**.

- **Drawer item**
  - In menu: `Start A Match` → **always** opens step 1 of the new wizard.

### 1.2 Create Match – Step 1: Basic details

- **Screen layout**
  - App bar: primary purple, title “Create match”.
  - Content card centered with **glass panel** style:
    - Rounded corners (20–24 px radius)
    - White with 80–90% opacity
    - Soft drop shadow.

- **Sections**
  - **Match type selector (chips row)**:
    - Pills: `Tennis`, `Leather`, `Box`, `Other`.
    - Selected pill uses primary purple background, white text.
  - **Overs & format**
    - Dropdowns:
      - “Overs per side” → presets `5, 10, 15, 20, 25, 30` + Custom.
      - “Match format” → `Friendly`, `Tournament`, `Practice`.
  - **Date & time**
    - Two inputs side‑by‑side:
      - Date (calendar icon)
      - Start time (clock icon).
  - **CTA**
    - Full‑width primary button: **Next – Select teams**.

### 1.3 Create Match – Step 2: Teams

- **Layout**
  - Two large **team slots** stacked vertically:
    - Each slot shows:
      - Circular placeholder avatar with team initials.
      - `Select team A` / `Select team B` button (teal).
  - Between slots: diamond “vs” graphic (already implemented in `SelectPlayingTeamsScreen`).

- **Behaviour**
  - Tapping a slot:
    - Opens **Select Team** screen (Your teams / Opponents / Add).
    - After picking, returns and **immediately opens Select Squad for that team**.
  - When both teams selected:
    - Bottom sticky button: **Next – Squad & roles**.

---

## 2. Team & Player selection

### 2.1 Select Team (existing, keep visuals aligned)

- Tabs at top:
  - `Your Teams` | `Opponents` | `Add`.
- Search bar with **rounded input** and `+ Add team` button to the right.
- Team tiles:
  - Avatar (initials in colored circle, badge if verified).
  - Name, city, captain row (with `C` avatar).
  - Right side: small grid/QR icon.

### 2.2 Select Squad (new design spec)

- **Header**
  - App bar: title = team name (e.g., `Hi`), refresh icon.
  - First row under app bar:
    - Left: `Select squad` (bold) + `(Optional)` (italic, grey).
    - Right: `Select all` text button (teal).

- **Search + Add**
  - Search input:
    - Rounded 10 px, leading search icon, white filled.
  - To the right: teal filled **“Add player”** pill with icon.

- **Player list**
  - Each row:
    - Left: circular avatar with default illustration or first letter.
    - Center: player name (bold), small grey line for role/phone (optional).
    - Right: `Checkbox` for selection.
  - Row taps toggle selection.

- **Bottom CTA**
  - Sticky bottom bar:
    - Single teal button “Next – Assign roles”.
    - Disabled (greyed) until at least 1 player selected.

### 2.3 Add Players methods (new design spec)

- **Add players to `<team>` screen**
  - App bar: title “Add players to `<team>`”.
  - List of **method cards**:

1. **Team link**
   - Card with:
     - Left: circle icon (link).
     - Title: “Team link”.
     - Subtitle: “Share this with players to let them join the team.”
     - Buttons: `Share` (outlined purple) + `WhatsApp` (green).

2. **Add via phone number**
   - Card with phone icon, subtitle “Best for adding 1–2 players quickly”.

3. **Add from contacts**
   - Card with contacts icon, subtitle “Players already in your contacts”.

4. **Team QR code**
   - Card with QR code icon, subtitle “Scan and add players directly”.

Each card has rounded corners, white background, subtle border + shadow.

### 2.4 Assign Roles (captain / keeper)

- **App bar**
  - Title: `<TeamName> – captain, keeper, substitute`.
  - TabBar below:
    - `Captain` | `Wicket keeper`.

- **Tab content**
  - Instruction text at top (“Select captain” / “Select wicket keeper”).
  - List of players with:
    - Avatar.
    - Name.
    - Trailing icon:
      - Filled check circle in teal when selected.
      - Hollow circle when not.
  - Single‑select behaviour per role.

- **Bottom CTA**
  - Teal full‑width button: **Next – Match settings** (or “Done” depending on flow).

---

## 3. Location & Umpire selection

### 3.1 Ground / location picker

- **Screen structure**
  - App bar: “Select ground”.
  - Tabs: `Nearby` | `Favorites` | `Search`.

- **Nearby tab**
  - Top banner:
    - “Nearby `Hyderabad (Telangana)` (change)” – inline link to change city.
  - List of ground cards:
    - Thumbnail image.
    - Title (ground name).
    - Subtitle = area + city.
    - Right pill: rating badge (e.g., “4.5/5 · 7 reviews”).

- **Search tab**
  - Search with filters icon (sorted by distance / rating).
  - Results listed as simple rows (no images) for speed.

### 3.2 Umpire selection

- **Design**
  - Similar to “community listing” cards you already have:
    - Avatar, name, city, experience (e.g., “35 matches”).
    - Right side: toggle switch “Assign” or “Invite”.
  - Optional: bottom button “Skip for now”.

---

## 4. Live scoring – modern layout

### 4.1 Score header

- **Top card** pinned under app bar:
  - Shows:
    - Batting team name + score: `244/4 (20.0)` large.
    - Required runs / overs for chases (“Need 57 from 10 balls”).
    - Match status chip: `LIVE` (red), `COMPLETED` (grey), `RAIN DELAY` (blue).
  - Use two‑tone background:
    - Left side light purple, right side white with border between.

### 4.2 Quick controls strip

- Horizontal scrollable row of **rounded buttons**:
  - `+1`, `+2`, `+3`, `4`, `6`, `W`, `NB`, `WD`, `0.1 over`.
  - Primary actions (4, 6, W) in filled purple/teal; others outlined.

### 4.3 Batter & bowler cards

- Two stacked cards:
  - **Striker / non‑striker**
    - Avatar, name, runs (balls), SR.
  - **Current bowler**
    - Name, figures `2–15 (2.3)`, economy.
  - Each card has a small badges row: “On strike”, “Over 19.2”.

### 4.4 Over timeline & commentary

- **Over summary chips**
  - Horizontal list of chips for each ball of current over: `0 · 1 · 4 · W · 2 · 1`.
  - Selected ball highlights and shows short commentary below.

- **Commentary list**
  - Timeline list, each row:
    - Over/ball on left (`19.5`).
    - Event chip (4, 6, W) colored.
    - Text commentary to the right.

---

## 5. Post‑match summary

### 5.1 Hero summary

- Large card at top:
  - Winner line: “Dudekonda Warriors won by 39 runs”.
  - Subline: “T20 · Stadium Ground · 20 Feb 2026”.
  - Two columns for final scores.

### 5.2 Key performers

- Horizontal `MVP` cards:
  - Batter of the Match.
  - Bowler of the Match.
  - “Game‑changer” (best impact).
  - Each shows avatar, name, quick stats.

### 5.3 Share and continue

- Row of CTA buttons:
  - “Share scorecard”.
  - “Start new match with same teams”.
  - “View detailed scorecard”.

---

## 6. General visual guidelines

- **Background**
  - Use `DefaultPageBackground` globally (already in `main.dart` builder).
  - Individual `Scaffold` instances should keep `backgroundColor: Colors.transparent`.

- **Cards & surfaces**
  - White or near‑white with subtle radius (16–24).
  - Soft shadows for primary interaction cards; borders for secondary lists.

- **Typography**
  - Section headings: 12–14 pt, **all caps**, letter spacing 1–1.5, grey or purple.
  - Body text: 13–15 pt, dark text color from `AppColors.textPrimary`.

- **Actions**
  - Primary: filled in `AppColors.primaryElectric` or `AppColors.primaryTeal`.
  - Secondary: outlined using same color (border + text).

Use this document as the **single source of truth** for match‑related UI updates. Any new widget or screen in the create‑match / scoring flow should visually align with these patterns. 

