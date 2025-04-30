#extends Area2D
extends RigidBody2D

@onready var progress_bar = $ProgressBar
@onready var hurt_box = $Area2D
@export var max_health:int
@onready var health = max_health

func _ready() -> void:
	progress_bar.max_value = max_health
	progress_bar.value = health
	hurt_box.connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body: Node2D) -> void:
	if body is Angel:
		#target_attacks_player(body)
		target_gets_hurt()

func target_gets_hurt():
	health -= 1
	if health > 0:
		progress_bar.value = health
	else:
		queue_free()
		
# Aplicar Knockback
func target_attacks_player(body):
	var knockback_direction = (body.global_position - global_position).normalized()
	body.apply_knockback(knockback_direction, 800, .3)
