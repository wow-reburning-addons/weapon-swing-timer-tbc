# AGENTS.md

## Scope and Target
- This repo is a WoW addon (`WeaponSwingTimer`) loaded directly by the client; there is no build/lint/test pipeline in-repo.
- Project constraint: adapt this internet-sourced addon for WoW **2.4.3** compatibility; prefer 2.4.3 API/event behavior over modern Classic/Retail helpers.

## Source of Truth
- Load order is defined in `WeaponSwingTimer.toc`; keep dependency order intact when adding files:
  `localization.lua -> WeaponSwingTimer_ranged_DB.lua -> Utils -> Player -> Target -> Castbar -> Hunter -> Config -> Core`.
- `WeaponSwingTimer_Core.lua` is the event hub/entrypoint: registers events on `ADDON_LOADED`, then dispatches to module handlers.

## Runtime Architecture (What To Touch)
- Player melee logic: `WeaponSwingTimer_Player.lua`.
- Target melee logic: `WeaponSwingTimer_Target.lua`.
- Hunter/wand shot timer logic: `WeaponSwingTimer_Hunter.lua`.
- Aimed/Multi castbar and pushback logic: `WeaponSwingTimer_Castbar.lua`.
- Shared helpers and chat output: `WeaponSwingTimer_Utils.lua`.
- Localized strings are centralized in `localization.lua` (`L[...]` table); do not hardcode user-facing text in module files.

## Compatibility Hotspots for 2.4.3 Porting
- Combat log parsing currently depends on `CombatLogGetCurrentEventInfo()` in `WeaponSwingTimer_Core.lua`; this is a likely incompatibility point for 2.4.3 clients.
- Combat handlers in `Player/Target/Hunter/Castbar` unpack modern combat-log tuple layouts; if event payload shape changes, update all four together.
- `.toc` currently declares `## Interface: 20502`; keep interface value aligned with the actual target client build you run.

## Data and State Gotchas
- Per-character saved variable names are fixed in `WeaponSwingTimer.toc`; preserve names to avoid wiping user settings.
- Hunter speed math depends on `addon_data.ranged_DB.item_ids[weaponID].base_speed` from `WeaponSwingTimer_ranged_DB.lua`; guard unknown/unsupported item IDs when touching this path.
- Config UI is opened via slash commands `/wst`, `/weaponswingtimer`, `/WeaponSwingTimer` (wired in `WeaponSwingTimer_Core.lua`).

## Verification (Manual Only)
- Install/update folder under `Interface/AddOns/WeaponSwingTimer`, then `/reload` in-game.
- Smoke test: melee bar (player + target), hunter/wand bar, castbar pushback, and config panel open via `/wst`.
