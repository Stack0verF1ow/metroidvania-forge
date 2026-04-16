@tool
@icon("res://assets/ch_03_game_systems/icons/map_node.svg")

class_name MapNode
extends Control

@export var linked_level: GameScreen.Level_Number = GameScreen.Level_Number.Level_A:
	set(value):
		if linked_level == value:
			return

		linked_level = value
		if Engine.is_editor_hint():
			update_node()

@export_tool_button("Update") var update_node_button = update_node

@export var entrances_top: Array[float] = []
@export var entrances_right: Array[float] = []
@export var entrances_bottom: Array[float] = []
@export var entrances_left: Array[float] = []

@onready var label: Label = %Label
@onready var transition_blocks: Control = %TransitionBlocks

const SCALE_FACTOR: float = 40.0
const DEFAULT_LEVEL_SIZE := Vector2(480.0, 270.0)
const EDGE_PADDING: float = 2.0
const BLOCK_THICKNESS: float = 1.0
const BLOCK_LENGTH: float = 3.0

var level_factory := LevelFactory.new()


## 初始化缩略关卡节点，并在进入树后立刻按 linked_level 刷新预览数据。
func _ready() -> void:
	update_node()

	if label != null:
		label.visible = Engine.is_editor_hint()

	_connect_game_manager_signal()
	refresh_discovery_visibility()


## 在节点进入树后订阅 GameManager 的探索状态变化，
## 这样切关或读档后不需要重新创建暂停菜单也能刷新当前节点显示状态。
func _exit_tree() -> void:
	_disconnect_game_manager_signal()

## 从关卡场景中读取边界和出口数据，并同步到当前缩略图节点。
func update_node() -> void:
	var level_size := DEFAULT_LEVEL_SIZE
	var level_origin := Vector2.ZERO
	var transitions: Array[LevelTransition] = []
	var scene_instance = _instantiate_linked_scene()

	if scene_instance != null:
		_update_node_label(scene_instance)

		var level_bounds := _find_level_bounds(scene_instance)
		if level_bounds != null:
			level_size = Vector2(level_bounds.width, level_bounds.height)
			level_origin = level_bounds.global_position

		transitions = _collect_level_transitions(scene_instance)
	else:
		_update_node_label(null)

	_apply_preview_size(level_size)
	create_entrance_data(transitions, level_origin)
	if scene_instance != null:
		scene_instance.free()
	create_transition_blocks()


## 通过 LevelFactory 把关卡编号解析成场景并实例化；失败时返回 null。
func _instantiate_linked_scene() -> Node:
	if not level_factory.level_paths.has(linked_level):
		return null

	var level_scene := level_factory.get_level_scene(linked_level)
	if level_scene == null:
		return null

	return level_scene.instantiate()


## 把关卡实际尺寸按统一比例缩放到暂停菜单用的缩略尺寸。
func _apply_preview_size(level_size: Vector2) -> void:
	size = (level_size / SCALE_FACTOR).round()
	custom_minimum_size = size


## 更新编辑器里显示的关卡名称，方便摆放和排查链接是否正确。
func _update_node_label(scene: Node) -> void:
	if label == null:
		label = get_node_or_null("%Label")
	if label == null:
		return

	if scene == null:
		label.text = "unlinked"
		return

	var scene_path := scene.scene_file_path
	scene_path = scene_path.replace("res://levels/", "")
	scene_path = scene_path.replace(".tscn", "")
	label.text = scene_path


## 递归查找关卡中的 LevelBounds，用它作为缩略图尺寸和坐标系基准。
func _find_level_bounds(node: Node) -> LevelBounds:
	if node is LevelBounds:
		return node as LevelBounds

	for child in node.get_children():
		var level_bounds := _find_level_bounds(child)
		if level_bounds != null:
			return level_bounds

	return null


## 递归收集关卡中的全部 LevelTransition，避免只扫根节点时漏掉容器里的出口。
func _collect_level_transitions(node: Node) -> Array[LevelTransition]:
	var transitions: Array[LevelTransition] = []
	_collect_level_transitions_recursive(node, transitions)
	return transitions


## 深度遍历节点树，把所有 LevelTransition 追加到结果数组中。
func _collect_level_transitions_recursive(node: Node, transitions: Array[LevelTransition]) -> void:
	for child in node.get_children():
		if child is LevelTransition:
			transitions.append(child as LevelTransition)

		_collect_level_transitions_recursive(child, transitions)


## 把关卡出口换算成缩略图四边上的偏移量，供后续入口块绘制使用。
func create_entrance_data(transitions: Array[LevelTransition], level_origin: Vector2) -> void:
	entrances_bottom.clear()
	entrances_left.clear()
	entrances_right.clear()
	entrances_top.clear()

	for transition in transitions:
		var local_position := transition.global_position - level_origin

		match transition.location:
			LevelTransition.SIDE.LEFT:
				entrances_left.append(_clamp_vertical_offset(local_position.y / SCALE_FACTOR))
			LevelTransition.SIDE.RIGHT:
				entrances_right.append(_clamp_vertical_offset(local_position.y / SCALE_FACTOR))
			LevelTransition.SIDE.TOP:
				entrances_bottom.append(_clamp_horizontal_offset(local_position.x / SCALE_FACTOR))
			LevelTransition.SIDE.BOTTOM:
				entrances_top.append(_clamp_horizontal_offset(local_position.x / SCALE_FACTOR))


## 重新生成四边的入口块，保证 linked_level 刷新后不会残留旧出口。
func create_transition_blocks() -> void:
	if transition_blocks == null:
		transition_blocks = get_node_or_null("%TransitionBlocks")
	if transition_blocks == null:
		return

	for child in transition_blocks.get_children():
		child.free()

	for offset in entrances_left:
		_add_vertical_block(offset, 0.0)

	for offset in entrances_right:
		_add_vertical_block(offset, maxf(0.0, size.x - BLOCK_THICKNESS))

	for offset in entrances_top:
		_add_horizontal_block(offset, 0.0)

	for offset in entrances_bottom:
		_add_horizontal_block(offset, maxf(0.0, size.y - BLOCK_THICKNESS))


## 在左边或右边绘制一个竖向入口块，长度固定，只改变纵向位置。
func _add_vertical_block(offset: float, x_position: float) -> void:
	var block := _add_block()
	block.size = Vector2(BLOCK_THICKNESS, BLOCK_LENGTH)
	block.position = Vector2(
		x_position,
		clampf(offset - (BLOCK_LENGTH * 0.5), 0.0, maxf(0.0, size.y - BLOCK_LENGTH))
	)


## 在上边或下边绘制一个横向入口块，长度固定，只改变横向位置。
func _add_horizontal_block(offset: float, y_position: float) -> void:
	var block := _add_block()
	block.size = Vector2(BLOCK_LENGTH, BLOCK_THICKNESS)
	block.position = Vector2(
		clampf(offset - (BLOCK_LENGTH * 0.5), 0.0, maxf(0.0, size.x - BLOCK_LENGTH)),
		y_position
	)


## 创建入口块节点，并统一设置为不参与输入的纯显示元素。
func _add_block() -> ColorRect:
	var block := ColorRect.new()
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_blocks.add_child(block)
	return block


## 把竖向入口偏移限制在可见范围内，避免入口块超出房间边界。
func _clamp_vertical_offset(offset: float) -> float:
	return clampf(offset, EDGE_PADDING, maxf(EDGE_PADDING, size.y - EDGE_PADDING))


## 把横向入口偏移限制在可见范围内，避免入口块超出房间边界。
func _clamp_horizontal_offset(offset: float) -> float:
	return clampf(offset, EDGE_PADDING, maxf(EDGE_PADDING, size.x - EDGE_PADDING))


## 按当前运行时已发现的区域列表刷新节点显示状态；
## 编辑器里始终显示，避免摆放暂停地图时看不到节点。
func refresh_discovery_visibility() -> void:
	if Engine.is_editor_hint():
		visible = true
		return

	var game_manager := _get_game_manager()
	if game_manager == null:
		return

	visible = game_manager.is_area_discovered(linked_level)


func display_player_location() -> void:
	var game_manager := _get_game_manager()
	if game_manager == null:
		return
	if game_manager.current_run == null:
		return
	if game_manager.current_run.level_num != linked_level:
		return

	var player_indicator := _get_player_indicator()
	if player_indicator == null:
		return

	var scene_instance = _instantiate_linked_scene()
	if scene_instance == null:
		return

	var level_bounds := _find_level_bounds(scene_instance)
	if level_bounds == null:
		scene_instance.free()
		return

	var player_world_position := _get_player_world_position(game_manager)
	var player_local_position := player_world_position - level_bounds.global_position
	var preview_position := Vector2(
		clampf(player_local_position.x / SCALE_FACTOR, 0.0, size.x),
		clampf(player_local_position.y / SCALE_FACTOR, 0.0, size.y)
	)

	player_indicator.position = position + preview_position
	player_indicator.visible = true
	scene_instance.free()


## 统一从场景树获取自动加载的 GameManager，避免脚本直接依赖全局名解析。
func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")


## 获取暂停地图上的共享玩家指示器；
## 它和各个 MapNode 是兄弟节点，因此需要从父节点上查找。
func _get_player_indicator() -> Control:
	var map_root := get_parent()
	if map_root == null:
		return null

	return map_root.get_node_or_null("PlayerIndicator") as Control


## 优先读取场景内真实玩家的位置，保证打开暂停菜单时使用的是最新坐标；
## 若当前测试或特殊场景中没有玩家节点，则回退到运行时存档里的 player_position。
func _get_player_world_position(game_manager: Node) -> Vector2:
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		return player.global_position

	return game_manager.current_run.player_position


## 连接 GameManager 的探索状态变化信号，避免 discovered_areas 更新后当前节点仍停留在旧显示状态。
func _connect_game_manager_signal() -> void:
	var game_manager := _get_game_manager()
	if game_manager == null:
		return

	if not game_manager.is_connected("discovered_areas_changed", _on_discovered_areas_changed):
		game_manager.connect("discovered_areas_changed", _on_discovered_areas_changed)


## 在节点离树时断开信号，避免旧的 MapNode 实例残留回调。
func _disconnect_game_manager_signal() -> void:
	var game_manager := _get_game_manager()
	if game_manager == null:
		return

	if game_manager.is_connected("discovered_areas_changed", _on_discovered_areas_changed):
		game_manager.disconnect("discovered_areas_changed", _on_discovered_areas_changed)


## 收到探索区域变化后重新计算当前缩略节点是否可见。
func _on_discovered_areas_changed() -> void:
	refresh_discovery_visibility()
