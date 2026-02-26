class_name Level
extends Node2D

signal level_transition_requested(new_level: Game.Level_Number, data: LevelData)

var game : Game = null
var level_data : LevelData = null

var level_name : Game.Level_Number

@onready var level_transitions : Node2D = %LevelTransitions

func _enter_tree() -> void:
	pass

func _ready() -> void:
	
	set_player_position()
	
	for child in level_transitions.get_children() :
		child.player_went_out.connect( _on_player_went_out.bind() )

func setup(context_game: Game, context_data: LevelData) -> void:
	game = context_game
	level_data = context_data 

func transiton_level(new_level: Game.Level_Number, data: LevelData = LevelData.new()) -> void:
	level_transition_requested.emit(new_level, data)

func set_player_position() -> void:
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if not player :
		print("未找到角色")
	
	for child in level_transitions.get_children():
		if child.target_level == level_data.last_level:
			player.global_position = child.global_position + level_data.relative_position

func _on_player_went_out( target_level: Game.Level_Number, relative_pos: Vector2 ) -> void:
	print(self.name + "发现")
	level_data = LevelData.build().set_last_level(level_name).set_relative_position(relative_pos)
	transiton_level( target_level, level_data )
