extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证 Switch.unique_name() 会返回祖父节点名和父节点名的组合，
## 供 persistent_data 在读档时稳定命中对应机关状态。
func _run() -> void:
	var game_manager = root.get_node_or_null("GameManager")
	if game_manager == null:
		print("ASSERT FAIL: GameManager autoload should exist in the scene tree")
		_done = true
		return

	game_manager.current_run = RunTime.create_new()

	var level := Node2D.new()
	level.name = "Level_A"
	var door := Node2D.new()
	door.name = "Door"
	var switch_scene := load("res://sences/Door/switch.tscn") as PackedScene
	var switch_node = switch_scene.instantiate() as Switch
	level.add_child(door)
	door.add_child(switch_node)
	root.add_child(level)
	await process_frame

	var expected_name := "Level_A_Door"

	if switch_node == null:
		print("ASSERT FAIL: expected the test hierarchy to contain a Switch")
	elif switch_node.unique_name() != expected_name:
		print("ASSERT FAIL: Switch.unique_name() should return %s, got %s" % [expected_name, switch_node.unique_name()])
	else:
		print("ASSERT PASS: Switch.unique_name() combines the level name and door name")

	level.free()
	_done = true
