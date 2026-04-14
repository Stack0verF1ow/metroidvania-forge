class_name Level
extends Node2D

signal level_transition_requested(new_level: GameScreen.Level_Number, transition_side: int, data: LevelData)

var game_screen: GameScreen = null
var level_data: LevelData = LevelData.build()
var level_name: GameScreen.Level_Number

@onready var level_transitions: Node2D = %LevelTransitions


func _enter_tree() -> void:
	pass


func _ready() -> void:
	var enum_names := GameScreen.Level_Number.keys()
	var enum_values := GameScreen.Level_Number.values()
	var index := enum_names.find(name)
	if index != -1:
		level_name = enum_values[index] as GameScreen.Level_Number
	else:
		push_error("Node name '%s' does not match any level enum." % name)

	for child in level_transitions.get_children():
		if child is LevelTransition:
			child.set_area_enabled(false)

	set_player_position()

	await get_tree().create_timer(0.2).timeout
	for child in level_transitions.get_children():
		if child is LevelTransition:
			child.set_area_enabled(true)
			child.player_went_out.connect(_on_player_went_out)


func setup(context_game_screen: GameScreen, context_data: LevelData) -> void:
	game_screen = context_game_screen
	level_data = context_data


func transiton_level(
	new_level: GameScreen.Level_Number,
	transition_side: int = LevelTransition.SIDE.INIT,
	data: LevelData = LevelData.new()
) -> void:
	level_transition_requested.emit(new_level, transition_side, data)


func get_entry_transition() -> LevelTransition:
	for child in level_transitions.get_children():
		var transition := child as LevelTransition
		if transition != null and transition.target_level == level_data.last_level:
			return transition
	return null


func get_entry_transition_side() -> int:
	var entry_transition := get_entry_transition()
	if entry_transition == null:
		return LevelTransition.SIDE.INIT
	return entry_transition.get_transition_side()


func set_player_position() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	var entry_transition := get_entry_transition()
	if entry_transition != null:
		player.global_position = entry_transition.global_position + level_data.relative_position


func _on_player_went_out(
	target_level: GameScreen.Level_Number,
	relative_pos: Vector2,
	transition_side: int
) -> void:
	level_data = level_data.set_last_level(level_name).set_relative_position(relative_pos)
	transiton_level(target_level, transition_side, level_data)
