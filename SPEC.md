# WeaponSwingTimer User Specification (WoW 2.4.3)

## 1) Purpose

WeaponSwingTimer shows timing bars for combat actions so the player can better plan melee swings, ranged shots, and hunter casts.

The addon is intended for WoW TBC 2.4.3 gameplay.

## 2) What the Player Sees

The addon can display up to four visual blocks:

- Player melee swing bar (main-hand, optionally off-hand)
- Target melee swing bar (main-hand, optionally off-hand)
- Hunter/wand shot bar (Auto Shot or Shoot cycle)
- Hunter cast bar for Aimed Shot and Multi-Shot

Each block can be enabled, moved, resized, and styled independently.

## 3) Player Melee Bar

Expected user-facing behavior:

- Shows the current timing of the player's main-hand swing.
- Optionally shows off-hand timing when dual-wielding.
- Resets correctly on successful hits and misses.
- Reacts naturally to combat effects that speed up or delay swings.
- Uses separate combat and out-of-combat transparency values.

## 4) Target Melee Bar

Expected user-facing behavior:

- Appears only when there is a valid target.
- Tracks the target's swing rhythm in real time.
- Resets and recalculates when target context changes.
- Supports its own size, position, colors, and text settings.

## 5) Hunter/Wand Shot Bar

Expected user-facing behavior:

- Tracks the full ranged attack cycle for Auto Shot or Shoot.
- Correctly handles start/stop of auto-repeat attacks.
- Updates when movement or other actions delay the next shot.
- Supports one-bar or two-phase style (depending on user settings).
- Optional clip/delay indicators behave consistently with shot timing.

## 6) Hunter Cast Bar (Aimed/Multi)

Expected user-facing behavior:

- Shows cast progress for Aimed Shot and Multi-Shot.
- Supports interruption, failure, and pushback behavior.
- Optional latency overlay can be shown.
- Optional cast text/time text can be shown.

## 7) Configuration and Commands

The addon settings window opens with:

- `/wst`
- `/weaponswingtimer`

Configuration includes:

- Global options (lock all bars, welcome message, reset defaults)
- Player melee options
- Target melee options
- Hunter/wand shot options
- Hunter cast bar options

## 8) Persistence

User settings persist between sessions and after `/reload`.

Expected result for the player:

- Bar positions remain where they were placed.
- Enabled/disabled states remain unchanged.
- Visual style and behavior options remain unchanged.

## 9) Stability Requirements

From user perspective, addon quality means:

- No visible errors during login, reload, combat, and target switching.
- Bars do not freeze in impossible states.
- Bars hide/show predictably according to settings and combat context.

## 10) Manual Acceptance Checklist

After install/update and `/reload`, verify:

1. Player melee bar tracks and resets correctly.
2. Target melee bar appears/disappears with target and tracks correctly.
3. Hunter/wand bar tracks ranged cycle and reacts to movement/casting delays.
4. Multi-Shot clip and delay indicators are visually coherent.
5. Cast bar handles Aimed/Multi casts, pushback, and interrupts as expected.
6. Settings open from slash commands and persist after reload.
7. Lock all bars and reset defaults work across all visible modules.
