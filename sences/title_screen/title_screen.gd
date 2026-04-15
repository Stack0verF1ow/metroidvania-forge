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

func _ready() -> void:
	new_game_button.pressed.connect( show_new_game_menu )
	load_game_button.pressed.connect( show_load_game_menu )
	
	start_slot_1.pressed.connect( _on_new_game_pressed.bind(0) )
	start_slot_2.pressed.connect( _on_new_game_pressed.bind(1) )
	start_slot_3.pressed.connect( _on_new_game_pressed.bind(2) )
	
	load_slot_1.pressed.connect( _on_load_game_pressed.bind(0) )
	load_slot_2.pressed.connect( _on_load_game_pressed.bind(1) )
	load_slot_3.pressed.connect( _on_load_game_pressed.bind(2) )
	
	show_main_menu()
	animation_player.animation_finished.connect( _on_animation_finshed )

func show_main_menu() -> void :
	main_menu.visible = true
	new_game_menu.visible = false
	load_game_menu.visible = false
	new_game_button.grab_focus()

func show_new_game_menu() -> void:
	main_menu.visible = false 
	new_game_menu.visible = true
	load_game_menu.visible = false
	
	start_slot_1.grab_focus()
	
	if GameManager.save_file_exists( 0 ):
		start_slot_1.text = "Replace Slot 01"
	if GameManager.save_file_exists( 1 ):
		start_slot_2.text = "Replace Slot 02"
	if GameManager.save_file_exists( 2 ):
		start_slot_3.text = "Replace Slot 03"

func show_load_game_menu() -> void:
	main_menu.visible = false 
	new_game_menu.visible = false
	load_game_menu.visible = true
	
	load_slot_1.grab_focus()
	
	load_slot_1.disabled = not GameManager.save_file_exists( 0 )
	load_slot_2.disabled = not GameManager.save_file_exists( 1 )
	load_slot_3.disabled = not GameManager.save_file_exists( 2 )
	

func _unhandled_input( event : InputEvent )-> void:
	if event.is_action_pressed( "ui_cancel" ):
		if main_menu.visible == false:
			# Audio
			show_main_menu()

func _on_new_game_pressed( slot : int ) -> void:
	
	screen_data = ScreenData.build().set_slot(slot)
	transiton_screen(EmoGame.ScreenType.GAME_SCREEN, screen_data)
	

func _on_load_game_pressed( slot : int ) -> void:
	pass

func _on_animation_finshed( anim_name: String ) -> void:
	if anim_name == "start":
		animation_player.play("loop") 
