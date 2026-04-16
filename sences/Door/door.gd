@tool
@icon("res://assets/ch_03_game_systems/icons/door.svg")
class_name Door
extends Node2D

const DOOR_CRASH_AUDIO = preload("res://assets/ch_03_game_systems/audio/door_crash.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for c in get_children():
		if c is Switch:
			if c.is_open:
				_on_switch_is_open()
			else:
				c.activated.connect( _on_switch_activated )

func _on_switch_activated() -> void:
	animation_player.play("open")

func _on_switch_is_open() -> void:
	animation_player.play("opened")

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_switch() == false:
		return ["Requires a Switch node"]
	return []

func _check_for_switch()-> bool:
	for c in get_children():
		if c is Switch:
			return true
	
	return false
