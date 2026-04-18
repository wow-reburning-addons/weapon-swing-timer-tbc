# Ace3 Migration Plan (Plan 1)

Target: move WeaponSwingTimer to Ace3 infrastructure gradually, while keeping the existing per-character saved variables and 2.4.3 behavior.

## Phase 1 - Bootstrap and Core Wiring

- [x] Add embedded Ace3 libs to `WeaponSwingTimer.toc`.
- [x] Convert core bootstrap to `AceAddon-3.0` lifecycle (`OnInitialize`/`OnEnable`).
- [x] Move event registration to `AceEvent-3.0` callbacks.
- [x] Move slash commands to `AceConsole-3.0` (`/wst`, `/weaponswingtimer`).
- [x] Keep legacy data model (`character_*_settings`) unchanged.
- [x] Use legacy (2.4.3-style) combat-log payload only.

## Phase 2 - AceConfig Bridge (No Data Migration)

- [ ] Introduce an `AceConfig` options table that reads/writes existing `character_*_settings`.
- [ ] Register options via `AceConfig-3.0` + `AceConfigDialog-3.0` and add to Blizzard Interface Options.
- [ ] Preserve the current settings semantics and default/reset behavior.
- [ ] Keep old config panel callable during transition, then retire it once parity is complete.

## Phase 3 - Cleanup and Parity Validation

- [ ] Remove duplicate UI paths after AceConfig reaches parity.
- [ ] Smoke-test in-game: melee bars (player/target), hunter/wand timer, castbar pushback, and `/wst` config open.
- [ ] Confirm no regression in 2.4.3-oriented event and combat-log handling.

## Explicit Non-Goals for Plan 1

- No migration to `AceDB-3.0` in this plan.
- No saved-variable schema rename in this plan.
- No replacement of combat logic modules (`Player`, `Target`, `Hunter`, `Castbar`) unless needed for event API adaptation.
