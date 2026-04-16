extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证 MapNode 能从真实关卡场景提取缩略尺寸和四边入口，并在切换场景时清掉旧入口块。
func _run() -> void:
	var map_node_scene := load("res://sences/pause_screen/map_node.tscn") as PackedScene
	var map_node = map_node_scene.instantiate() as MapNode
	var transition_blocks = map_node.get_node("%TransitionBlocks") as Control

	map_node.linked_scene = "res://levels/00_forest/level_b.tscn"
	map_node.update_node()

	if map_node.size != Vector2(23, 9):
		print("ASSERT FAIL: level_b preview size should be Vector2(23, 9), got %s" % [map_node.size])
		_done = true
		return
	elif map_node.entrances_left.size() != 1:
		print("ASSERT FAIL: level_b should expose one left entrance, got %s" % [map_node.entrances_left.size()])
		_done = true
		return
	elif map_node.entrances_bottom.size() != 1:
		print("ASSERT FAIL: level_b should expose one bottom entrance, got %s" % [map_node.entrances_bottom.size()])
		_done = true
		return
	elif map_node.entrances_right.size() != 0 or map_node.entrances_top.size() != 0:
		print("ASSERT FAIL: level_b should not create right/top entrances, got right=%s top=%s" % [map_node.entrances_right.size(), map_node.entrances_top.size()])
		_done = true
		return
	elif transition_blocks.get_child_count() != 2:
		print("ASSERT FAIL: level_b should create two transition blocks, got %s" % [transition_blocks.get_child_count()])
		_done = true
		return

	map_node.linked_scene = "res://levels/00_forest/level_c.tscn"
	map_node.update_node()

	if map_node.entrances_top.size() != 1:
		print("ASSERT FAIL: level_c should expose one top entrance after refresh, got %s" % [map_node.entrances_top.size()])
	elif map_node.entrances_left.size() != 0 or map_node.entrances_right.size() != 0 or map_node.entrances_bottom.size() != 0:
		print("ASSERT FAIL: level_c refresh should clear stale entrances, got left=%s right=%s bottom=%s" % [map_node.entrances_left.size(), map_node.entrances_right.size(), map_node.entrances_bottom.size()])
	elif transition_blocks.get_child_count() != 1:
		print("ASSERT FAIL: level_c refresh should leave one transition block, got %s" % [transition_blocks.get_child_count()])
	else:
		print("ASSERT PASS: MapNode maps top/bottom entrances using the room-edge positions correctly")

	map_node.free()
	_done = true
