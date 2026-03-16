# Backend ↔ Frontend wiring

This doc summarizes what has **backend support** and what is **wired** so that user input is saved and data is displayed automatically.

## Already had backend + now wired in UI

| Feature | Backend | Frontend wiring |
|--------|---------|------------------|
| **Grounds / locations** | `GET /api/locations` (list), match create accepts `locationName` | **Select Ground** screen loads grounds from `ApiService.listLocations(token)`; Nearby and Search tabs use that list. Selected name is passed to Create Match as venue. Fallback to static list if API fails or no token. |
| **Umpires** | **New** `GET /api/umpire/community` returns profiles with `role = 'umpire'` | **Select Umpire** screen loads from `ApiService.listUmpires(token)`. Fallback to static list on error. Assign toggle is UI-only (no “assign to match” in DB yet). |
| **Live score + commentary** | `PUT /api/umpire/matches/:id/score`, `POST /api/umpire/matches/:id/commentary` | **LIVE tab quick controls** (+1, +2, 4, 6, W, NB, WD, 0.1 over) call `ApiService.updateMatchScore` and `ApiService.addCommentary`, then refresh match details. |

## Already had backend + already wired

- **Create match** – `MatchService.createMatch` → API; venue (ground name) is sent as `locationName`.
- **Match scoreboard** – `ApiService.getMatchScoreboard`; score, teams, venue, **playerStats**, **commentary** all come from API and drive LIVE tab, scorecard, post-match summary.
- **Add players to match** – Squad selection flows into Create Match; `MatchService.addPlayerStat` → `addPlayerToMatch` + `updatePlayerStats`.
- **Post-match summary** – Uses same scoreboard data (winner, scores, MVPs from playerStats); no extra API.

## Not in backend (or UI-only)

- **Favourite grounds** – No API; Favorites tab is placeholder.
- **Assign umpire to match** – No `umpire_id` on matches in DB; Assign switch in Select Umpire is UI-only.
- **Captain / keeper** – Stored only in app (`SquadSelectionResult`); not sent to or stored by backend.

## Summary

- **Inputs that persist:** Create match (teams, venue, overs), add players, update score, add commentary. Ground list and umpire list load from backend; selected ground is sent as venue.
- **Display:** Score header, batter/bowler cards, over timeline, commentary list, scorecard, post-match summary, and MVPs all use data from `getMatchScoreboard` (and score/commentary updated via the quick controls).
