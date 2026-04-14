extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


func _run() -> void:
	var level_scene: PackedScene = load("res://levels/00_forest/level_b.tscn")
	var level = level_scene.instantiate()
	level.level_data = LevelData.build().set_last_level(GameScreen.Level_Number.Level_A)
	root.add_child(level)
	await process_frame

	var entry_side: int = level.get_entry_transition_side()
	if entry_side != LevelTransition.SIDE.LEFT:
		print("ASSERT FAIL: expected Level_B entry side from Level_A to be LEFT, got %s" % [entry_side])
	else:
		print("ASSERT PASS: level resolves entry side from previous level")

	var effect_scene: PackedScene = load("res://sences/game_screen/screen_effect.tscn")
	var effect = effect_scene.instantiate()
	root.add_child(effect)
	await process_frame

	effect.fade_duration = 0.01
	var mask: ColorRect = effect.get_mask()
	var viewport_size: Vector2 = effect.get_viewport().get_visible_rect().size

	effect.fade_in(LevelTransition.SIDE.RIGHT)
	if mask.position != Vector2(viewport_size.x, 0.0):
		print("ASSERT FAIL: fade_in should start off-screen on the right, got %s" % [mask.position])
	else:
		print("ASSERT PASS: fade_in starts from the requested side")

	await create_timer(0.05).timeout
	if mask.position != Vector2.ZERO:
		print("ASSERT FAIL: fade_in should end fully covering the screen, got %s" % [mask.position])
	else:
		print("ASSERT PASS: fade_in ends at full cover")

	effect.fade_out(LevelTransition.SIDE.LEFT)
	await create_timer(0.05).timeout
	if mask.position != Vector2(-viewport_size.x, 0.0):
		print("ASSERT FAIL: fade_out from LEFT should reveal from the left and exit to the left, got %s" % [mask.position])
	else:
		print("ASSERT PASS: fade_out reveals from the requested side")

	effect.fade_in(LevelTransition.SIDE.INIT)
	if mask.position != Vector2.ZERO:
		print("ASSERT FAIL: fade_in INIT should not start from an edge, got %s" % [mask.position])
	elif not is_equal_approx(mask.modulate.a, 0.0):
		print("ASSERT FAIL: fade_in INIT should begin from transparent black, got alpha %s" % [mask.modulate.a])
	else:
		print("ASSERT PASS: fade_in INIT uses alpha fade")

	await create_timer(0.05).timeout
	if not is_equal_approx(mask.modulate.a, 1.0):
		print("ASSERT FAIL: fade_in INIT should end at alpha 1.0, got %s" % [mask.modulate.a])
	else:
		print("ASSERT PASS: fade_in INIT finishes opaque")

	effect.fade_out(LevelTransition.SIDE.INIT)
	if mask.position != Vector2.ZERO:
		print("ASSERT FAIL: fade_out INIT should stay centered, got %s" % [mask.position])
	elif not is_equal_approx(mask.modulate.a, 1.0):
		print("ASSERT FAIL: fade_out INIT should start opaque, got alpha %s" % [mask.modulate.a])
	else:
		print("ASSERT PASS: fade_out INIT starts as an alpha fade")

	await create_timer(0.05).timeout
	if not is_equal_approx(mask.modulate.a, 0.0):
		print("ASSERT FAIL: fade_out INIT should end at alpha 0.0, got %s" % [mask.modulate.a])
	else:
		print("ASSERT PASS: fade_out INIT finishes transparent")

	_done = true
