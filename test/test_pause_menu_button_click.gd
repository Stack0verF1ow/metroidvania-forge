extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 在暂停状态下模拟点击 SystemMenuButton，验证系统菜单是否能被正常打开。
func _run() -> void:
	var pause_menu_scene := load("res://sences/pause_screen/pause_menu.tscn") as PackedScene
	var pause_menu = pause_menu_scene.instantiate()
	root.add_child(pause_menu)
	await process_frame

	var menu_script = pause_menu as PauseMenu
	menu_script.visible = true
	menu_script.show_pause_menu()
	paused = true
	await process_frame

	var button = pause_menu.get_node("%SystemMenuButton") as Button
	var system = pause_menu.get_node("%System") as Control
	var pause_menu_panel = pause_menu.get_node("%PauseMenu") as Control
	var button_center := button.get_global_rect().get_center()
	var pressed_count := 0
	button.pressed.connect(func() -> void:
		pressed_count += 1
	)

	if not pause_menu.can_process():
		print("ASSERT FAIL: pause menu root cannot process while paused")
		paused = false
		_done = true
		return

	if not button.can_process():
		print("ASSERT FAIL: SystemMenuButton cannot process while paused")
		paused = false
		_done = true
		return

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = button_center
	Input.parse_input_event(press)
	await process_frame

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = button_center
	Input.parse_input_event(release)
	await process_frame

	if pressed_count == 0:
		pause_menu_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		system.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		await process_frame

		Input.parse_input_event(press)
		await process_frame
		Input.parse_input_event(release)
		await process_frame

		if pressed_count == 0:
			print("ASSERT FAIL: simulated click never emitted the button pressed signal, even after forcing WHEN_PAUSED")
		else:
			print("ASSERT FAIL: button only works after forcing explicit WHEN_PAUSED on menu controls")
	elif not system.visible:
		print("ASSERT FAIL: clicking SystemMenuButton while paused should show the system panel")
	else:
		print("ASSERT PASS: SystemMenuButton opens the system panel while paused")

	paused = false
	_done = true
