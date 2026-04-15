class_name GameScreen
extends Screen

@onready var screen_effect: ScreenEffect = %ScreenEffect

enum Level_Number {
	Level_A,
	Level_B,
	Level_C,
}

var current_level: Level = null
var level_factory := LevelFactory.new()


## 初始化游戏界面，并根据 ScreenData 决定是直接进当前运行态还是先新建/读档。
func _ready() -> void:
	var game_manager = _get_game_manager()
	if game_manager != null:
		game_manager.runtime_loaded.connect(_on_runtime_loaded)
		if _enter_from_screen_data(game_manager):
			return

		switch_level(game_manager.current_run.level_num, LevelTransition.SIDE.INIT)
		return

	switch_level(Level_Number.Level_A, LevelTransition.SIDE.INIT)


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


## 读取上一个界面传来的 ScreenData，并把“新游戏/读档”请求转交给 GameManager。
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


## 统一从场景树中获取自动加载的游戏管理器，兼容脚本测试环境。
func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")
