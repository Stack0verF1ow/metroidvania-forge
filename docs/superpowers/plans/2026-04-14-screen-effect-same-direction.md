# ScreenEffect Same-Direction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `ScreenEffect` so `fade_in` and `fade_out` share one direction model and no longer compute opposite directions.

**Architecture:** Keep `LevelTransition.SIDE.INIT` as the alpha-fade sentinel, but make the directional branch use one shared screen-edge position helper. `fade_in` uses `edge -> zero`; `fade_out` uses `zero -> edge`.

**Tech Stack:** Godot 4.5, GDScript, headless SceneTree harness

---

### Task 1: Lock the new direction semantics with a failing harness

**Files:**
- Modify: `test/test_screen_effect_directional_transition.gd`
- Test: `test/test_screen_effect_directional_transition.gd`

- [ ] **Step 1: Write the failing assertion**

Change the `fade_out(LevelTransition.SIDE.LEFT)` expectation so it asserts:

```gdscript
if mask.position != Vector2(-viewport_size.x, 0.0):
    print("ASSERT FAIL: fade_out from LEFT should exit to the left, got %s" % [mask.position])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script d:/metroidvania-forge/test/test_screen_effect_directional_transition.gd`
Expected: `ASSERT FAIL` for the `fade_out from LEFT` assertion.

- [ ] **Step 3: Commit**

```bash
git add test/test_screen_effect_directional_transition.gd
git commit -m "test: update screen effect direction semantics"
```

### Task 2: Refactor ScreenEffect to use one direction model

**Files:**
- Modify: `sences/game_screen/screen_effect.gd`
- Test: `test/test_screen_effect_directional_transition.gd`

- [ ] **Step 1: Implement shared directional helper**

Refactor `screen_effect.gd` so:

```gdscript
func fade_in(direction: int = LevelTransition.SIDE.INIT) -> void:
    await _run_transition(direction, _get_edge_position(direction), Vector2.ZERO, 0.0, 1.0)

func fade_out(direction: int = LevelTransition.SIDE.INIT) -> void:
    await _run_transition(direction, Vector2.ZERO, _get_edge_position(direction), 1.0, 0.0)
```

and remove `_get_fade_out_end_position()` plus any opposite-direction call.

- [ ] **Step 2: Run test to verify it passes**

Run: `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script d:/metroidvania-forge/test/test_screen_effect_directional_transition.gd`
Expected: all assertions print `ASSERT PASS`.

- [ ] **Step 3: Run project validation**

Run: `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --quit`
Expected: no new parse or runtime warnings beyond the existing exit-leak issue.

- [ ] **Step 4: Commit**

```bash
git add sences/game_screen/screen_effect.gd test/test_screen_effect_directional_transition.gd
git commit -m "refactor: unify screen effect direction handling"
```
