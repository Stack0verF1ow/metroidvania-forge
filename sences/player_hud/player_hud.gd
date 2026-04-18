extends CanvasLayer


@onready var hp_margin_container: MarginContainer = %HPMarginContainer
@onready var hp_bar: TextureProgressBar = %HPBar
@onready var game_over: Control = %GameOver
@onready var load_button: Button = %LoadButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	Messages.player_health_changed.connect( update_health_bar )
	
	game_over.visible = false
	load_button.pressed.connect( _on_load_pressed )
	quit_button.pressed.connect( _on_quit_pressed )

func update_health_bar( hp: float, max_hp: float ) -> void:
	var value  : float = ( hp / max_hp ) * 100 
	hp_bar.value = value
	hp_margin_container.size.x = max_hp + 22

func _on_load_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	pass
