class_name LevelFactory

var levels : Dictionary

func _init() -> void:
	levels = {
		Game.Level_Number.Level_A : preload("res://levels/00_forest/level_a.tscn"),
		Game.Level_Number.Level_B : preload("res://levels/00_forest/level_b.tscn"),
		Game.Level_Number.Level_C : preload("res://levels/00_forest/level_c.tscn"),
	}

func get_frush_level( level: Game.Level_Number ) -> Level:
	assert(levels.has(level), "level don't exist")
	return levels.get(level).instantiate()
