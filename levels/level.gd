class_name Level
extends Node2D

signal level_transition_requested(new_level: Game.Level_Number, data: LevelData)

var game : Game = null
var level_data : LevelData = LevelData.build()

var level_name : Game.Level_Number

@onready var level_transitions : Node2D = %LevelTransitions

func _enter_tree() -> void:
	pass


func _ready() -> void:
	
	level_name = LevelNameHelper.get_level_number( self.name )
	
	# 1. 禁用所有过渡区域（防止出生时触发）
	for child in level_transitions.get_children():
		if child is LevelTransition:
			child.set_area_enabled(false)
	
	# 2. 设置玩家位置
	set_player_position()
	
	# 3. 延迟一小段时间后启用区域并连接信号
	await get_tree().create_timer(0.2).timeout
	for child in level_transitions.get_children():
		if child is LevelTransition:
			child.set_area_enabled(true)
			child.player_went_out.connect(_on_player_went_out.bind())

func setup(context_game: Game, context_data: LevelData) -> void:
	game = context_game
	level_data = context_data 

func transiton_level(new_level: Game.Level_Number, transi_dir: String, data: LevelData = LevelData.new()) -> void:
	level_transition_requested.emit(new_level, transi_dir, data)

func set_player_position() -> void:
	
	print(self.name + "正在设置角色位置" + "; 对应的关卡编号： " + str(level_name) )
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if not player :
		print("未找到角色")
	
	for child in level_transitions.get_children():
		if child.target_level == level_data.last_level:
			print(str(level_data.last_level) + " " + str(level_data.relative_position))
			player.global_position = child.global_position + level_data.relative_position

func _on_player_went_out( target_level: Game.Level_Number, relative_pos: Vector2, transi_dir: String ) -> void:
	print(self.name + " -> " + LevelNameHelper.get_string(target_level) )
	level_data = level_data.set_last_level(level_name).set_relative_position(relative_pos)
	transiton_level( target_level, transi_dir, level_data )
