class_name Angel
extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get('parameters/playback')

@export var SPEED = 500.0
@export var JUMP_VELOCITY = -500.0
@export var max_jump_count = 2

var curr_jump_count = 0

func _physics_process(delta: float) -> void:
	handle_x_axis_movement()
	handle_y_axis_movement(delta)
	reset_position_if_outside_map()
	move_and_slide()
	
func handle_x_axis_movement():
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		moving_character_left(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		state_machine.travel("idle")
	
func moving_character_left(direction):
	if direction == 1:
		state_machine.travel("caminar_derecha")
	else:
		state_machine.travel("caminar_izquierda")
	velocity.x = SPEED * direction

func handle_y_axis_movement(delta):
	var jump_pressed = Input.is_action_just_pressed("ui_accept")
	var fall_pressed = Input.is_action_just_pressed("ui_down")
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		curr_jump_count = 0
	if jump_pressed:
		character_jump()
	if fall_pressed:
		character_fall()

func character_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		curr_jump_count = 1
	else:
		if curr_jump_count < max_jump_count:
			velocity.y = JUMP_VELOCITY
			curr_jump_count += 1
		else:
			return

func character_fall():
	if not is_on_floor():
		velocity.y = SPEED
	else:
		return

func reset_position_if_outside_map():
	if (position.y > 800) or (position.x < -200) or (position.x > 1300):
		position.y = 70
		position.x = 520
