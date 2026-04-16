extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证暂停状态下触发返回标题信号后，界面能够切回 TitleScreen 且树恢复为未暂停。
func _run() -> void:
	var emo_game_scene := load("res://sences/screen/emo_game.tscn") as PackedScene
	var emo_game = emo_game_scene.instantiate() as EmoGame
	root.add_child(emo_game)
	await process_frame

	emo_game.switch_screen(EmoGame.ScreenType.GAME_SCREEN)
	await process_frame
	await process_frame

	if not emo_game.current_screen is GameScreen:
		print("ASSERT FAIL: expected EmoGame to enter GameScreen before back-to-title test")
		_done = true
		return

	var messages = root.get_node_or_null("Messages")
	if messages == null:
		print("ASSERT FAIL: Messages autoload should exist in the scene tree")
		_done = true
		return

	paused = true
	messages.emit_signal("back_to_title")
	await process_frame
	await process_frame

	if not emo_game.current_screen is TitleScreen:
		print("ASSERT FAIL: back-to-title signal should switch the current screen to TitleScreen")
	elif paused:
		print("ASSERT FAIL: back-to-title flow should clear the paused state before showing TitleScreen")
	else:
		print("ASSERT PASS: paused back-to-title flow lands on TitleScreen and resumes the tree")

	paused = false
	_done = true
