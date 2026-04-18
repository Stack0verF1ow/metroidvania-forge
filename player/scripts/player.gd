class_name Player
extends CharacterBody2D

signal damage_taken()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionShapeStand
@onready var collision_crouch: CollisionShape2D = $CollisionShapeCrouch
@onready var da_stand: CollisionShape2D = %DAStand
@onready var da_crouch: CollisionShape2D = %DACrouch
@onready var one_way_platform_ray_cast: ShapeCast2D = $OneWayPlatformRayCast
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var attack_area: AttackArea = $AttackArea
@onready var attack_sprite: Sprite2D = %AttackSprite2D
@onready var damage_area: DamageArea = %DamageArea


const MOVE_SPEED : float = 150
const JUMP_VELOCITY : float = 450
const MAX_FALL_VELOCITY := 600

var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]

var direction := Vector2.ZERO
var gravity : float = 980
var gravity_weight : float = 1.0


var hp : float = 20 :
	set( value ):
		hp = clampf( value, 0, max_hp )
		Messages.player_health_changed.emit( hp, max_hp )
		
var max_hp : float = 20 :
	set( value ):
		max_hp = value
		Messages.player_health_changed.emit( hp, max_hp )
		
var dash : bool = false
var double_jump : bool = false
var ground_slam : bool = false
var morph_roll : bool = false

func _ready() -> void:
	z_index = 255
	initialize_states()
	Messages.player_healed.connect( _on_player_healed )
	damage_area.damage_taken.connect( _on_damage_taken )
	hp = max_hp

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("Jump") and velocity.y < 0 :
		velocity.y *= 0.5
	if event.is_action_pressed("Action"):
		Messages.player_interacted.emit( self )
	change_state( current_state.handle_input(event))
	
	# Debug
	if OS.is_debug_build():
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_MINUS:
				if Input.is_key_pressed( KEY_SHIFT ):
					max_hp -= 10
				else:
					hp -=2
			elif event.keycode == KEY_EQUAL :
				if Input.is_key_pressed( KEY_SHIFT ):
					max_hp += 10
				else:
					hp += 2
		#if event.is_action_pressed("Attack"):
			#attack_area.activate()
	#end Debug

func _process(_delta: float) -> void:
	update_direction()
	change_state( current_state.process(_delta) )
	pass

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta * gravity_weight
	velocity.y = clampf(velocity.y, -1000.0, MAX_FALL_VELOCITY)
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
	var prev_direction : Vector2 = direction
	
	var x_axis = Input.get_axis("Left", "Right")
	var y_axis = Input.get_axis("Up", "Down")
	direction = Vector2(x_axis, y_axis)
	
	if direction.x != prev_direction.x :
		attack_area.flip( direction.x )
		if direction.x < 0:
			sprite.flip_h = true
			attack_sprite.flip_h = true
			attack_sprite.position.x = -24
		elif direction.x > 0:
			sprite.flip_h = false
			attack_sprite.flip_h = false
			attack_sprite.position.x = 24
	
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

func _on_player_healed( amount: float ) -> void:
	hp += amount
	# audio/visual

func _on_damage_taken( attack_area : AttackArea ) -> void:
	if current_state == PlayerStateDeath:
		return
	hp -= attack_area.damage
	damage_taken.emit()
	
