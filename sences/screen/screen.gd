class_name Screen
extends Node

signal screen_transition_requested(new_screen: EmoGame.ScreenType, data: ScreenData)

var game : EmoGame = null
var screen_data : ScreenData = null

func _enter_tree() -> void:
	pass

func setup(context_game: EmoGame, context_data: ScreenData) -> void:
	game = context_game
	screen_data = context_data 

func transiton_screen(new_screen: EmoGame.ScreenType, data: ScreenData = ScreenData.new()) -> void:
	screen_transition_requested.emit(new_screen, data)
