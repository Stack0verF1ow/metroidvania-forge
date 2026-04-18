@icon("res://assets/ch_04_player_abilities/icons/damage_area.svg")
class_name DamageArea
extends Area2D

signal damage_taken( attack_area )

@export var audio : AudioStream

func take_damage( attack_area : AttackArea ) -> void:
	damage_taken.emit()
	if audio :
		Audio.play_spatial_sound( audio, global_position )
	

func make_invulnerable( duration : float ) -> void:
	process_mode =Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer( duration ).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
