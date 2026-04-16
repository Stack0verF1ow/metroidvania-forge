# Map Node Preview Cache Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cache each MapNode's level-origin metadata during preview generation so reopening PauseMenu can reposition PlayerIndicator without reloading the level scene.

**Architecture:** Keep preview-data ownership inside `MapNode`. `update_node()` computes and stores the level origin once, while `display_player_location()` consumes only cached preview metadata plus current player position. `PauseMenu` remains the refresh trigger and does not learn level-bound details.

**Tech Stack:** Godot 4.5, GDScript, SceneTree headless tests.

---

### Task 1: Lock the optimization behavior with a failing test

**Files:**
- Modify: `test/test_pause_menu_player_indicator.gd`

- [ ] **Step 1: Write the failing test**

```gdscript
map_node_b.level_factory.level_paths.erase(GameScreen.Level_Number.Level_B)
pause_menu.show_pause_menu()
await process_frame
if not indicator.visible:
    print("ASSERT FAIL: PlayerIndicator should still refresh from cached preview data")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script res://test/test_pause_menu_player_indicator.gd`
Expected: FAIL because `display_player_location()` still tries to instantiate the level scene.

- [ ] **Step 3: Write minimal implementation**

```gdscript
var cached_level_origin: Vector2 = Vector2.ZERO
var has_cached_level_origin: bool = false
```

- [ ] **Step 4: Run test to verify it passes**

Run: `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script res://test/test_pause_menu_player_indicator.gd`
Expected: PASS with the cached preview path.

- [ ] **Step 5: Commit**

```bash
git add test/test_pause_menu_player_indicator.gd sences/pause_screen/map_node.gd sences/pause_screen/pause_menu.gd CURRENT_TASK.md docs/superpowers/plans/2026-04-16-map-node-preview-cache.md
git commit -m "refactor: cache map node preview origin"
```

### Task 2: Re-run focused regressions

**Files:**
- Test: `test/test_map_node_preview.gd`
- Test: `test/test_map_node_visibility.gd`

- [ ] **Step 1: Run focused regressions**

```bash
d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script res://test/test_map_node_preview.gd
d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --script res://test/test_map_node_visibility.gd
d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe --headless --quit
```

- [ ] **Step 2: Verify outputs stay clean**

Expected: All tests print only `ASSERT PASS` lines and headless quit reports no parse errors.

- [ ] **Step 3: Commit**

```bash
git add sences/pause_screen/map_node.gd test/test_pause_menu_player_indicator.gd
git commit -m "test: cover cached map indicator positioning"
```
