# WeaponSwingTimer Development Notes

## Pending behavior decision: ranged bar before first shot

Context:
- Current logic uses `attack_mode` (`none`, `melee`, `ranged`) to avoid showing melee and ranged bars at the same time.
- In some cases, with `display_condition = out_of_melee`, the ranged bar does not appear until the player starts shooting.
- This happens when range detection is uncertain before first shot and `attack_mode` is still `none`.

Observed case:
- Target is valid and attackable.
- Player is not in melee distance.
- Melee bar behavior is acceptable.
- Ranged bar is hidden until the first auto-shot event.

Planned improvement:
1. Keep `attack_mode` gating to prevent double display.
2. Add pre-shot visibility path for ranged bar when `display_condition = out_of_melee`:
   - If target is confirmed not in melee range, show ranged bar even when `attack_mode = none`.
   - If target is in melee range, hide ranged bar.
   - If melee-range check is unknown (`nil`), try ranged spell range check (`IsSpellInRange` with Auto Shot/Shoot where possible).
3. Define explicit fallback for unknown range check result:
   - Option A (recommended): show ranged bar when target is valid hostile.
   - Option B: keep ranged bar hidden until first actual ranged event.

Open decision:
- User preference currently points to Option A (show ranged before first shot when clearly out of melee range).

Verification checklist after implementation:
- No target + out of combat: bars respect display conditions, no overlap spam.
- Valid hostile target in melee: melee bar can show, ranged bar does not.
- Valid hostile target out of melee, before first shot: ranged bar appears as expected.
- During active ranged combat: melee bar stays hidden.
- During active melee combat: ranged bar stays hidden.
