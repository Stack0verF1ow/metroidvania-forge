class_name Level
extends Node2D

signal level_transition_requested(new_level: GameScreen.Level_Number, transition_side: int, data: LevelData)

var game_screen: GameScreen = null
var level_data: LevelData = LevelData.build()
var level_name: GameScreen.Level_Number

@onready var level_transitions: Node2D = %LevelTransitions


# 保留空的生命周期钩子，和项目里其他节点脚本的结构保持一致。
func _enter_tree() -> void:
	pass


# 解析当前关卡对应的枚举值，放置玩家位置，并监听本关所有切图入口。
func _ready() -> void:
	var enum_names := GameScreen.Level_Number.keys()
	var enum_values := GameScreen.Level_Number.values()
	var index := enum_names.find(name)
	if index != -1:
		level_name = enum_values[index] as GameScreen.Level_Number
	else:
		push_error("Node name '%s' does not match any level enum." % name)

	set_player_position()

	for child in level_transitions.get_children():
		child.player_went_out.connect(_on_player_went_out)


# 保存所属 GameScreen 上下文，以及从上一张地图带过来的切图数据。
func setup(context_game_screen: GameScreen, context_data: LevelData) -> void:
	game_screen = context_game_screen
	level_data = context_data


# 向上层转发关卡切换请求，并保留方向和出生偏移数据。
func transiton_level(new_level: GameScreen.Level_Number, transition_side: int = -1, data: LevelData = LevelData.new()) -> void:
	level_transition_requested.emit(new_level, transition_side, data)


# 找到当前关卡里“指向上一张地图”的那个入口。
func get_entry_transition() -> LevelTransition:
	for child in level_transitions.get_children():
		var transition := child as LevelTransition
		if transition != null and transition.target_level == level_data.last_level:
			return transition
	return null


# 返回当前关卡在揭幕时应该使用的入口方向。
func get_entry_transition_side() -> int:
	var entry_transition := get_entry_transition()
	if entry_transition == null:
		return -1
	return entry_transition.get_transition_side()


# 当玩家从别的房间切进来时，把玩家放到匹配的入口位置。
func set_player_position() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	# 上一张地图的 id 就是查找当前出生入口的关键索引。
	var entry_transition := get_entry_transition()
	if entry_transition != null:
		player.global_position = entry_transition.global_position + level_data.relative_position


# 收集离开当前关卡时的上下文数据，并请求 GameScreen 真正执行切图。
func _on_player_went_out(target_level: GameScreen.Level_Number, relative_pos: Vector2, transition_side: int) -> void:
	level_data = level_data.set_last_level(level_name).set_relative_position(relative_pos)
	print(name + "收到")
	transiton_level(target_level, transition_side, level_data)
