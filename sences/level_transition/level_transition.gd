@tool # 自定义工具，可在编辑器使用

@icon("res://sences/level_transition/level_transition.svg")

class_name LevelTransition
extends Node2D

#可编辑选项
@export_range( 2, 12, 1, "or_greater" ) var size : int = 2 :
	set( value ):
		size = value
		apply_area_settings()
	

@export var location : SIDE = SIDE.LEFT :
	set( value ):
		location = value
		apply_area_settings()

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

signal player_went_out( target_level_name: Game.Level_Number, relative_pos: Vector2, transi_dir: String )

#关联节点变量
@onready var area_2d: Area2D = %Area2D

var target_level : Game.Level_Number 

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.body_entered.connect( _on_player_entered.bind() )
	
	# 根据节点名字自动转换为枚举值
	var enum_names = Game.Level_Number.keys()
	var enum_values = Game.Level_Number.values()
	var index = enum_names.find(self.name)  # 假设节点名与枚举名完全一致
	
	if index != -1:
		target_level = enum_values[index] as Game.Level_Number
	else:
		push_error("节点名 '%s' 不匹配任何关卡枚举！" % self.name)

	# 原打印代码保留（可选）
	#print(self.name, " -> 目标关卡: ", Game.Level_Number.keys()[target_level])

func apply_area_settings() -> void:
	area_2d = get_node_or_null("%Area2D")
	if not area_2d :
		return
	
	match location:
		SIDE.LEFT:
			area_2d.scale.x = -1
			area_2d.scale.y = size
			
		SIDE.RIGHT:
			area_2d.scale.x = 1
			area_2d.scale.y = size
			
		SIDE.TOP:
			area_2d.scale.x = size
			area_2d.scale.y = -1
			
		SIDE.BOTTOM:
			area_2d.scale.x = size
			area_2d.scale.y = 1
			

func get_relative_pos( player_position: Vector2 ) -> Vector2:
	
	var relative_postion =  player_position - self.global_position 
	
	match location:
		SIDE.LEFT:
			relative_postion.x -= 12
			
		SIDE.RIGHT:
			relative_postion.x += 12
			
		SIDE.TOP:
			relative_postion.y += 12
			
		SIDE.BOTTOM:
			relative_postion.y -= 12
	
	return relative_postion

# 控制区域是否可触发,避免频繁触发
func set_area_enabled(enabled: bool) -> void:
	area_2d.monitoring = enabled

func get_dir( location: SIDE ) -> String:
	var dir : String = ""
	match location:
		SIDE.LEFT:
			dir = "left"
			
		SIDE.RIGHT:
			dir = "right"
			
		SIDE.TOP:
			dir = "up"
			
		SIDE.BOTTOM:
			dir = "down"
	
	return dir

func _on_player_entered( player : CharacterBody2D ) -> void:
	var relative_pos : Vector2 = get_relative_pos(player.global_position) 
	#print("玩家位置：" + str(player.global_position) + " 加载点位置：" + str(self.global_position))
	player_went_out.emit( target_level, relative_pos, get_dir(location) )
