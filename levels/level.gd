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
	
	# 根据节点名字自动转换为枚举值
	var enum_names = Game.Level_Number.keys()
	var enum_values = Game.Level_Number.values()
	var index = enum_names.find(self.name)  # 假设节点名与枚举名完全一致
	
	if index != -1:
		level_name = enum_values[index] as Game.Level_Number
	else:
		push_error("节点名 '%s' 不匹配任何关卡枚举！" % self.name)

	set_player_position()
	
	for child in level_transitions.get_children() :
		child.player_went_out.connect( _on_player_went_out.bind() )

func setup(context_game: Game, context_data: LevelData) -> void:
	game = context_game
	level_data = context_data 

func transiton_level(new_level: Game.Level_Number, data: LevelData = LevelData.new()) -> void:
	level_transition_requested.emit(new_level, data)

func set_player_position() -> void:
	print(self.name + "正在设置角色位置")
	print(str(level_data.last_level))
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if not player :
		print("未找到角色")
	
	for child in level_transitions.get_children():
		if child.target_level == level_data.last_level:
			print(str(level_data.last_level) + " " + str(level_data.relative_position))
			player.global_position = child.global_position + level_data.relative_position

func _on_player_went_out( target_level: Game.Level_Number, relative_pos: Vector2 ) -> void:
	print(self.name + "->" + str(target_level) )
	level_data = level_data.set_last_level(level_name).set_relative_position(relative_pos)
	transiton_level( target_level, level_data )
