# Directional Screen Effect Design

## Goal

为 `ScreenEffect` 增加带方向的关卡转场效果，并让方向参数直接来自 `LevelTransition`。

## Scope

- 修正 `Level -> GameScreen` 的关卡切换参数链路，确保离开方向能正确传到特效层。
- 在 `Level` 中提供“根据上一关查找当前入口方向”的能力，供新关卡 `fade_out` 使用。
- 在 `ScreenEffect` 中实现方向驱动的遮罩动画，并保留 `first_load()` 的初次加载表现。

## Design

### Transition data flow

- `LevelTransition.location` 继续作为唯一方向来源。
- 玩家触发关卡切换时，`Level` 发出 `level_transition_requested(new_level, transition_side, data)`。
- `GameScreen` 在卸载旧关卡前使用 `transition_side` 执行 `fade_in()`。
- 新关卡加入场景树并完成初始化后，`GameScreen` 通过新关卡中“目标为上一关”的入口 `LevelTransition` 取得入口方向，并执行 `fade_out()`。

### ScreenEffect behavior

- `ScreenEffect` 使用一个铺满视口的黑色遮罩节点。
- `fade_in(direction)` 表示遮罩从 `direction` 对应边缘滑入，直到完全遮住屏幕。
- `fade_out(direction)` 表示从 `direction` 对应边缘开始揭示新场景，因此遮罩会向该方向的反方向滑出屏幕。
- `first_load()` 维持独立逻辑，只做简单初次淡出，不依赖关卡方向。

### Error handling

- 如果当前关卡找不到入口方向，`fade_out()` 回退到无方向的立即隐藏，不阻塞切换。
- 初次加载使用 `NO_DIRECTION` 常量，避免与正常切场混淆。

### Testing

- 为 `Level` 增加针对入口方向查询的验证。
- 为 `ScreenEffect` 增加针对 `fade_in/fade_out` 方向位移的验证。
- 运行项目级 Godot 解析校验，确保信号签名和脚本引用没有回归。
