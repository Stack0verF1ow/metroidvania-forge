class_name PlayerState
extends Node

var player : Player
var next_state : PlayerState

func init() -> void:
	print("init!" + name)
	pass
	
func enter() -> void:
	pass
	
func exit() -> void:
	pass

func handle_input( _event : InputEvent) -> PlayerState:
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState : 
	return null
