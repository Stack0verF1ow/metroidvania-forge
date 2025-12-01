class_name Player
extends CharacterBody2D

@export var move_speed : float = 150

var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]

var direction := Vector2.ZERO
var gravity : float = 980
var gravity_weight : float = 1.0

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
	velocity.y += gravity * delta * gravity_weight
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
	$Label.text = current_state.name
	
func update_direction() -> void:
	#var prev_direction : Vector2 = direction
	
	var x_axis = Input.get_axis("Left", "Right")
	var y_axis = Input.get_axis("Up", "Down")
	direction = Vector2(x_axis, y_axis)
	
func change_state(new_state : PlayerState) -> void:
	if new_state == null:
		return
	elif new_state == current_state :
		return
	
	if current_state:
		current_state.exit()
	
	#记录近期3个状态
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
	
	$Label.text = current_state.name
