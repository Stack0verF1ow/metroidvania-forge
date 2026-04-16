class_name LevelFactory

var level_paths: Dictionary


## 初始化关卡编号到场景路径的映射。
func _init() -> void:
	level_paths = {
		GameScreen.Level_Number.Level_A: "res://levels/00_forest/level_a.tscn",
		GameScreen.Level_Number.Level_B: "res://levels/00_forest/level_b.tscn",
		GameScreen.Level_Number.Level_C: "res://levels/00_forest/level_c.tscn",
		GameScreen.Level_Number.Level_D: "res://levels/00_forest/level_d.tscn",
	}


## 根据关卡编号返回对应的 PackedScene，供运行时切关和编辑器预览复用。
func get_level_scene(level: GameScreen.Level_Number) -> PackedScene:
	assert(level_paths.has(level), "level don't exist")

	var level_scene := load(level_paths.get(level)) as PackedScene
	assert(level_scene != null, "level scene failed to load")
	return level_scene


## 根据关卡编号在运行时加载并实例化一个全新的关卡场景。
func get_frush_level(level: GameScreen.Level_Number) -> Level:
	var level_scene := get_level_scene(level)
	return level_scene.instantiate() as Level
