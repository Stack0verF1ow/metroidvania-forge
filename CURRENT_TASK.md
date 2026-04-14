Goal
- Refactor `ScreenEffect` so `fade_in` and `fade_out` share the same directional transition logic and no longer compute an opposite direction.

Targets
- `sences/game_screen/screen_effect.gd`
- `test/test_screen_effect_directional_transition.gd`
- `docs/superpowers/specs/2026-04-14-screen-effect-same-direction-design.md`
- `docs/superpowers/plans/2026-04-14-screen-effect-same-direction.md`

Constraints
- Work directly on the current `main` branch as requested.
- Keep `LevelTransition.SIDE.INIT` as the only non-directional sentinel.
- `fade_in` and `fade_out` should both use the same `transition_dir`; only their start/end states differ.
- Do not revert unrelated user changes.

Assets
- Use the local Godot CLI at `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`.

Verify
- The directional harness expects `fade_out(LEFT)` to move the mask off the left edge, not the right.
- `ScreenEffect` no longer computes or calls an opposite-direction helper.
- The updated harness passes with the local Godot CLI.

Latest user feedback
- ScreenEffect中的fade_in和fade_out只是过渡的方向不同，可以把重复的代码提取出来，只用一个transition_dir就行，不用再获取transition_dir的反向
- 直接在 main 上改
