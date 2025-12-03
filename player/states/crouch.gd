class_name PlayerStateCrouch
extends PlayerState

const DECELERATION_RATE : float = 10

func init() -> void:
	print("init!" + name)
	pass
	
func enter() -> void:
	player.animation_player.play("crouch")
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false
	pass
	
func exit() -> void:
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true
	pass

func handle_input( event : InputEvent) -> PlayerState:
	if event.is_action_pressed("Jump"):
		player.one_way_platform_ray_cast.force_shapecast_update()
		if player.one_way_platform_ray_cast.is_colliding() == true:
			player.position.y += 4 
			return fall
	return null

func process(_delta: float) -> PlayerState:
	
	return null

func physics_process(delta: float) -> PlayerState : 
	player.velocity.x -= player.velocity.x * DECELERATION_RATE * delta
	if player.direction.y <= 0.5:
		return idle
	return null
