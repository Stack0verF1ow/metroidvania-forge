class_name LevelNameHelper

const map : Dictionary = {
	Game.Level_Number.Level_A : "Level_A",
	Game.Level_Number.Level_B : "Level_B",
	Game.Level_Number.Level_C : "Level_C",
}


static func get_string(level_number: Game.Level_Number) -> String:
	return map[level_number]

static func get_level_number(level_name: String) -> Variant:
	for level_number in map:
		if map[level_number] == level_name:
			return level_number
	return null 
