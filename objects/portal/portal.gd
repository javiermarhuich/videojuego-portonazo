extends Area2D
class_name Portal

signal player_crossed

@onready var collision = $CollisionShape2D

var X_AXIS_START = 50
var X_AXIS_END = 1000
var Y_AXIS_START = 50
var Y_AXIS_END = 400
var PLAYER_BORDER_LIMIT = 200

func _ready() -> void:
	collision.disabled = true
	await get_tree().create_timer(0.2).timeout
	collision.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is Angel:
		move_character_and_destroy_portal(body)
		
func move_character_and_destroy_portal(body):
	player_crossed.emit()
	var position = generate_position(body)
	body.set_character_position(position[0], position[1])
	queue_free()
 
func generate_position(body):
	var curr_pos_x = body.position.x
	var curr_pos_y = body.position.y
	var random = RandomNumberGenerator.new()
	var position_x = generate_position_x(random, curr_pos_x)
	var position_y = generate_position_y(random, curr_pos_x)
	return [position_x, position_y]
	
func generate_position_x(random, limit_position):
	var posibility_1 = random.randi_range(X_AXIS_START, limit_position - PLAYER_BORDER_LIMIT)
	var posibility_2 = random.randi_range(limit_position + PLAYER_BORDER_LIMIT, X_AXIS_END)
	var alternative = [posibility_1, posibility_2]
	#print("x:", alternative)
	if limit_position <= PLAYER_BORDER_LIMIT or posibility_1 <= X_AXIS_START:
		#print("X chose", posibility_2)
		return posibility_2
	elif limit_position >= X_AXIS_END - PLAYER_BORDER_LIMIT or posibility_2 >= X_AXIS_END:
		#print("X chose", posibility_1)
		return posibility_1
	else:
		var chosen = alternative[randi() % 2]
		#print("X chose", chosen)
		return chosen
	
func generate_position_y(random, limit_position):
	var posibility_1 = random.randi_range(Y_AXIS_START, limit_position - PLAYER_BORDER_LIMIT)
	var posibility_2 = random.randi_range(limit_position + PLAYER_BORDER_LIMIT, Y_AXIS_END)
	var alternative = [posibility_1, posibility_2]
	#print("y:", alternative)	
	if limit_position <= PLAYER_BORDER_LIMIT or posibility_1 <= Y_AXIS_START:
		#print("Y chose", posibility_2)
		return posibility_2
	elif limit_position >= Y_AXIS_END - PLAYER_BORDER_LIMIT or posibility_2 >= Y_AXIS_END:
		#print("Y chose", posibility_1)
		return posibility_1
	else:
		var chosen = alternative[randi() % 2]
		#print("Y chose", chosen)
		return chosen
	
