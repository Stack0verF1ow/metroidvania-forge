extends Node

enum REVERB_TYPE {
	NONE,
	SMALL,
	MEDIUM,
	LARGE,
}

enum Sound {
	UI_FOCUS,
	UI_SELECT,
	UI_CANCEL,
	UI_SUCCESS,
	UI_ERROR,
}

const BUS_EFFECT_PASS := &"EffectPass"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"
const BUS_UI := &"UI"

const UI_MAP : Dictionary[Sound, AudioStream] = {
	Sound.UI_FOCUS : preload("res://00_global/audio/ui_audio/ui_bloop_audio.wav"),
	Sound.UI_SELECT : preload("res://00_global/audio/ui_audio/ui_select_audio.wav"),
	Sound.UI_CANCEL : preload("res://00_global/audio/ui_audio/ui_woosh.wav"),
	Sound.UI_SUCCESS : preload("res://00_global/audio/ui_audio/ui_success_audio.wav"),
	Sound.UI_ERROR : preload("res://00_global/audio/ui_audio/ui_error_audio.wav"),
}

var current_track : int = 0
var music_tweens : Array[Tween] = []
var ui_audio_player : AudioStreamPlaybackPolyphonic
var sfx_preview_player : AudioStreamPlayer

@onready var music_1: AudioStreamPlayer = $Music1
@onready var music_2: AudioStreamPlayer = $Music2
@onready var ui: AudioStreamPlayer = $UI


## 初始化全局音频节点。
## 这里强制让根节点在暂停时继续处理，保证 BGM 淡入淡出和菜单预览不被 SceneTree.paused 一并挂起。
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_1.volume_linear = 0.0
	music_2.volume_linear = 0.0
	ui.play()
	ui_audio_player = ui.get_stream_playback()
	_ensure_sfx_preview_player()


## 通过 UI 的多复音播放器播放一条界面音效，避免频繁实例化新节点。
func _play_ui_audio(audio: AudioStream) -> void:
	if ui_audio_player:
		ui_audio_player.play_stream(audio)


## 按预定义的 UI 音效枚举播放界面反馈音。
func play_ui(sound: Sound) -> void:
	_play_ui_audio(UI_MAP[sound])


## 播放新的 BGM。
## 同一首且仍在播放时直接复用；否则切到另一条播放器并做淡入淡出。
func play_music(audio: AudioStream) -> void:
	if audio == null:
		stop_music()
		return

	var current_player : AudioStreamPlayer = get_music_player(current_track)
	if current_player != null and current_player.stream == audio and current_player.playing:
		return

	var next_track : int = wrapi(current_track + 1, 0, 2)
	var next_player : AudioStreamPlayer = get_music_player(next_track)
	if next_player == null:
		return

	_kill_music_tweens()
	next_player.stream = audio
	next_player.volume_linear = 0.0
	next_player.play()

	fade_track_out(current_player)
	fade_track_in(next_player)

	current_track = next_track


## 返回当前索引对应的音乐播放器。
## 音乐系统只保留两路播放器，轮流承担当前曲目和下一首曲目的交叉淡化。
func get_music_player(i: int) -> AudioStreamPlayer:
	if i == 0:
		return music_1
	return music_2


## 停止全部 BGM，并清空播放器状态。
## 这样切回 Title 后不会残留旧曲目，也能确保同一首歌之后还能被重新播放。
func stop_music() -> void:
	_kill_music_tweens()
	_reset_music_player(music_1)
	_reset_music_player(music_2)
	current_track = 0


## 把当前曲目淡出到静音并在结束时停播。
## 只有播放器真的处于播放状态时才需要做淡出，避免空播放器也创建无意义 Tween。
func fade_track_out(player: AudioStreamPlayer) -> void:
	if player == null or not player.playing:
		return

	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 0.0, 1.5)
	tween.tween_callback(_finalize_fade_out.bind(player))


## 把新曲目从静音淡入到目标音量。
func fade_track_in(player: AudioStreamPlayer) -> void:
	if player == null:
		return

	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 1.0, 1.0)


## 播放带空间位置的场景音效。
## 这类音效应该跟随游戏暂停，因此显式设为 PAUSABLE，避免继承到全局音频节点的 ALWAYS 行为。
func play_spatial_sound(audio: AudioStream, pos: Vector2) -> void:
	if audio == null:
		return

	var ap : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(ap)
	ap.bus = BUS_SFX
	ap.process_mode = Node.PROCESS_MODE_PAUSABLE
	ap.stream = audio
	ap.position = pos
	ap.finished.connect(ap.queue_free)
	ap.play()


## 播放暂停菜单等全局界面的 SFX 预览。
## 这里故意不用空间音效，避免预览音量被距离、监听器和相机位置影响。
func play_sfx_preview(audio: AudioStream) -> void:
	if audio == null:
		return

	_ensure_sfx_preview_player()
	sfx_preview_player.stop()
	sfx_preview_player.stream = audio
	sfx_preview_player.play()


## 根据场景需求切换混响强度。
func set_reverb(type: REVERB_TYPE) -> void:
	var reverb_fx : AudioEffectReverb = AudioServer.get_bus_effect(1, 0)
	if not reverb_fx:
		return

	AudioServer.set_bus_effect_enabled(1, 0, true)
	match type:
		REVERB_TYPE.NONE:
			AudioServer.set_bus_effect_enabled(1, 0, false)
		REVERB_TYPE.SMALL:
			reverb_fx.room_size = 0.2
		REVERB_TYPE.MEDIUM:
			reverb_fx.room_size = 0.5
		REVERB_TYPE.LARGE:
			reverb_fx.room_size = 0.8


## 创建并缓存一个常驻的 SFX 预览播放器。
## 这样暂停菜单每次调音量都只复用同一个节点，不会在 Audio 下不断堆临时播放器。
func _ensure_sfx_preview_player() -> void:
	if is_instance_valid(sfx_preview_player):
		return

	sfx_preview_player = AudioStreamPlayer.new()
	sfx_preview_player.name = "SFXPreview"
	sfx_preview_player.bus = BUS_SFX
	sfx_preview_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_preview_player)


## 结束旧曲目的淡出流程，并把音量保持在静音状态，方便下一次复用时从 0 开始淡入。
func _finalize_fade_out(player: AudioStreamPlayer) -> void:
	if player == null:
		return

	player.stop()
	player.volume_linear = 0.0


## 统一停止并清空一条音乐播放器的状态。
func _reset_music_player(player: AudioStreamPlayer) -> void:
	if player == null:
		return

	player.stop()
	player.stream = null
	player.volume_linear = 0.0


## 清理仍然存活的音乐 Tween，避免旧的淡出淡入继续修改新的播放状态。
func _kill_music_tweens() -> void:
	for tween in music_tweens:
		if is_instance_valid(tween):
			tween.kill()
	music_tweens.clear()
