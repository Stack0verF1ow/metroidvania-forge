@icon("res://assets/ch_03_game_systems/icons/save_point.svg")
class_name SavePoint
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer

func _ready()-> void:
	area_2d.body_entered.connect( _on_player_entered )
	area_2d.body_exited.connect( _on_player_exited )
	
func _on_player_entered( _n :Node2D )-> void:
	print("player come in")
	Messages.player_interacted.connect( _on_player_interacted )
	
func _on_player_exited( _n:Node2D )-> void:
	Messages.player_interacted.disconnect( _on_player_interacted )

func _on_player_interacted( _player : Player ) -> void:
	Messages.player_healed.emit( 999 )
	GameManager.save_game()
	animation_player.play("game_saved")
	animation_player.seek(0)
