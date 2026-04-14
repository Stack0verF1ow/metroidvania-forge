class_name LevelNameHelper

const map : Dictionary = {
	GameScreen.Level_Number.Level_A : "Level_A",
	GameScreen.Level_Number.Level_B : "Level_B",
	GameScreen.Level_Number.Level_C : "Level_C",
}


static func get_string(level_number: GameScreen.Level_Number) -> String:
	return map[level_number]

static func get_level_number(level_name: String) -> GameScreen.Level_Number:
	
	return map.find_key(level_name) 
