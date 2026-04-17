extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证暂停菜单里的 SFX 预览走的是普通总线预览，
## 而不是受距离和监听器影响的空间音效播放器。
func _run() -> void:
	var audio = root.get_node_or_null("Audio")
	if audio == null:
		print("ASSERT FAIL: Audio autoload should exist in the scene tree")
		_done = true
		return
	await process_frame

	var player := Node2D.new()
	player.name = "PreviewPlayer"
	player.position = Vector2(128, 64)
	player.add_to_group("Player")
	root.add_child(player)

	var pause_menu_scene := load("res://sences/pause_screen/pause_menu.tscn") as PackedScene
	var pause_menu = pause_menu_scene.instantiate() as PauseMenu
	root.add_child(pause_menu)
	await process_frame

	pause_menu._on_sfx_slider_changed(0.35)
	await process_frame

	var preview_player := _get_sfx_preview_player(audio)
	var spatial_player_count := _count_spatial_sfx_players(audio)

	if spatial_player_count > 0:
		print("ASSERT FAIL: pause menu SFX preview should not create AudioStreamPlayer2D nodes")
	elif preview_player == null:
		print("ASSERT FAIL: pause menu SFX preview should use a plain AudioStreamPlayer on the SFX bus")
	elif not preview_player.playing:
		print("ASSERT FAIL: pause menu SFX preview player should be actively playing the test sound")
	else:
		print("ASSERT PASS: pause menu SFX preview uses a non-spatial player on the SFX bus")

	pause_menu.queue_free()
	player.queue_free()
	_done = true


## 只提取真正给暂停菜单做预览的普通播放器，
## 排除已有的 Music1、Music2、UI 等常驻播放器。
func _get_sfx_preview_player(audio: Node) -> AudioStreamPlayer:
	for child in audio.get_children():
		if child is AudioStreamPlayer and child.bus == "SFX":
			return child
	return null


## 统计暂停菜单预览期间是否错误地产生了 AudioStreamPlayer2D。
func _count_spatial_sfx_players(audio: Node) -> int:
	var count := 0
	for child in audio.get_children():
		if child is AudioStreamPlayer2D and child.bus == "SFX":
			count += 1
	return count
