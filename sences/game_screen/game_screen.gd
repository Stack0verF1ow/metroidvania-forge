class_name GameScreen
extends Screen

@onready var screen_effect: ScreenEffect = %ScreenEffect
@onready var pause_menu: PauseMenu = %PauseMenu

enum Level_Number {
	Level_A,
	Level_B,
	Level_C,
}

var current_level: Level = null
var level_factory := LevelFactory.new()


## 初始化游戏界面，并根据 ScreenData 决定是直接进入当前运行态还是先新建/读档。
func _ready() -> void:
	_connect_back_to_title_signal()

	var game_manager = _get_game_manager()
	if game_manager != null:
		game_manager.runtime_loaded.connect(_on_runtime_loaded)
		if _enter_from_screen_data(game_manager):
			return

		switch_level(game_manager.current_run.level_num, LevelTransition.SIDE.INIT)
		return

	switch_level(Level_Number.Level_A, LevelTransition.SIDE.INIT)


## 在界面离开场景树时断开返回标题事件，避免全局消息里残留旧回调。
func _exit_tree() -> void:
	_disconnect_back_to_title_signal()


## 在界面初始化时尽早接上“返回标题”事件，避免被上面的提前 return 跳过。
func _connect_back_to_title_signal() -> void:
	var messages := _get_messages()
	if messages == null:
		return

	if not messages.is_connected("back_to_title", _on_back_to_title):
		messages.connect("back_to_title", _on_back_to_title)


## 在界面销毁前解除“返回标题”事件绑定，防止消息继续发给已离场的 GameScreen。
func _disconnect_back_to_title_signal() -> void:
	var messages := _get_messages()
	if messages == null:
		return

	if messages.is_connected("back_to_title", _on_back_to_title):
		messages.disconnect("back_to_title", _on_back_to_title)


## 提供调试热键，便于直接触发当前槽位的存档和读档流程。
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var game_manager = _get_game_manager()
		if game_manager == null:
			return

		if event.keycode == KEY_F5:
			game_manager.save_game()
		elif event.keycode == KEY_F7:
			game_manager.load_game(game_manager.current_run.current_slot)


## 执行完整切关流程，并把新关卡同步到运行态中。
func switch_level(
	level: Level_Number,
	transition_side: LevelTransition.SIDE = LevelTransition.SIDE.INIT,
	data: LevelData = LevelData.new()
) -> void:
	if current_level != null:
		screen_effect.fade_in(transition_side)
		call_deferred("remove_child", current_level)
		current_level.queue_free()

	current_level = level_factory.get_frush_level(level)
	current_level.setup(self, data)
	current_level.level_transition_requested.connect(switch_level)

	call_deferred("add_child", current_level)
	var game_manager = _get_game_manager()
	if game_manager != null:
		game_manager.set_current_level(level)
	screen_effect.fade_out(transition_side)


## 新游戏或读档流程完成后，按运行态记录切到正确关卡。
func _on_runtime_loaded(new_level_num: Level_Number) -> void:
	switch_level(new_level_num)


## 读取上一界面传来的 ScreenData，并把“新游戏/读档”请求转交给 GameManager。
func _enter_from_screen_data(game_manager: Node) -> bool:
	if screen_data == null:
		return false

	match screen_data.enter_mode:
		ScreenData.EnterMode.NEW_GAME:
			if screen_data.slot < 0:
				return false
			game_manager.create_new_game_save(screen_data.slot)
			return true
		ScreenData.EnterMode.LOAD_GAME:
			if screen_data.slot < 0:
				return false
			game_manager.load_game(screen_data.slot)
			return true
		_:
			return false


## 收到返回标题事件后，先解除全局暂停，再走现有的 Screen 切换流程。
func _on_back_to_title() -> void:
	get_tree().paused = false
	transiton_screen(EmoGame.ScreenType.TITLE_SCREEN)


## 统一从场景树中获取自动加载的游戏管理器，兼容脚本测试环境。
func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")


## 统一从场景树获取自动加载的 Messages，避免脚本直接依赖全局名解析。
func _get_messages() -> Node:
	return get_tree().root.get_node_or_null("Messages")
