@tool
@icon("res://sences/level_transition/level_transition.svg")

class_name LevelTransition
extends Node2D

# 定义这个转场触发器位于关卡的哪一侧。
enum SIDE { LEFT, RIGHT, TOP, BOTTOM, INIT }

@export_range(2, 12, 1, "or_greater") var size: int = 2:
	set(value):
		size = value
		apply_area_settings()

@export var location: SIDE = SIDE.LEFT:
	set(value):
		location = value
		apply_area_settings()
		
@export var target_level : GameScreen.Level_Number

signal player_went_out(target_level_name: GameScreen.Level_Number, relative_pos: Vector2, transition_side: int)

@onready var area_2d: Area2D = %Area2D

# 运行时绑定玩家进入触发区后的回调。
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	area_2d.body_entered.connect(_on_player_entered)


# 提供一个显式方法给外部读取当前转场方向，避免直接依赖导出字段。
func get_transition_side() -> int:
	return location


# 根据方向和尺寸调整触发区缩放，让同一个场景资源能复用为四个边界入口。
func apply_area_settings() -> void:
	area_2d = get_node_or_null("%Area2D")
	if area_2d == null:
		return

	match location:
		SIDE.LEFT:
			area_2d.scale = Vector2(-1.0, size)
		SIDE.RIGHT:
			area_2d.scale = Vector2(1.0, size)
		SIDE.TOP:
			area_2d.scale = Vector2(size, -1.0)
		SIDE.BOTTOM:
			area_2d.scale = Vector2(size, 1.0)


# 计算玩家进入下一张地图后的相对出生偏移。
func get_relative_pos(player_position: Vector2) -> Vector2:
	var relative_position := player_position - global_position

	match location:
		SIDE.LEFT:
			# 稍微把出生点推出触发区，避免玩家刚落地就再次触发切图。
			relative_position.x -= 20.0
		SIDE.RIGHT:
			relative_position.x += 20.0
		SIDE.TOP:
			relative_position.y += 20.0
		SIDE.BOTTOM:
			relative_position.y -= 20.0

	return relative_position


# 把出生偏移和离开方向一起打包，交回给 Level 发起切图。
func _on_player_entered(player: CharacterBody2D) -> void:
	print("玩家将进入" + name)
	var relative_pos := get_relative_pos(player.global_position)
	player_went_out.emit(target_level, relative_pos, get_transition_side())
