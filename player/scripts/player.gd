class_name Player
extends CharacterBody2D

var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]

var diretion := Vector2.ZERO
var gravity : float = 980

func _ready() -> void:
	initialize_states()
	pass

func _unhandled_input(event: InputEvent) -> void:
	change_state( current_state.handle_input(event))

func _process(_delta: float) -> void:
	update_direction()
	change_state( current_state.process(_delta) )
	pass

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()
	change_state( current_state.physics_process(delta) )
	pass

func initialize_states() -> void:
	states = []
	for child in %States.get_children():
		if child is PlayerState:
			states.append(child)
			child.player = self
	
	if states.size() == 0 :
		return
	
	for state in states :
		state.init()
	
	change_state(current_state)
	
func update_direction() -> void:
	var prev_direction : Vector2 = diretion
	diretion = Input.get_vector("Left", "Right", "Up", "Down")

func change_state(new_state : PlayerState) -> void:
	if new_state == null:
		return
	elif new_state == current_state :
		return
	
	if current_state:
		current_state.exit()
	
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
