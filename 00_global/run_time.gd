class_name RunTime

const DEFAULT_LEVEL_NUM: GameScreen.Level_Number = GameScreen.Level_Number.Level_A
const DEFAULT_PLAYER_POSITION := Vector2(60.0, 230.0)
const DEFAULT_HP := 20.0

var current_slot: int = 0
var level_num: GameScreen.Level_Number = DEFAULT_LEVEL_NUM
var player_position: Vector2 = DEFAULT_PLAYER_POSITION
var hp: float = DEFAULT_HP
var max_hp: float = DEFAULT_HP
var dash: bool = false
var double_jump: bool = false
var ground_slam: bool = false
var morph_roll: bool = false
var discovered_areas: Array[int] = []
var persistent_data: Dictionary = {}


## 创建一份新游戏使用的默认运行态数据。
static func create_new() -> RunTime:
	var runtime := RunTime.new()
	runtime.discovered_areas = [DEFAULT_LEVEL_NUM]
	runtime.persistent_data = {}
	return runtime


## 将运行态转换成可落盘的字典结构。
func to_save_dictionary() -> Dictionary:
	return {
		"current_slot": current_slot,
		"level_num": level_num,
		"x": player_position.x,
		"y": player_position.y,
		"hp": hp,
		"max_hp": max_hp,
		"dash": dash,
		"double_jump": double_jump,
		"ground_slam": ground_slam,
		"morph_roll": morph_roll,
		"discovered_areas": discovered_areas.duplicate(),
		"persistent_data": persistent_data.duplicate(true),
	}


## 从存档字典恢复运行态，并兼容旧版字段命名。
static func from_save_dictionary(data: Dictionary) -> RunTime:
	var runtime := RunTime.create_new()
	runtime.current_slot = int(data.get("current_slot", runtime.current_slot))
	runtime.level_num = data.get("level_num", runtime.level_num) as GameScreen.Level_Number
	runtime.player_position = Vector2(
		float(data.get("x", runtime.player_position.x)),
		float(data.get("y", runtime.player_position.y))
	)
	runtime.hp = float(data.get("hp", runtime.hp))
	runtime.max_hp = float(data.get("max_hp", runtime.max_hp))
	runtime.dash = bool(data.get("dash", runtime.dash))
	runtime.double_jump = bool(data.get("double_jump", runtime.double_jump))
	runtime.ground_slam = bool(data.get("ground_slam", runtime.ground_slam))
	runtime.morph_roll = bool(data.get("morph_roll", runtime.morph_roll))

	var stored_areas = data.get("discovered_areas", data.get("discovered areas", [runtime.level_num]))
	runtime.discovered_areas.clear()
	if stored_areas is Array:
		for area in stored_areas:
			runtime.discovered_areas.append(int(area))

	if not runtime.discovered_areas.has(runtime.level_num):
		runtime.discovered_areas.append(runtime.level_num)

	var stored_persistent = data.get("persistent_data", {})
	if stored_persistent is Dictionary:
		runtime.persistent_data = stored_persistent.duplicate(true)
	else:
		runtime.persistent_data = {}

	return runtime


## 记录当前所处关卡，并确保探索列表里只保留一份。
func remember_level(new_level: GameScreen.Level_Number) -> void:
	level_num = new_level
	if not discovered_areas.has(new_level):
		discovered_areas.append(new_level)


## 从玩家节点抓取需要持久化的运行数据。
func capture_player(player: Player) -> void:
	player_position = player.global_position
	hp = player.hp
	max_hp = player.max_hp
	dash = player.dash
	double_jump = player.double_jump
	ground_slam = player.ground_slam
	morph_roll = player.morph_roll


## 将读档后的运行数据重新应用到玩家节点。
func apply_to_player(player: Player) -> void:
	player.global_position = player_position
	player.hp = hp
	player.max_hp = max_hp
	player.dash = dash
	player.double_jump = double_jump
	player.ground_slam = ground_slam
	player.morph_roll = morph_roll
