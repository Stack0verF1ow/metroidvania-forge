extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证进入 TitleScreen 时会清理上一场景遗留的 BGM，
## 同时再次播放同一首曲目时也能正常重新开始。
func _run() -> void:
	var audio = root.get_node_or_null("Audio")
	if audio == null:
		print("ASSERT FAIL: Audio autoload should exist in the scene tree")
		_done = true
		return
	await process_frame

	var track := load("res://music/forest_01.ogg") as AudioStream
	audio.play_music(track)
	await process_frame
	await process_frame

	var title_scene := load("res://sences/title_screen/title_screen.tscn") as PackedScene
	var title_screen = title_scene.instantiate()
	root.add_child(title_screen)
	await process_frame
	await process_frame

	if audio.music_1.playing or audio.music_2.playing:
		print("ASSERT FAIL: entering TitleScreen should stop the previous gameplay music")
		title_screen.queue_free()
		_done = true
		return

	audio.play_music(track)
	await process_frame
	await process_frame

	if not audio.music_1.playing and not audio.music_2.playing:
		print("ASSERT FAIL: the same music track should be replayable after TitleScreen stops it")
	else:
		print("ASSERT PASS: TitleScreen clears old BGM and the same track can be replayed")

	title_screen.queue_free()
	audio.music_1.stop()
	audio.music_2.stop()
	_done = true
