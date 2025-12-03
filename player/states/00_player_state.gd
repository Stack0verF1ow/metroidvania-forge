@icon("res://player/states/state.svg") 
class_name PlayerState
extends Node

var player : Player
var next_state : PlayerState

@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall
@onready var crouch: PlayerStateCrouch = %Crouch


func init() -> void:
	print("init!" + name)
	pass
	
func enter() -> void:
	print("enter!" + name)
	pass
	
func exit() -> void:
	pass

func handle_input( _event : InputEvent) -> PlayerState:
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState : 
	return null

func set_jump_frame(now: float, a_begin: float, a_end: float, b_begin: float, b_end:float) -> void:
	var frame : float = remap(now, a_begin, a_end, b_begin, b_end)
	player.animation_player.seek(frame, true)
