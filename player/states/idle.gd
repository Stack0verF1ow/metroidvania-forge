class_name PlayerStateIdle
extends PlayerState

func init() -> void:
	print("init!" + name)
	pass
	
func enter() -> void:
	player.animation_player.play("idle")
	
	
func exit() -> void:
	pass

func handle_input( event : InputEvent) -> PlayerState:
	if event.is_action_pressed("Jump"):
		return jump
	return null

func process(_delta: float) -> PlayerState:
	if player.direction.x != 0:
		return run
	elif player.direction.y > 0.5:
		return crouch
	
	if not player.is_on_floor() :
		return fall
	return null

func physics_process(_delta: float) -> PlayerState : 
	player.velocity.x = 0
	return null
