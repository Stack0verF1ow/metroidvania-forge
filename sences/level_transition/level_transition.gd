@tool # 自定义工具，可在编辑器使用
@icon("res://sences/level_transition.svg")

class_name LevelTransition
extends Node2D

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

signal player_went_out()

#可编辑选项
@export_range( 2, 12, 1, "or_greater" ) var size : int = 2 :
	set( value ):
		size = value
		apply_area_settings()
	

@export var location : SIDE = SIDE.LEFT :
	set( value ):
		location = value
		apply_area_settings()

#关联节点变量
@onready var area_2d: Area2D = %Area2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect( _on_player_entered.bind() )

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
			

func _on_player_entered() -> void:
	player_went_out.emit()
