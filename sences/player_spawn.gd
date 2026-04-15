@icon("res://assets/ch_02_world_building_foundations/player_spawn.svg")
class_name PlayerSpawn
extends Node2D

func _ready() -> void:
	visible = false
	
	await get_tree().process_frame
	if get_tree().get_first_node_in_group( "Player" ):
		return
	else :
		var player : Player = load("res://player/player.tscn").instantiate()
		player.global_position = global_position
		get_parent().add_child(player)
	
