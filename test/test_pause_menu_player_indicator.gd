extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证重新打开暂停菜单时，PlayerIndicator 会按当前玩家位置刷新到正确的缩略图坐标，
## 而不是停留在 PauseMenu 初次实例化时的旧位置。
func _run() -> void:
	var game_manager = root.get_node_or_null("GameManager")
	if game_manager == null:
		print("ASSERT FAIL: GameManager autoload should exist in the scene tree")
		_done = true
		return

	var level_bounds := _get_level_bounds_for(GameScreen.Level_Number.Level_B)
	if level_bounds.is_empty():
		print("ASSERT FAIL: expected level_b to provide LevelBounds")
		_done = true
		return

	var level_origin: Vector2 = level_bounds.origin
	var level_size: Vector2 = level_bounds.size
	var first_player_position := level_origin + Vector2(level_size.x * 0.25, level_size.y * 0.25)
	var second_player_position := level_origin + Vector2(level_size.x * 0.75, level_size.y * 0.6)

	game_manager.current_run = RunTime.create_new()
	game_manager.current_run.level_num = GameScreen.Level_Number.Level_B
	if not game_manager.current_run.discovered_areas.has(GameScreen.Level_Number.Level_B):
		game_manager.current_run.discovered_areas.append(GameScreen.Level_Number.Level_B)
	game_manager.current_run.player_position = first_player_position

	var pause_menu_scene := load("res://sences/pause_screen/pause_menu.tscn") as PackedScene
	var pause_menu = pause_menu_scene.instantiate() as PauseMenu
	root.add_child(pause_menu)
	await process_frame

	var indicator = pause_menu.get_node("PauseMenu/Map/PlayerIndicator") as Control
	var map_node_b = pause_menu.get_node("PauseMenu/Map/MapNode2") as MapNode
	var first_expected: Vector2 = map_node_b.position + (first_player_position - level_origin) / map_node_b.SCALE_FACTOR

	if not indicator.visible:
		print("ASSERT FAIL: PlayerIndicator should be visible for the current level")
		pause_menu.free()
		_done = true
		return
	elif not _is_vector_close(indicator.position, first_expected):
		print("ASSERT FAIL: initial PlayerIndicator position mismatch, got %s expected %s" % [indicator.position, first_expected])
		pause_menu.free()
		_done = true
		return

	pause_menu.visible = false
	game_manager.current_run.player_position = second_player_position
	pause_menu.visible = true
	pause_menu.show_pause_menu()
	await process_frame

	var second_expected: Vector2 = map_node_b.position + (second_player_position - level_origin) / map_node_b.SCALE_FACTOR
	if not _is_vector_close(indicator.position, second_expected):
		print("ASSERT FAIL: reopening PauseMenu should refresh PlayerIndicator position, got %s expected %s" % [indicator.position, second_expected])
	elif _is_vector_close(indicator.position, first_expected):
		print("ASSERT FAIL: PlayerIndicator stayed at the stale position after reopening PauseMenu")
	else:
		print("ASSERT PASS: opening PauseMenu refreshes PlayerIndicator to the latest player position")

	pause_menu.free()
	_done = true


## 加载目标关卡并提取 LevelBounds，供测试计算玩家世界坐标与缩略图坐标的对应关系。
func _get_level_bounds_for(level: GameScreen.Level_Number) -> Dictionary:
	var level_scene := LevelFactory.new().get_level_scene(level)
	var level_instance = level_scene.instantiate()
	var level_bounds := _find_level_bounds(level_instance)
	var level_bounds_data := {}
	if level_bounds != null:
		level_bounds_data = {
			"origin": level_bounds.global_position,
			"size": Vector2(level_bounds.width, level_bounds.height),
		}
	level_instance.free()
	return level_bounds_data


## 递归查找关卡中的 LevelBounds，保持和运行时代码一致的边界来源。
func _find_level_bounds(node: Node) -> LevelBounds:
	if node is LevelBounds:
		return node as LevelBounds

	for child in node.get_children():
		var level_bounds := _find_level_bounds(child)
		if level_bounds != null:
			return level_bounds

	return null


## 用近似比较判断两个坐标是否一致，避免浮点缩放后的微小误差影响测试结果。
func _is_vector_close(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
