Goal
- 排查并修复进入 Level_B / Level_C 后暂停菜单中对应 MapNode 不显示的问题。

Targets
- `sences/pause_screen/map_node.gd`
- `sences/pause_screen/pause_menu.gd`
- `00_global/game_manager.gd`
- `sences/game_screen/game_screen.gd`
- `test/test_map_node_visibility.gd`

Constraints
- 保持依赖方向为 `MapNode -> GameScreen -> LevelFactory`。
- 不回退用户已有改动。
- 先定位根因，再做最小修复。
- 注释保持中文风格，与现有项目一致。

Assets
- 使用本地 Godot CLI：`d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`。

Verify
- 初始只发现 Level_A 时，Level_B / Level_C 的 MapNode 默认隐藏。
- 调用切换到 Level_B / Level_C 后，对应 MapNode 会刷新为可见。
- 项目 headless 校验通过。
- 新增测试可复现并覆盖该行为。

Latest user feedback
- 为什么我进入到level_b、c的时候，看不到对应的MapNode？请帮我排查一下
