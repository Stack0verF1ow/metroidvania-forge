class_name PlayerStateFall
extends PlayerState

const FALL_GRAVITY_WEIGHT := 1.165
const COYOTE_TIME : float = 0.2
const JUMP_BUFFER_TIME := 0.2

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

func init() -> void:
	#print("init!" + name)
	pass
	
func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.gravity_weight = FALL_GRAVITY_WEIGHT
	if player.previous_state == jump:
		coyote_timer = 0
	else:
		coyote_timer = COYOTE_TIME
	pass
	
func exit() -> void:
	player.gravity_weight = 1.0
	jump_buffer_timer = 0
	pass

func handle_input( event : InputEvent ) -> PlayerState:
	if event.is_action_pressed("Jump"):
		if coyote_timer > 0:
			return jump
		else :
			jump_buffer_timer = JUMP_BUFFER_TIME
	return null

func process(delta: float) -> PlayerState:
	set_jump_frame(player.velocity.y, 0.0, player.MAX_FALL_VELOCITY, 0.5, 1.0)
	coyote_timer -= delta
	jump_buffer_timer -= delta
	return null

func physics_process(_delta: float) -> PlayerState : 
	if player.is_on_floor():
		if jump_buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.MOVE_SPEED
	
	return null
