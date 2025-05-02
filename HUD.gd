extends CanvasLayer

@export var jugador_p1 : Angel
@export var jugador_p2 : Angel

@onready var p1_vida_1 = $Control/p1_vida_1
@onready var p1_vida_2 = $Control/p1_vida_2
@onready var p1_vida_3 = $Control/p1_vida_3

@onready var p2_vida_1 = $Control2/p2_Vida_1
@onready var p2_vida_2 = $Control2/p2_Vida_2
@onready var p2_vida_3 = $Control2/p2_Vida_3

#@export var jugador_demonio : Demonio

func _ready():
	jugador_p1.lifes_change.connect(show_p1_lifes)
	jugador_p2.lifes_change.connect(show_p2_lifes)
	show_p1_lifes()
	show_p2_lifes()

func show_p1_lifes():
	if jugador_p1.lifes == 2:
		p1_vida_3.visible = false
	if jugador_p1.lifes == 1:
		p1_vida_2.visible = false
	if jugador_p1.lifes == 0:
		p1_vida_1.visible = false

func show_p2_lifes():
	if jugador_p2.lifes == 2:
		p2_vida_3.visible = false
	if jugador_p2.lifes == 1:
		p2_vida_2.visible = false
	if jugador_p2.lifes == 0:
		p2_vida_1.visible = false
