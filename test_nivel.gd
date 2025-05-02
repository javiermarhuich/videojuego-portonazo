extends Node2D

var portal = preload("res://objects/portal/Portal.tscn")
var door = preload("res://objects/door/door.tscn")

@export var jugador_angel : Angel

func _ready() -> void:
	jugador_angel.player_puts_new_portal.connect(create_new_portal)
	# Cuando se agregue el otro jugador
	#angel.player_puts_new_portal.connect(create_new_portal_for_player.bind(angel))
	#demon.player_puts_new_portal.connect(create_new_portal_for_player.bind(demon))

func create_new_door():
	call_deferred("_create_new_door_safe")

func _create_new_door_safe():
	var new_door = door.instantiate()
	add_child(new_door)
	new_door.global_position = Vector2(jugador_angel.position.x + 50, jugador_angel.position.y)

func create_new_portal(): #(player):
	var new_portal = portal.instantiate() as Portal
	add_child(new_portal)
	new_portal.player_crossed.connect(create_new_door, CONNECT_ONE_SHOT)
	#new_portal.player_crossed.connect(create_new_door_for_player.bind(player))
	new_portal.global_position = Vector2(jugador_angel.position.x + 30, jugador_angel.position.y)
