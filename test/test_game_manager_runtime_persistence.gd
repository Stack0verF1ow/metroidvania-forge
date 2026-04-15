extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


func _run() -> void:
	var save_path := "user://test_runtime_persistence.sav"
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	var game_manager = root.get_node_or_null("GameManager")
	if game_manager == null:
		print("ASSERT FAIL: GameManager autoload should exist in the scene tree")
		_done = true
		return

	game_manager.current_run = RunTime.create_new()
	game_manager.set_current_level(GameScreen.Level_Number.Level_B)
	game_manager.set_current_level(GameScreen.Level_Number.Level_B)

	var level_b_count := 0
	for area in game_manager.current_run.discovered_areas:
		if area == GameScreen.Level_Number.Level_B:
			level_b_count += 1

	if game_manager.current_run.level_num != GameScreen.Level_Number.Level_B:
		print("ASSERT FAIL: set_current_level should update the runtime level")
		_done = true
		return
	elif level_b_count != 1:
		print("ASSERT FAIL: set_current_level should not duplicate discovered areas, got %s copies" % [level_b_count])
		_done = true
		return
	print("ASSERT PASS: GameManager keeps runtime level tracking consistent")

	var runtime := RunTime.new()
	runtime.level_num = GameScreen.Level_Number.Level_C
	runtime.player_position = Vector2(128.0, 256.0)
	runtime.hp = 13.0
	runtime.max_hp = 18.0
	runtime.dash = true
	runtime.double_jump = true
	runtime.ground_slam = false
	runtime.morph_roll = true
	runtime.discovered_areas = [
		GameScreen.Level_Number.Level_A,
		GameScreen.Level_Number.Level_C,
	]
	runtime.persistent_data = {
		"opened_gate": true,
		"boss_hp": 7,
	}

	var saved := DataManager.save_runtime(runtime, save_path)
	if not saved:
		print("ASSERT FAIL: save_runtime should report success")
		_done = true
		return

	if not FileAccess.file_exists(save_path):
		print("ASSERT FAIL: save_runtime should create a save file")
		_done = true
		return
	print("ASSERT PASS: save_runtime writes the runtime file")

	var loaded := DataManager.load_runtime(save_path)
	if loaded == null:
		print("ASSERT FAIL: load_runtime should return a runtime")
		_done = true
		return

	if loaded.level_num != runtime.level_num:
		print("ASSERT FAIL: loaded level_num mismatch, got %s" % [loaded.level_num])
	elif loaded.player_position != runtime.player_position:
		print("ASSERT FAIL: loaded player_position mismatch, got %s" % [loaded.player_position])
	elif not is_equal_approx(loaded.hp, runtime.hp):
		print("ASSERT FAIL: loaded hp mismatch, got %s" % [loaded.hp])
	elif not is_equal_approx(loaded.max_hp, runtime.max_hp):
		print("ASSERT FAIL: loaded max_hp mismatch, got %s" % [loaded.max_hp])
	elif loaded.dash != runtime.dash:
		print("ASSERT FAIL: loaded dash mismatch, got %s" % [loaded.dash])
	elif loaded.double_jump != runtime.double_jump:
		print("ASSERT FAIL: loaded double_jump mismatch, got %s" % [loaded.double_jump])
	elif loaded.ground_slam != runtime.ground_slam:
		print("ASSERT FAIL: loaded ground_slam mismatch, got %s" % [loaded.ground_slam])
	elif loaded.morph_roll != runtime.morph_roll:
		print("ASSERT FAIL: loaded morph_roll mismatch, got %s" % [loaded.morph_roll])
	elif loaded.discovered_areas != runtime.discovered_areas:
		print("ASSERT FAIL: loaded discovered_areas mismatch, got %s" % [loaded.discovered_areas])
	elif loaded.persistent_data.get("opened_gate") != runtime.persistent_data.get("opened_gate"):
		print("ASSERT FAIL: loaded persistent_data bool mismatch, got %s" % [loaded.persistent_data])
	elif int(loaded.persistent_data.get("boss_hp", -1)) != int(runtime.persistent_data.get("boss_hp", -1)):
		print("ASSERT FAIL: loaded persistent_data number mismatch, got %s" % [loaded.persistent_data])
	else:
		print("ASSERT PASS: load_runtime restores every runtime field")

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	_done = true
