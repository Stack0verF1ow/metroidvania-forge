@icon("res://player/states/state.svg") 
class_name PlayerState
extends Node

var player : Player
var next_state : PlayerState

@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall


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
