class_name PlayerStateTakeDamage
extends PlayerState


@onready var damage_area: DamageArea = %DamageArea
@onready var hurt_audio: AudioStreamPlayer2D = %HurtAudio

@export var move_speed : float = 100
@export var invulnerable_duration : float = 0.5

var time : float = 0.0
var dir : float = 1.0


func init() -> void:
	damage_area.damage_taken.connect( _on_damage_taken )
	
func enter() -> void:
	player.animation_player.play("take_damage")
	time = player.animation_player.current_animation_length
	damage_area.make_invulnerable( invulnerable_duration )
	hurt_audio.play()
	VisualEffect.camera_shake( 2.0 )
	
	
func exit() -> void:
	pass

func handle_input( event : InputEvent) -> PlayerState:
	
	return null

func process( delta: float) -> PlayerState:
	time -= delta
	if time <= 0:
		return idle
	return null

func physics_process(_delta: float) -> PlayerState : 
	player.velocity.x = move_speed * dir
	return null

func _on_damage_taken( attack_area: AttackArea ) -> void:
	player.change_state( self )
	if attack_area.global_position.x < player.global_position.x:
		dir = 1.0
	else:
		dir = -1.0
	
