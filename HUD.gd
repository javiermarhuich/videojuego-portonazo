extends Control

@export var jugador_angel : Angel
@export var angel_door : Sprite2D

#@export var jugador_demonio : Demonio


func _ready() -> void:
	jugador_angel.player_has_door.connect(show_angel_has_door)
	show_angel_has_door()

func show_angel_has_door():
	if jugador_angel.has_door:
		angel_door.visible = true
	else:
		angel_door.visible = false

#func update(): 
#	value = player.health * 100 / player.max_health
