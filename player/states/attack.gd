class_name PlayerStateAttack
extends PlayerState

@onready var attack_sprite_2d: Sprite2D = %AttackSprite2D

const AUDIO_ATTACK = preload("uid://sacae6da2rjs")

@export var combo_time_window : float = 0.2
@export var speed : float = 150

var timer : float = 0
var combo : int = 0


func init() -> void:
	attack_sprite_2d.visible = false
	pass
	
func enter() -> void:
	do_attack()
	player.animation_player.animation_finished.connect( _on_animation_finished )
	
	
	
func exit() -> void:
	timer = 0
	combo = 0
	player.animation_player.animation_finished.disconnect( _on_animation_finished )
	next_state = null
	attack_sprite_2d.visible = false
	pass

func handle_input( event : InputEvent) -> PlayerState:
	if event.is_action_pressed("Attack"):
		timer = combo_time_window
	return null

func process( delta: float) -> PlayerState:
	timer -= delta
	return next_state

func physics_process(_delta: float) -> PlayerState : 
	player.velocity.x = player.direction.x * speed
	return null

func do_attack() -> void:
	var anim_name : String = "attack"
	if combo > 0 :
		anim_name = "attack_2"
	player.animation_player.play(anim_name)
	player.attack_area.activate()
	Audio.play_spatial_sound( AUDIO_ATTACK, player.global_position )

func _end_attack() -> void:
	if timer > 0:
		combo = wrapi( combo + 1, 0, 2 )
		do_attack()
	else:
		if player.is_on_floor():
			next_state = idle
		else:
			next_state = fall

func _on_animation_finished( _anim_name : String ) -> void:
	_end_attack()
	pass
