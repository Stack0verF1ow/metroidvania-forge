class_name ScreenFactory

var screens : Dictionary

func _init() -> void:
	screens = {
		EmoGame.ScreenType.GAME_SCREEN : preload("res://sences/game_screen/game_screen.tscn"),
	}

func get_fresh_screen(screen: EmoGame.ScreenType) -> Screen:
	assert(screens.has(screen), "screen don't exist")
	return screens.get(screen).instantiate()
