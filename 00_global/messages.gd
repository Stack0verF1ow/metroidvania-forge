extends Node

signal player_interacted( player : Player )
signal player_healed( amount : int )
signal player_death()
signal input_hints_changed( hint : String )
signal player_health_changed( hp: float, max_hp: float )
signal back_to_title()
