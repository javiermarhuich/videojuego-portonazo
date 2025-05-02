class_name Angel
extends CharacterBody2D

signal health_change
signal player_has_door
signal player_puts_new_portal

@onready var animation_tree = $AnimationTree
@onready var hurt_box = $Hurtbox
@onready var state_machine = animation_tree.get('parameters/playback')

@export var input_prefix: String = "p1"

@export var SPEED = 500.0
@export var JUMP_VELOCITY = -1000.0
@export var max_jump_count = 2

@export var max_health = 100
@onready var health = max_health

var has_door = true
var is_frozen = false

var knockback : Vector2 = Vector2.ZERO
var knockback_timer = 0.0

var curr_jump_count = 0

func _ready() -> void:
	hurt_box.connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body: Node2D) -> void:
	if body is Angel:
		player_gets_hurt()

func _physics_process(delta: float) -> void:
	handle_x_axis_movement()
	handle_y_axis_movement(delta)
	reset_position_if_outside_map()
	handle_knockback(delta)
	handle_create_new_portal()
	move_and_slide()
	
func handle_x_axis_movement():
	if knockback_timer > 0.0:
		return
	var direction := Input.get_axis("move_left_"+input_prefix, "move_right_"+input_prefix)
	if direction:
		moving_character_left(direction)
	elif !is_on_floor():
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x)/20)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		state_machine.travel("idle")
	
func moving_character_left(direction):
	if is_frozen:
		return
	if direction == 1:
		state_machine.travel("caminar_derecha")
	else:
		state_machine.travel("caminar_izquierda")
	velocity.x = SPEED * direction

func handle_y_axis_movement(delta):
	if knockback_timer > 0.0 or is_frozen:
		return
	var jump_pressed = Input.is_action_just_pressed("jump_"+input_prefix)
	var fall_pressed = Input.is_action_just_pressed("down_"+input_prefix)
	if not is_on_floor():
		velocity += get_gravity() * delta * 3
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
		health = 0 #max_health
		health_change.emit()
		end_game_if_player_has_no_life()
		
func player_gets_hurt():
	health -= 10
	health_change.emit()
	end_game_if_player_has_no_life()

func handle_knockback(delta):
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO

func apply_knockback(direction: Vector2, force: float, knockback_duration: float):
	knockback = direction * force
	knockback_timer = knockback_duration

func handle_create_new_portal():
	var jump_pressed = Input.is_action_just_pressed("ui_text_completion_replace")
	if jump_pressed and has_door:
		has_door = false
		player_puts_new_portal.emit()
		player_has_door.emit()

func set_character_position(x: int, y:int):
	position.x = x
	position.y = y
	is_frozen = true
	await get_tree().create_timer(0.2).timeout
	is_frozen = false

func set_character_has_door_true():
	if has_door == false:
		has_door = true
		player_has_door.emit()
		
func end_game_if_player_has_no_life():
	if health <= 0:
		get_node("../../Game_Over").game_over()
