class_name GameScreen
extends Screen

@onready var screen_effect: ScreenEffect = %ScreenEffect

enum Level_Number {
	Level_A,
	Level_B,
	Level_C,
}

var current_level: Level = null
var level_factory := LevelFactory.new()


# 初始化首个关卡；如果存在存档系统，也接受它发来的读档切图请求。
func _ready() -> void:

	switch_level(Level_Number.Level_A, LevelTransition.SIDE.INIT)


# 执行完整切图流程：先遮住旧关卡，再替换场景，最后按新关卡入口方向揭幕。
func switch_level(level: Level_Number, transition_side: LevelTransition.SIDE = LevelTransition.SIDE.INIT, data: LevelData = LevelData.new()) -> void:
	if current_level != null:
		screen_effect.fade_out(transition_side)
		call_deferred("remove_child", current_level)
		current_level.queue_free()

	current_level = level_factory.get_frush_level(level)
	current_level.setup(self, data)
	current_level.level_transition_requested.connect(switch_level)
	
	call_deferred("add_child", current_level)
	screen_effect.fade_in(transition_side)
