class_name Game
extends Node

@onready var screen_effect: CanvasLayer = %ScreenEffect

enum Level_Number {
	Level_A,
	Level_B,
	Level_C,
	#Level_D,
}

var current_level : Level = null
var Level_factory := LevelFactory.new()


func _ready() -> void:
	
	switch_Level(Level_Number.Level_A, "init")

func switch_Level( level: Level_Number, transi_dir: String, data: LevelData = LevelData.new() ) -> void:
	if current_level != null :
		current_level.queue_free()
		screen_effect.fade_in(transi_dir)
	current_level = Level_factory.get_frush_level(level)
	current_level.setup(self, data)
	current_level.level_transition_requested.connect(switch_Level.bind())
	call_deferred("add_child", current_level)
	
	if transi_dir == "init":
		screen_effect.first_load()
	else :
		screen_effect.fade_out(transi_dir)
