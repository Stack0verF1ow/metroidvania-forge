extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证暂停菜单在场景层级和鼠标过滤上不会被 HUD 这类全屏展示层挡住。
func _run() -> void:
	var pause_menu_scene := load("res://sences/pause_screen/pause_menu.tscn") as PackedScene
	var player_hud_scene := load("res://sences/player_hud/player_hud.tscn") as PackedScene

	var pause_menu = pause_menu_scene.instantiate()
	var player_hud = player_hud_scene.instantiate()
	root.add_child(player_hud)
	root.add_child(pause_menu)
	await process_frame

	var overlay = pause_menu.get_node("Control") as Control
	var dim_rect = pause_menu.get_node("Control/ColorRect") as ColorRect
	var top_bar = pause_menu.get_node("Control/ColorRect2") as ColorRect
	var pause_menu_panel = pause_menu.get_node("%PauseMenu") as Control
	var map_panel = pause_menu.get_node("PauseMenu/Map") as Control
	var system_panel = pause_menu.get_node("%System") as Control
	var player_hud_root = player_hud.get_node("Control") as Control
	var failures: Array[String] = []

	if overlay.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		failures.append("ASSERT FAIL: overlay Control should ignore mouse input, got %s" % [overlay.mouse_filter])
	if dim_rect.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		failures.append("ASSERT FAIL: dim ColorRect should ignore mouse input, got %s" % [dim_rect.mouse_filter])
	if top_bar.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		failures.append("ASSERT FAIL: top bar ColorRect should ignore mouse input, got %s" % [top_bar.mouse_filter])
	if pause_menu_panel.mouse_filter != Control.MOUSE_FILTER_PASS:
		failures.append("ASSERT FAIL: pause menu panel should pass mouse input to child buttons, got %s" % [pause_menu_panel.mouse_filter])
	if map_panel.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		failures.append("ASSERT FAIL: map panel should ignore mouse input until it has interactions, got %s" % [map_panel.mouse_filter])
	if system_panel.mouse_filter != Control.MOUSE_FILTER_PASS:
		failures.append("ASSERT FAIL: system panel should pass mouse input to its child controls, got %s" % [system_panel.mouse_filter])
	if player_hud.layer >= pause_menu.layer:
		failures.append("ASSERT FAIL: pause menu CanvasLayer should be above PlayerHud, got pause=%s hud=%s" % [pause_menu.layer, player_hud.layer])
	if player_hud_root.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		failures.append("ASSERT FAIL: player HUD root Control should ignore mouse input, got %s" % [player_hud_root.mouse_filter])

	if failures.is_empty():
		print("ASSERT PASS: pause menu sits above HUD and its non-interactive layers do not block clicks")
	else:
		for failure in failures:
			print(failure)

	_done = true
