Goal
- 排查并修复当前音频系统在暂停、切回 TitleScreen、以及音效音量上的异常行为。

Targets
- `00_global/audio/audio.gd`
- `sences/pause_screen/pause_menu.gd`
- `sences/game_screen/game_screen.gd`
- `sences/title_screen/title_screen.gd`
- `project.godot`
- `default_bus_layout.tres`
- `test/test_audio_*.gd`

Constraints
- 先定位根因，再做最小修复。
- 不回退用户已有改动。
- 注释保持中文风格，与现有项目一致。

Assets
- 使用本地 Godot CLI：`d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`。

Verify
- 暂停游戏时，预期的音乐播放状态正确。
- 切回 TitleScreen 后，不会残留 GameScreen 的音乐。
- 音乐、SFX、UI 音量和 PauseMenu 滑杆一致。
- 项目 headless 校验通过，并新增最小复现测试覆盖问题。

Latest user feedback
- 我现在的audio系统有一些bug，比如暂停的时候music不播放，切回TitleScreen的时候，music还会播放，播放的音效音量也是异常的，请帮我排查一下
