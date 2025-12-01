class_name PlayerStateJump
extends PlayerState

const JUMP_VELOCITY : float = 450

func init() -> void:
	print("init!" + name)
	pass
	
func enter() -> void:
	player.velocity.y = -JUMP_VELOCITY
	pass
	
func exit() -> void:
	pass

func handle_input( event : InputEvent) -> PlayerState:
	if event.is_action_released("Jump"):
		player.velocity.y *= 0.5
	return null

func process(_delta: float) -> PlayerState:
	
	return null

func physics_process(_delta: float) -> PlayerState : 
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0 :
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	
	return null
