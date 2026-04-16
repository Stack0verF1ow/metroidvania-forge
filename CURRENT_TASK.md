Goal
- 完善并优化 MapNode，使其能够根据 linked_scene 正确显示缩略关卡尺寸与四边出口。

Targets
- `sences/pause_screen/map_node.gd`
- `test/test_map_node_preview.gd`

Constraints
- 保持现有 MapNode 的外部用法不变，包括 `linked_scene`、`Update` 按钮和四组入口数组。
- 优先沿用现有关卡场景中的 `LevelBounds` 与 `LevelTransition` 数据，不额外发明地图配置格式。
- 不回退用户的其他改动。

Assets
- 使用本地 Godot CLI：`d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`。

Verify
- MapNode 能从真实关卡场景读取正确的缩略尺寸。
- MapNode 能显示 left/right/top/bottom 四边的入口块。
- 切换不同 linked_scene 后，旧入口块会被正确清理。
- 项目 headless 校验通过。

Latest user feedback
- 请帮我完善并优化MapNode的代码，使其能正确显示缩略的关卡
