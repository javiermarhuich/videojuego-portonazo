extends Node2D

var portal = preload("res://objects/portal/Portal.tscn")

func _ready() -> void:
	$Nivel_jugable/Jugador1.input_prefix = "p1"
	$Nivel_jugable/Jugador2.input_prefix = "p2"
	$Nivel_jugable/Jugador1.player_puts_new_portal.connect(create_new_portal.bind($Nivel_jugable/Jugador1))
	$Nivel_jugable/Jugador2.player_puts_new_portal.connect(create_new_portal.bind($Nivel_jugable/Jugador2))

func create_new_portal(player):
	var new_portal = portal.instantiate() as Portal
	$Nivel_jugable.add_child(new_portal)
	new_portal.z_index = 1
	new_portal.global_position = Vector2(player.position.x + 30, player.position.y)
