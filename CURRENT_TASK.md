Goal
- Migrate save/load ownership so runtime save state lives in `GameManager.current_run`, while `DataManager` exposes static functions that only read and write persisted data.

Targets
- `00_global/game_manager.gd`
- `00_global/run_time.gd`
- `utils/data_manager.gd`
- `sences/game_screen/game_screen.gd`
- `test/test_game_manager_runtime_persistence.gd`

Constraints
- Keep the current Godot autoload structure centered on `GameManager`.
- Move existing save data fields into the runtime model instead of keeping duplicate mutable state in `DataManager`.
- `DataManager` should become a pure static persistence helper.
- Do not revert unrelated user changes.

Assets
- Use the local Godot CLI at `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`.

Verify
- Saving serializes the current runtime state from `GameManager.current_run`.
- Loading returns runtime data back into `GameManager.current_run`.
- `set_current_level()` updates the runtime level and discovered areas without duplicate tracking bugs.
- Godot headless validation and the new persistence test both run.

Latest user feedback
- 我想将要保存的数据存在game_manager的runtime里，data_manager的函数设置为静态函数，负责存取数据，请帮我完成对应函数的迁移及修改
