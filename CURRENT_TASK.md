Goal
- Route slot selection from `TitleScreen` to `GameScreen` through `ScreenData`, so new game and load game both initialize the correct runtime before gameplay starts.

Targets
- `sences/screen/screen_data.gd`
- `sences/title_screen/title_screen.gd`
- `sences/game_screen/game_screen.gd`
- `00_global/game_manager.gd`

Constraints
- Trigger save creation and loading after `GameScreen` is created, not directly in `TitleScreen`.
- Pass only screen-transition intent through `ScreenData`.
- Remove temporary test artifacts after verification.
- Do not revert unrelated user changes.

Assets
- Use the local Godot CLI at `d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`.

Verify
- `TitleScreen` sends both slot and enter mode through `ScreenData`.
- `GameScreen` decides whether to create a new save or load an existing save based on `screen_data`.
- `GameManager` keeps the active slot consistent for save/load.
- Headless validation passes after temporary tests are removed.

Latest user feedback
- player的数据状态应该由game_manager而不是game_screen来应用到player上，我已经修改好了，现在我遇到一个问题，如何通过Screen_data从Title_screen选的存档，到Game_screen正确加载
- 请帮我改完，注意测试完后将测试相关的代码删掉
