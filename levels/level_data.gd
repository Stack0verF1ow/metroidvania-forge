class_name LevelData

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
var last_level : GameScreen.Level_Number = -1
var relative_position : Vector2 = Vector2.ZERO

static func build() -> LevelData:
	return LevelData.new()

func set_last_level(context_last_level: GameScreen.Level_Number) -> LevelData:
	last_level = context_last_level
	return self

func set_relative_position(context_relative_position: Vector2) -> LevelData:
	relative_position = context_relative_position
	return self
