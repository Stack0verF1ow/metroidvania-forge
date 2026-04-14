class_name ScreenEffect
extends CanvasLayer

@export_range(0.01, 2.0, 0.01, "or_greater") var fade_duration: float = 0.25
@export_range(0.01, 2.0, 0.01, "or_greater") var first_load_duration: float = 0.35
@export var fade_color: Color = Color.BLACK

@onready var fade_layer: Control = %FadeLayer
@onready var mask: ColorRect = %Mask

var _active_tween: Tween = null


# 初始化全屏遮罩，并在窗口尺寸变化时保持布局同步。
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_layout()
	get_viewport().size_changed.connect(_update_layout)
	_hide_mask()


# 暴露遮罩节点给测试脚本，方便直接断言位置和尺寸。
func get_mask() -> ColorRect:
	return mask


# 处理第一次进入游戏时的效果：只需要从黑屏简单淡出即可。
func first_load() -> void:
	_stop_active_tween()
	_prepare_mask()
	mask.position = Vector2.ZERO
	mask.modulate.a = 1.0
	_active_tween = create_tween()
	_active_tween.tween_property(mask, "modulate:a", 0.0, first_load_duration)
	await _active_tween.finished
	mask.visible = false


# 切图前先把屏幕盖住；如果有方向，就让遮罩沿该方向滑入屏幕。
func fade_in(direction: int = LevelTransition.SIDE.INIT) -> void:
	await _run_transition(direction, _get_edge_position(direction), Vector2.ZERO, 0.0, 1.0)

# 切图后揭示新关卡；如果有方向，就让遮罩沿同一方向滑出屏幕。
func fade_out(direction: int = LevelTransition.SIDE.INIT) -> void:
	await _run_transition(direction, Vector2.ZERO, _get_edge_position(direction), 1.0, 0.0)
	mask.visible = false


# 抽取两种过渡的公共逻辑：准备遮罩、创建 tween，并按 INIT 或方向位移分支执行。
func _run_transition(
	direction: int,
	start_position: Vector2,
	end_position: Vector2,
	start_alpha: float,
	end_alpha: float
) -> Signal:
	_stop_active_tween()
	_prepare_mask()

	if direction == LevelTransition.SIDE.INIT:
		mask.position = Vector2.ZERO
		mask.modulate.a = start_alpha
		_active_tween = create_tween()
		_active_tween.tween_property(mask, "modulate:a", end_alpha, fade_duration)
	else:
		mask.position = start_position
		mask.modulate.a = 1.0
		_active_tween = create_tween()
		_active_tween.tween_property(mask, ^"position", end_position, fade_duration)

	return _active_tween.finished


# 在播放动画前，先保证遮罩可见、尺寸正确、颜色正确。
func _prepare_mask() -> void:
	_update_layout()
	mask.visible = true
	mask.color = fade_color


# 把遮罩恢复到默认的“隐藏且静止”状态。
func _hide_mask() -> void:
	mask.visible = false
	mask.position = Vector2.ZERO
	mask.modulate.a = 0.0


# 让遮罩尺寸始终匹配视口，并限制它只在一个屏幕范围内移动。
func _update_layout() -> void:
	if fade_layer == null or mask == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	mask.position = mask.position.clamp(Vector2(-viewport_size.x, -viewport_size.y), Vector2(viewport_size.x, viewport_size.y))
	mask.size = viewport_size


# 把方向转换成对应的屏幕边缘位置；fade_in 和 fade_out 只是在起点终点上互换。
func _get_edge_position(direction: int) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	match direction:
		LevelTransition.SIDE.LEFT:
			return Vector2(-viewport_size.x, 0.0)
		LevelTransition.SIDE.RIGHT:
			return Vector2(viewport_size.x, 0.0)
		LevelTransition.SIDE.TOP:
			return Vector2(0.0, -viewport_size.y)
		LevelTransition.SIDE.BOTTOM:
			return Vector2(0.0, viewport_size.y)
	return Vector2.ZERO


# 防止上一个 tween 还没结束时，又启动新的转场动画，导致互相抢状态。
func _stop_active_tween() -> void:
	if _active_tween != null and is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
