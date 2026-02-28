class_name ScreenEffect
extends CanvasLayer

@onready var fade: Control = %Fade

const DOUBLE_SCREEN_SIZE : Vector2 = Vector2( 960, 540 )

func first_load() -> void:
	fade.visible = false

func fade_in( dir: String ) -> void:
	var fade_pos : Vector2 = get_fade_pos( dir )
	fade.visible = true
	await fade_screen( fade_pos, Vector2.ZERO )
	fade.visible = false

func fade_out( dir: String ) -> void:
	var fade_pos : Vector2 = get_fade_pos( dir )
	fade.visible = true
	await fade_screen( Vector2.ZERO, -fade_pos )
	fade.visible = false

func fade_screen( from: Vector2, to: Vector2 ) -> Signal:
	fade.position = from
	var tween : Tween = create_tween()
	tween.tween_property(fade, "position", to, 0.2 )
	return tween.finished

func get_fade_pos( dir: String ) -> Vector2:
	
	var pos : Vector2
	
	match dir:
		"left": 
			pos = DOUBLE_SCREEN_SIZE * Vector2.LEFT
		"right": 
			pos = DOUBLE_SCREEN_SIZE * Vector2.RIGHT
		"up": 
			pos = DOUBLE_SCREEN_SIZE * Vector2.UP
		"down": 
			pos = DOUBLE_SCREEN_SIZE * Vector2.DOWN
	
	return pos
