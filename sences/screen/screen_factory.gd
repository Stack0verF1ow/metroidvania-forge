class_name ScreenFactory

var screen_paths: Dictionary


## 初始化游戏内可切换的界面路径映射。
func _init() -> void:
	screen_paths = {
		EmoGame.ScreenType.GAME_SCREEN: "res://sences/game_screen/game_screen.tscn",
		EmoGame.ScreenType.TITLE_SCREEN: "res://sences/title_screen/title_screen.tscn",
	}


## 根据界面类型在运行时加载并实例化一个新的界面节点。
func get_fresh_screen(screen: EmoGame.ScreenType) -> Screen:
	assert(screen_paths.has(screen), "screen don't exist")

	var screen_scene := load(screen_paths.get(screen)) as PackedScene
	assert(screen_scene != null, "screen scene failed to load")
	return screen_scene.instantiate() as Screen
