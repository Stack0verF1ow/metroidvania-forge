Goal
- 完善 Switch.unique_name()，让它返回“父节点的父节点名 + 父节点 Door 名”的组合，用于 persistent_data 的稳定 key。

Targets
- `sences/Door/switch.gd`
- `test/test_switch_unique_name.gd`

Constraints
- 不改函数名，仍然使用 `unique_name()`。
- 组合规则按用户要求：父节点的父节点名 + 父节点名。
- 不回退用户已有改动。
- 注释保持中文风格。

Assets
- 使用本地 Godot CLI：`d:/metroidvania-forge/Godot_v4.5.1-stable_win64_console.exe`。

Verify
- Switch 在正常层级下能返回由祖父节点名和父节点名组成的字符串。
- 该结果可直接用作 persistent_data 的 key。
- 项目 headless 校验通过。

Latest user feedback
- 不用改名，我希望这个函数返回的是“父节点的父节点名 + 父节点 Door 名 ”的组合，请帮我完善unique_name()
