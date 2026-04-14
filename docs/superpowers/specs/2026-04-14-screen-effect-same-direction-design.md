# ScreenEffect Same-Direction Design

## Goal

把 `ScreenEffect.fade_in()` 和 `fade_out()` 的方向语义统一成同一个 `transition_dir`，并抽取重复逻辑。

## Design

- `LevelTransition.SIDE.INIT` 继续表示首屏或无方向的 alpha 淡变。
- 对于四个普通方向，`transition_dir` 始终表示遮罩运动的方向。
- `fade_in(dir)` 从 `dir` 对应的屏幕外位置滑到 `Vector2.ZERO`。
- `fade_out(dir)` 从 `Vector2.ZERO` 滑到 `dir` 对应的屏幕外位置。
- 方向位移由一个共享 helper 计算，`fade_in/fade_out` 只决定起点、终点和 alpha 初值。
- 删除“反方向”推导逻辑，避免语义绕弯。

## Testing

- 更新 headless harness，使其断言 `fade_out(LEFT)` 最终到 `Vector2(-viewport_size.x, 0)`。
- 保留 `INIT` 分支的 alpha fade 验证。
