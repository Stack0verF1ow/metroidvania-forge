class_name TitleScreen
extends Screen

@onready var main_menu: VBoxContainer = %MainMenu
@onready var new_game_menu: VBoxContainer = %NewGameMenu
@onready var load_game_menu: VBoxContainer = %LoadGameMenu

@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton

@onready var start_slot_1: Button = %StartSlot1
@onready var start_slot_2: Button = %StartSlot2
@onready var start_slot_3: Button = %StartSlot3

@onready var load_slot_1: Button = %LoadSlot1
@onready var load_slot_2: Button = %LoadSlot2
@onready var load_slot_3: Button = %LoadSlot3

@onready var animation_player: AnimationPlayer = $Control/MainMenu/Logo/AnimationPlayer


## 绑定标题界面上的菜单按钮和动画回调。
func _ready() -> void:
	var audio := _get_audio()
	if audio != null:
		audio.stop_music()
	new_game_button.pressed.connect(show_new_game_menu)
	load_game_button.pressed.connect(show_load_game_menu)

	start_slot_1.pressed.connect(_on_new_game_pressed.bind(0))
	start_slot_2.pressed.connect(_on_new_game_pressed.bind(1))
	start_slot_3.pressed.connect(_on_new_game_pressed.bind(2))

	load_slot_1.pressed.connect(_on_load_game_pressed.bind(0))
	load_slot_2.pressed.connect(_on_load_game_pressed.bind(1))
	load_slot_3.pressed.connect(_on_load_game_pressed.bind(2))

	show_main_menu()
	animation_player.animation_finished.connect(_on_animation_finshed)
	
	setup_button_audio()

## 切回标题主菜单。
func show_main_menu() -> void:
	main_menu.visible = true
	new_game_menu.visible = false
	load_game_menu.visible = false
	new_game_button.grab_focus()


## 展示新游戏菜单，并根据存档存在与否更新按钮文案。
func show_new_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = true
	load_game_menu.visible = false

	start_slot_1.grab_focus()

	var game_manager = _get_game_manager()
	if game_manager == null:
		return

	start_slot_1.text = "Replace Slot 01" if game_manager.save_file_exists(0) else "Begin Slot 01"
	start_slot_2.text = "Replace Slot 02" if game_manager.save_file_exists(1) else "Begin Slot 02"
	start_slot_3.text = "Replace Slot 03" if game_manager.save_file_exists(2) else "Begin Slot 03"


## 展示读档菜单，并禁用不存在存档的槽位按钮。
func show_load_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = false
	load_game_menu.visible = true

	load_slot_1.grab_focus()

	var game_manager = _get_game_manager()
	if game_manager == null:
		load_slot_1.disabled = true
		load_slot_2.disabled = true
		load_slot_3.disabled = true
		return

	load_slot_1.disabled = not game_manager.save_file_exists(0)
	load_slot_2.disabled = not game_manager.save_file_exists(1)
	load_slot_3.disabled = not game_manager.save_file_exists(2)


## 在子菜单下按取消键时返回主菜单。
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not main_menu.visible:
		show_main_menu()


## 选择新游戏槽位后，把槽位和进入模式通过 ScreenData 传给 GameScreen。
func _on_new_game_pressed(slot: int) -> void:
	screen_data = ScreenData.build() \
		.set_slot(slot) \
		.set_enter_mode(ScreenData.EnterMode.NEW_GAME)
	transiton_screen(EmoGame.ScreenType.GAME_SCREEN, screen_data)


## 选择读档槽位后，把槽位和进入模式通过 ScreenData 传给 GameScreen。
func _on_load_game_pressed(slot: int) -> void:
	screen_data = ScreenData.build() \
		.set_slot(slot) \
		.set_enter_mode(ScreenData.EnterMode.LOAD_GAME)
	transiton_screen(EmoGame.ScreenType.GAME_SCREEN, screen_data)

func setup_button_audio() -> void :
	for c in find_children("*", "Button"):
		c.focus_entered.connect( _play_focus_audio )
		c.pressed.connect( _play_select_audio )

## 标题动画播完开场段后切到循环动画。
func _on_animation_finshed(anim_name: String) -> void:
	if anim_name == "start":
		animation_player.play("loop")


## 统一从场景树中获取自动加载的游戏管理器，兼容脚本测试环境。
func _get_game_manager() -> Node:
	return get_tree().root.get_node_or_null("GameManager")


## 统一从场景树中获取全局 Audio 自动加载。
func _get_audio() -> Node:
	return get_tree().root.get_node_or_null("Audio")


## 播放按钮聚焦音效。
func _play_focus_audio() -> void:
	var audio := _get_audio()
	if audio != null:
		audio.play_ui(0)


## 播放按钮确认音效。
func _play_select_audio() -> void:
	var audio := _get_audio()
	if audio != null:
		audio.play_ui(1)
