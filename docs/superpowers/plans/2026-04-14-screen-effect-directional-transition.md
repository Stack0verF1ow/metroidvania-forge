# Screen Effect Directional Transition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add directional level transition effects to `ScreenEffect` and wire the direction from `LevelTransition`.

**Architecture:** Extend the level-switch signal path so the exiting `LevelTransition.location` reaches `GameScreen`, then let the destination `Level` resolve its entry-side transition for the reveal animation. Keep `ScreenEffect` focused on animating a full-screen mask and keep initial load behavior separate.

**Tech Stack:** Godot 4.5, GDScript, headless SceneTree harness

---

### Task 1: Lock the intended behavior with failing tests

**Files:**
- Create: `test/test_screen_effect_directional_transition.gd`
- Test: `test/test_screen_effect_directional_transition.gd`

- [ ] **Step 1: Write the failing test**

```gdscript
extends SceneTree

func _initialize() -> void:
    var level_scene: PackedScene = load("res://levels/00_forest/level_b.tscn")
    var level = level_scene.instantiate()
    level.level_data = LevelData.build().set_last_level(GameScreen.Level_Number.Level_A)
    root.add_child(level)
    await root.process_frame
    var side = level.get_entry_transition_side()
    if side != LevelTransition.SIDE.LEFT:
        print("ASSERT FAIL: expected Level_B entry side from Level_A to be LEFT, got %s" % [side])

    var effect_scene: PackedScene = load("res://sences/game_screen/screen_effect.tscn")
    var effect = effect_scene.instantiate()
    root.add_child(effect)
    await root.process_frame
    effect.fade_duration = 0.01
    effect.fade_in(LevelTransition.SIDE.RIGHT)
    var mask = effect.get_mask()
    var viewport_size = effect.get_viewport().get_visible_rect().size
    if mask.position != Vector2(viewport_size.x, 0.0):
        print("ASSERT FAIL: fade_in should start off-screen on the right, got %s" % [mask.position])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `godot --headless --script test/test_screen_effect_directional_transition.gd`
Expected: fail because `Level.get_entry_transition_side()` and `ScreenEffect.get_mask()` do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```gdscript
func get_entry_transition_side() -> int:
    for child in level_transitions.get_children():
        if child.target_level == level_data.last_level:
            return child.location
    return -1
```

```gdscript
func get_mask() -> ColorRect:
    return mask
```

- [ ] **Step 4: Run test to verify it passes**

Run: `godot --headless --script test/test_screen_effect_directional_transition.gd`
Expected: no `ASSERT FAIL` output for the initial assertions.

- [ ] **Step 5: Commit**

```bash
git add test/test_screen_effect_directional_transition.gd levels/level.gd sences/game_screen/screen_effect.gd
git commit -m "test: cover directional screen transition"
```

### Task 2: Wire directional transition flow through the level switch

**Files:**
- Modify: `levels/level.gd`
- Modify: `sences/level_transition/level_transition.gd`
- Modify: `sences/game_screen/game_screen.gd`
- Modify: `sences/game_screen/screen_effect.gd`
- Modify: `sences/game_screen/screen_effect.tscn`
- Test: `test/test_screen_effect_directional_transition.gd`

- [ ] **Step 1: Write the failing integration assertions**

```gdscript
effect.fade_out(LevelTransition.SIDE.LEFT)
await root.process_frame
await root.process_frame
if mask.position == Vector2.ZERO:
    print("ASSERT FAIL: fade_out should move the mask away from the full-cover position")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `godot --headless --script test/test_screen_effect_directional_transition.gd`
Expected: fail because `fade_out()` and the transition signal path still do not drive directional movement.

- [ ] **Step 3: Write minimal implementation**

```gdscript
signal level_transition_requested(new_level: GameScreen.Level_Number, transition_side: int, data: LevelData)

func _on_player_went_out(target_level: GameScreen.Level_Number, relative_pos: Vector2, transition_side: int) -> void:
    level_data = level_data.set_last_level(level_name).set_relative_position(relative_pos)
    transiton_level(target_level, transition_side, level_data)
```

```gdscript
func switch_Level(level: Level_Number, transition_side: int = ScreenEffect.NO_DIRECTION, data: LevelData = LevelData.new()) -> void:
    _switch_level_async(level, transition_side, data)
```

- [ ] **Step 4: Run test and project validation**

Run: `godot --headless --script test/test_screen_effect_directional_transition.gd`
Expected: no `ASSERT FAIL` output.

Run: `godot --headless --quit`
Expected: project exits without script parse errors.

- [ ] **Step 5: Commit**

```bash
git add levels/level.gd sences/level_transition/level_transition.gd sences/game_screen/game_screen.gd sences/game_screen/screen_effect.gd sences/game_screen/screen_effect.tscn test/test_screen_effect_directional_transition.gd
git commit -m "feat: add directional screen transition effect"
```
