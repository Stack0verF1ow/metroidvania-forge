extends Node

signal runtime_loaded( new_level_num: GameScreen.Level_Number )

const SLOTS : Array[ String ] = [
	"save_01.sav", "save_02.sav", "save_03.sav",
]
var current_run: RunTime = RunTime.create_new()

## 确保自动加载的游戏管理器始终持有可用运行态。
func _ready() -> void:
	_ensure_current_run()


## 采集当前运行中的玩家状态，并委托数据管理器写入磁盘。
func save_game() -> void:
	_ensure_current_run()
	_capture_player_state()

	if not DataManager.save_runtime(current_run, get_file_name()):
		push_error("Failed to save runtime data.")


## 从磁盘恢复运行态，并通知 GameScreen 按新数据刷新。
func load_game() -> void:
	current_run = DataManager.load_runtime( get_file_name() )
	runtime_loaded.emit( current_run.level_num )
	restore_loaded_player()


## 更新当前运行态记录的关卡信息，并同步探索区域。
func set_current_level(new_level: GameScreen.Level_Number) -> void:
	_ensure_current_run()
	current_run.remember_level(new_level)


## 把读档数据应用回玩家。
func restore_loaded_player() -> void:
	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return

	current_run.apply_to_player(player)


## 把当前玩家节点的关键属性收敛到运行态里，避免存档层直接依赖场景细节。
func _capture_player_state() -> void:
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		return

	current_run.capture_player(player)


## 在其他入口访问前兜底初始化运行态，避免空引用。
func _ensure_current_run() -> void:
	if current_run == null:
		current_run = DataManager.create_new_runtime()

# 查找存档槽位
func get_file_name() -> String:
	return "user://" + SLOTS[current_run.current_slot]
