class_name PauseMenu
extends CanvasLayer

@onready var pause_menu: Control = %PauseMenu
@onready var system: Control = %System
@onready var system_menu_button: Button = %SystemMenuButton
@onready var back_to_map_button: Button = %BackToMapButton
@onready var back_to_title_button: Button = %BackToTitleButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider
@onready var map_root: Control = $PauseMenu/Map
@onready var player_indicator: Control = $PauseMenu/Map/PlayerIndicator

var test_position : Vector2

## 初始化暂停菜单，并绑定系统菜单入口与系统菜单内部按钮。
func _ready() -> void:
	show_pause_menu()
	system_menu_button.pressed.connect(show_system_menu)
	setup_system_menu()
	setup_button_audio()
	
	test_position = get_tree().get_first_node_in_group("Player").global_position

## 处理暂停键开关，让暂停菜单在暂停状态下也能重新关闭。
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible
		if visible:
			_refresh_player_indicator()
	
	if pause_menu.visible == true:
		if event.is_action_pressed("Right") or event.is_action_pressed("Down"):
			system_menu_button.grab_focus()


## 显示主暂停菜单，并隐藏系统设置面板。
func show_pause_menu() -> void:
	pause_menu.visible = true
	system.visible = false
	_refresh_player_indicator()


## 显示系统设置面板，并隐藏主暂停菜单。
func show_system_menu() -> void:
	pause_menu.visible = false
	system.visible = true
	back_to_map_button.grab_focus()


## 绑定系统菜单中的返回地图和返回标题按钮事件。
func setup_system_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear( 2 )
	sfx_slider.value = AudioServer.get_bus_volume_linear( 3 )
	ui_slider.value = AudioServer.get_bus_volume_linear( 4 )
	
	
	music_slider.value_changed.connect( _on_music_slider_changed )
	sfx_slider.value_changed.connect( _on_sfx_slider_changed )
	ui_slider.value_changed.connect( _on_ui_slider_changed )
	
	back_to_map_button.pressed.connect(show_pause_menu)
	back_to_title_button.pressed.connect(_on_back_to_title_pressed)

func setup_button_audio() -> void :
	for c in find_children("*", "Button"):
		c.focus_entered.connect( Audio.play_ui.bind( Audio.Sound.UI_FOCUS ) )
		c.pressed.connect( Audio.play_ui.bind( Audio.Sound.UI_SELECT ) )

## 向全局消息节点发送“返回标题”事件，由 GameScreen 统一执行切屏流程。
func _on_back_to_title_pressed() -> void:
	var messages := _get_messages()
	if messages != null:
		messages.emit_signal("back_to_title")


## 统一从场景树获取自动加载的 Messages，避免界面脚本直接依赖全局名解析。
func _get_messages() -> Node:
	return get_tree().root.get_node_or_null("Messages")


## 重新计算暂停地图上的玩家指示器位置；
## 打开地图时先隐藏指示器，再让当前关卡对应的 MapNode 把它摆到正确位置。
func _refresh_player_indicator() -> void:
	if player_indicator == null:
		return

	player_indicator.visible = false
	if map_root == null:
		return

	for child in map_root.get_children():
		if child is MapNode:
			(child as MapNode).display_player_location()

func _on_music_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 2, v )
	DataManager.save_configuration()

func _on_sfx_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 3, v )
	Audio.play_spatial_sound( preload("uid://qme1ayhy0c71"), test_position)
	DataManager.save_configuration()

func _on_ui_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 4, v )
	Audio.play_ui( Audio.Sound.UI_SELECT )
	DataManager.save_configuration()
