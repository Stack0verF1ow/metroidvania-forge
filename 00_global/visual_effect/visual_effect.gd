#VisualEffect script
extends Node

signal camera_shook( strength: float )

const DUST_EFFECT = preload("uid://bj6jwc21o6da7")


func _create_dust_effect( pos : Vector2 ) -> DustEffect:
	var dust : DustEffect = DUST_EFFECT.instantiate()
	add_child( dust )
	dust.global_position = pos
	return dust
	

func jump_dust( pos: Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.JUMP )
	
	
func land_dust( pos: Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.LAND )

func hit_dust( pos: Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.HIT )

func hit_particles() -> void:
	pass

func camera_shake( strength: float ) -> void:
	camera_shook.emit( strength )
	 
	
