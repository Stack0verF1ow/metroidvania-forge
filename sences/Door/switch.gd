@icon("res://assets/ch_03_game_systems/icons/switch.svg")
class_name Switch
extends Node2D

signal activated()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D

const DOOR_SWITCH_AUDIO = preload("uid://pqnyiwt4uexp")

var is_open : bool = false

func _ready() -> void:
	var game_manager := _get_game_manager()
	if game_manager == null:
		return

	if game_manager.current_run.persistent_data.get_or_add(unique_name(), "closed") == "open":
		is_open = true
		set_open()
	else:
		area_2d.body_entered.connect( _on_player_entered )
		area_2d.body_exited.connect( _on_player_exited )


func _on_player_entered( _n : Node ) -> void:
	var messages := _get_messages()
	if messages == null:
		return

	messages.input_hints_changed.emit("interact")
	messages.player_interacted.connect(_on_player_interacted)

func _on_player_exited( _n : Node ) -> void:
	var messages := _get_messages()
	if messages == null:
		return

	messages.input_hints_changed.emit("")
	messages.player_interacted.disconnect(_on_player_interacted)

func _on_player_interacted( _player : Node ) -> void :
	var game_manager := _get_game_manager()
	if game_manager == null:
		return

	game_manager.current_run.persistent_data[unique_name()] = "open"
	Audio.play_spatial_sound( DOOR_SWITCH_AUDIO, global_position )
	activated.emit()
	set_open()

func set_open() -> void:
	sprite_2d.flip_h = true 
	sprite_2d.modulate = Color.GRAY
	area_2d.queue_free()


## 返回祖父节点名和父节点名的组合，供 persistent_data 作为机关状态的唯一键使用。
func unique_name() -> String :
	var parent_node := get_parent()
	if parent_node == null:
		return name

	var grandparent_node := parent_node.get_parent()
	if grandparent_node == null:
		return parent_node.name

	return "%s_%s" % [grandparent_node.name, parent_node.name]


## 统一从场景树读取自动加载的 GameManager，避免脚本直接依赖全局名解析。
func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")


## 统一从场景树读取自动加载的 Messages，避免脚本直接依赖全局名解析。
func _get_messages() -> Node:
	return get_tree().root.get_node_or_null("Messages")
