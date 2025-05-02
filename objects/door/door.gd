extends Area2D
class_name Door

@onready var collision_shape = $CollisionShape2D 

func _ready():
	collision_shape.disabled = true
	await get_tree().create_timer(0.3).timeout
	collision_shape.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is Angel:
		set_character_door_and_destroy_item(body)
		
func set_character_door_and_destroy_item(body):
	body.set_character_has_door_true()
	queue_free()
