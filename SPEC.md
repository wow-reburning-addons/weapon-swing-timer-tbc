# WeaponSwingTimer Ideal Specification (WoW 2.4.3)

## 1) Purpose and Scope

WeaponSwingTimer tracks and displays combat timing bars for:

- Player melee swings (main-hand and off-hand)
- Target melee swings (main-hand and off-hand)
- Ranged/wand shot cycle (Auto Shot / Shoot)
- Hunter castbar for Aimed Shot and Multi-Shot, including pushback and latency overlay

Target platform is WoW TBC 2.4.3 behavior. Compatibility with 2.4.3 APIs and event payloads has priority.

## 2) Core Runtime Architecture

- `WeaponSwingTimer_Core.lua` is the event hub and lifecycle entrypoint.
- Load order follows `WeaponSwingTimer.toc`:
  `localization.lua -> WeaponSwingTimer_ranged_DB.lua -> Utils -> Player -> Target -> Castbar -> Hunter -> Config -> Core`
- Core normalizes combat log payload into a stable `combat_info` object and dispatches to module handlers:
  - `player.OnCombatLogUnfiltered(combat_info)`
  - `target.OnCombatLogUnfiltered(combat_info)`
  - `hunter.OnCombatLogUnfiltered(combat_info)`
  - `castbar.OnCombatLogUnfiltered(combat_info)`

## 3) Lifecycle and Events

### Startup

On `ADDON_LOADED` for this addon:

1. Load all saved settings (core + all modules)
2. Initialize all visuals/frames
3. Register runtime events
4. Reset initial swing/shot timers to neutral state
5. Print welcome message if enabled

### Runtime events

Core must handle at least:

- `PLAYER_REGEN_ENABLED` / `PLAYER_REGEN_DISABLED` for in-combat state
- `PLAYER_TARGET_CHANGED`
- `COMBAT_LOG_EVENT_UNFILTERED`
- `UNIT_INVENTORY_CHANGED`
- `START_AUTOREPEAT_SPELL` / `STOP_AUTOREPEAT_SPELL`
- `UNIT_SPELLCAST_SUCCEEDED`
- `UNIT_SPELLCAST_FAILED`
- `UNIT_SPELLCAST_INTERRUPTED`
- `UNIT_SPELLCAST_FAILED_QUIET`

### Update loop

`OnUpdate` continuously updates timers and visual widths/text/alpha for all enabled modules.

## 4) Player Melee Module

### Functional behavior

- Track main-hand swing timer from player combat events.
- Track off-hand timer when off-hand weapon exists and setting allows it.
- Reset timers on swing result events (`SWING_DAMAGE`, `SWING_MISSED`) with miss-type logic.
- Apply parry haste behavior through shared miss handler.
- Support spell-driven swing resets via class spell whitelist.
- On weapon speed changes, scale remaining timer proportionally.

### Visual behavior

- Show/hide module by `enabled`.
- Respect `fill_empty` mode.
- Show or hide off-hand section based on off-hand presence + setting.
- Show sparks only when appropriate (classic bars and non-terminal width).
- Alpha is combat-sensitive (`in_combat_alpha`, `ooc_alpha`).

## 5) Target Melee Module

### Functional behavior

- Active only when `UnitExists("target")`.
- On target change, update target GUID/class and reset timers.
- Reset timers from target combat events equivalent to player logic.
- Apply parry haste and spell reset behavior via core handlers.
- Recompute/scale timers when target attack speed changes.

### Visual behavior

- Hide bar when no valid target.
- Apply independent style/position settings from player bar.

## 6) Hunter/Wand Shot Module

### Functional behavior

- Track ranged cycle using `range_speed`, `auto_cast_time`, `shot_timer`.
- Support both hunter `Auto Shot` and wand `Shoot` behavior.
- Detect auto-repeat start/stop state.
- Handle movement/casting states that delay or re-prime shot cycle.
- Handle relevant spell events (`Auto Shot`, `Aimed Shot`, `Multi-Shot`, `Shoot`, `Feign Death`, etc.).
- Keep shot timing consistent under haste changes.

### Optional overlays/features

- Multi-Shot clip zone indicator.
- Auto-shot delay timer behavior (`FAILED_QUIET` use case).
- One-bar (YaHT-like) and two-phase display modes.

## 7) Castbar Module (Aimed/Multi)

### Functional behavior

- Show cast progress for Aimed Shot and Multi-Shot (controlled by settings).
- Start cast on recognized cast start events.
- Track cast elapsed and completion window.
- Handle pushback from incoming damage while casting.
- Handle success, fail, and interrupt outcomes.

### Visual behavior

- Progress bar fills over cast duration.
- Optional center text and time text.
- Optional latency overlay.
- Fade behavior when not actively casting.

## 8) Configuration and UX

### Slash commands

Addon options must open from:

- `/WeaponSwingTimer`
- `/weaponswingtimer`
- `/wst`

### Configuration panels

- Global panel
  - Lock all bars
  - Welcome message
  - Reset defaults
- Melee panel
  - Player settings
  - Target settings
- Hunter & Wand panel
  - Shot bar settings
  - Castbar settings

### Persistence

Saved variables are per-character and must preserve existing names to avoid user setting loss:

- `character_core_settings`
- `character_player_settings`
- `character_target_settings`
- `character_hunter_settings`
- `character_castbar_settings`

## 9) Localization Rules

- All user-facing strings must come from `localization.lua` (`L[...]`).
- Module files should not hardcode user-facing text.

## 10) Compatibility and Safety Requirements (2.4.3)

### Combat log compatibility

- Must handle both modern and legacy combat-log payload shapes through normalization.
- No runtime error when `CombatLogGetCurrentEventInfo` is unavailable.

### Nil and unknown-data safety

- No Lua errors if API returns nil/0 unexpectedly.
- Unknown ranged weapon IDs must not cause indexing errors in `ranged_DB` lookups.
- Missing unit/item info must degrade gracefully (safe defaults).

### Stability constraints

- No Lua errors during login/reload/combat transitions.
- Bars should never get stuck in impossible visual states.

## 11) Definition of Done (Manual Verification)

After install/update and `/reload`, verify:

1. Player melee bar tracks and resets correctly.
2. Target melee bar appears/disappears with target and tracks correctly.
3. Hunter/wand bar tracks full ranged cycle and responds to movement/casts.
4. Multi-Shot clip bar behavior is coherent with shot timing.
5. Castbar shows Aimed/Multi casts, pushback, and latency (if enabled).
6. Config panel opens via slash command and settings persist across reload.
7. Lock-all-bars and reset-defaults work for all modules.
