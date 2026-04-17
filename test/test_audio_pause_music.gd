extends SceneTree

var _done: bool = false


func _initialize() -> void:
	await _run()


func _process(_delta: float) -> bool:
	return _done


## 验证进入暂停后，Audio 自动加载节点和当前音乐播放器仍然可以继续处理，
## 这样 BGM 才不会因为暂停整棵树而被一并挂起。
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

	var active_player := _get_active_music_player(audio)
	paused = true
	await process_frame

	if active_player == null:
		print("ASSERT FAIL: play_music() should leave one music player in the playing state")
	elif not audio.can_process():
		print("ASSERT FAIL: Audio autoload should keep processing while the tree is paused")
	elif not active_player.can_process():
		print("ASSERT FAIL: active music player should keep processing while the tree is paused")
	elif not active_player.playing:
		print("ASSERT FAIL: active music player should still be playing after the tree is paused")
	else:
		print("ASSERT PASS: music keeps processing and playing while the tree is paused")

	paused = false
	audio.music_1.stop()
	audio.music_2.stop()
	_done = true


## 读取当前正在播放的音乐播放器，避免测试依赖内部轮换到哪一路。
func _get_active_music_player(audio: Node) -> AudioStreamPlayer:
	if audio.music_1.playing:
		return audio.music_1
	if audio.music_2.playing:
		return audio.music_2
	return null
