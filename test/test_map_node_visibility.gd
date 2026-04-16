extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证暂停菜单中的 MapNode 会在发现新区域后及时刷新显示状态，
## 避免只在首次进入树时读取一次 discovered_areas 导致后续关卡始终不可见。
func _run() -> void:
	var game_manager = root.get_node_or_null("GameManager")
	if game_manager == null:
		print("ASSERT FAIL: GameManager autoload should exist in the scene tree")
		_done = true
		return

	game_manager.current_run = RunTime.create_new()

	var pause_menu_scene := load("res://sences/pause_screen/pause_menu.tscn") as PackedScene
	var pause_menu = pause_menu_scene.instantiate()
	root.add_child(pause_menu)
	await process_frame

	var map_node_b = pause_menu.get_node("PauseMenu/Map/MapNode2") as MapNode
	var map_node_c = pause_menu.get_node("PauseMenu/Map/MapNode4") as MapNode

	if map_node_b.visible:
		print("ASSERT FAIL: level_b MapNode should be hidden before discovery")
		pause_menu.free()
		_done = true
		return
	elif map_node_c.visible:
		print("ASSERT FAIL: level_c MapNode should be hidden before discovery")
		pause_menu.free()
		_done = true
		return

	game_manager.set_current_level(GameScreen.Level_Number.Level_B)
	await process_frame

	if not game_manager.is_area_discovered(GameScreen.Level_Number.Level_B):
		print("ASSERT FAIL: GameManager should mark level_b as discovered after set_current_level")
		pause_menu.free()
		_done = true
		return
	elif not map_node_b.visible:
		print("ASSERT FAIL: level_b MapNode should become visible after discovery")
		pause_menu.free()
		_done = true
		return
	elif map_node_c.visible:
		print("ASSERT FAIL: level_c MapNode should stay hidden before its own discovery")
		pause_menu.free()
		_done = true
		return

	game_manager.set_current_level(GameScreen.Level_Number.Level_C)
	await process_frame

	if not game_manager.is_area_discovered(GameScreen.Level_Number.Level_C):
		print("ASSERT FAIL: GameManager should mark level_c as discovered after set_current_level")
	elif not map_node_b.visible:
		print("ASSERT FAIL: level_b MapNode should stay visible after other areas are discovered")
	elif not map_node_c.visible:
		print("ASSERT FAIL: level_c MapNode should become visible after discovery")
	else:
		print("ASSERT PASS: PauseMenu MapNodes refresh visibility after discovered areas change")

	pause_menu.free()
	_done = true
