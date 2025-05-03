class_name Angel
extends CharacterBody2D

signal health_change
signal lifes_change
signal player_puts_new_portal

@export var sprites : Texture2D

@onready var animation_tree = $AnimationTree
@onready var hurt_box = $Hurtbox
@onready var state_machine = animation_tree.get('parameters/playback')

@export var input_prefix: String = "p1"
@export var enemy_input_prefix: String = "p2"

@export var SPEED = 500.0
@export var JUMP_VELOCITY = -1000.0
@export var max_jump_count = 2

@export var max_health = 100
@onready var health = max_health
var lifes = 3

var is_frozen = false

var knockback : Vector2 = Vector2.ZERO
var knockback_timer = 0.0

var attack_count = 0
var attack_timer = 0.0

var blocking = false
var parrying = false

var orbit_radius = 180.0
var orbit_angle = 0.0
var orbit_speed = 20.0

var curr_jump_count = 0

var can_be_attacked_by_enemy = false

func _ready() -> void:
	$Sprite2D.texture = sprites
	hurt_box.connect("body_entered", Callable(self, "_on_body_entered"))
	hurt_box.connect("body_exited", Callable(self, "_on_body_exited"))
	$parryboxArea.visible = false
	
func _on_body_entered(body: Node2D) -> void:
	if body is Angel and body != self:
		can_be_attacked_by_enemy = true
		
func _on_body_exited(body: Node2D) -> void:
	if body is Angel and body != self:
		can_be_attacked_by_enemy = false

func _physics_process(delta: float) -> void:
	handle_x_axis_movement(delta)
	handle_y_axis_movement(delta)
	reset_position_if_outside_map()
	handle_knockback(delta)
	#handle_create_new_portal()
	swing_door(delta)
	handle_block()
	move_and_slide()
	reset_after_parry(delta)
	
func swing_door(delta) -> void:
	if knockback_timer > 0.0:
		return
	var pressed_attack = Input.is_action_just_pressed("attack_"+input_prefix)
	if pressed_attack and attack_timer == 0.0:
		if not blocking:
			attack_count = 0
			attack_timer = 0.5
			if $Sprite2D.flip_h:
				orbit_angle = -0.5
			else:
				orbit_angle = 3.5
		else:
			if $parryboxArea/ParryTime.is_stopped() and $parryboxArea/cooldown.is_stopped():
				$parryboxArea.visible = true
				$parryboxArea/ParryTime.start()
				print("Parry!")
				parrying = true
				
				
	
	if attack_timer > 0.0:
		var overlapping_bodies = $DoorBox.get_overlapping_bodies()
		if attack_timer > 0.2 and attack_timer < 0.4:
			for body in overlapping_bodies:
				if body is Angel and body != self:
					if attack_count == 0:
						var direction
						if $Sprite2D.flip_h:
							direction = Vector2(-1.0,-1.0)
						else:
							direction = Vector2(1.0,-1.0)
						if not body.parrying:
							body.apply_knockback(direction, 250+2500/max(body.health,20), 0.25+1.0/max(body.health,20))
							if not body.blocking:
								body.player_gets_hurt()
								body.apply_knockback(direction, 1.2*(400+15000/max(body.health,15)), (0.25+1.0/max(body.health,15)))
								body.start_particles()
						else:
							attack_timer = -1.0
							modulate = Color(0.3, 0.3, 0.3)
						attack_count += 1
		if $Sprite2D.flip_h and attack_timer <= 0.4:
			orbit_angle = maxf(orbit_angle -orbit_speed*delta, -3.5)
		elif attack_timer <= 0.4:
			orbit_angle = minf(orbit_angle + orbit_speed*delta, 6.5)
		var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		$DoorBox.position = offset
		$DoorBox/Sprite2D.rotation = offset.angle() + PI / 2
		attack_timer -= delta
	else:
		if not blocking:
			$DoorBox.position = Vector2(100*(sign(2*int($Sprite2D.flip_h)-1)), -orbit_radius)
		$DoorBox/Sprite2D.rotation = 0.5 - (1-float($Sprite2D.flip_h))
		
func handle_x_axis_movement(delta):
	if knockback_timer > 0.0:
		return
	var direction := Input.get_axis("move_left_"+input_prefix, "move_right_"+input_prefix)
	if direction:
		moving_character_left(delta, direction)
	elif !is_on_floor():
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x)/20)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		state_machine.travel("idle")
	
func moving_character_left(delta, direction):
	if is_frozen:
		return
	if not blocking:
		if direction == 1:
			if attack_timer <= 0.0:
				$Sprite2D.flip_h = false
			state_machine.travel("caminar_derecha")
		else:
			if attack_timer <= 0.0:
				$Sprite2D.flip_h = true
			state_machine.travel("caminar_derecha")
	var velocity_change
	if blocking:
		velocity_change = 0.0
	else:
		velocity_change = SPEED * direction * delta
	if abs(velocity.x) > SPEED:
		velocity.x = move_toward(velocity.x, velocity_change, abs(velocity.x)/20)
	else:
		velocity.x = SPEED * direction

func handle_y_axis_movement(delta):
	if knockback_timer > 0.0 or is_frozen:
		return
	var jump_pressed = Input.is_action_just_pressed("jump_"+input_prefix)
	var fall_pressed = Input.is_action_pressed("down_"+input_prefix)
	if not is_on_floor():
		velocity += get_gravity() * delta * 3
	if is_on_floor():
		curr_jump_count = 0
	if jump_pressed:
		character_jump()
	if fall_pressed:
		character_fall(delta)
	else:
		blocking = false

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

func character_fall(delta):
	if not is_on_floor():
		blocking = false
		if velocity.y < SPEED:
			velocity.y = SPEED
	else:
		if attack_timer <= 0.0 and knockback_timer <= 0.0:
			blocking = true
			velocity.x = 0.0
		else:
			blocking = false
			
func handle_block():
	if blocking:
		$DoorBox.position = Vector2(0.0, 0.0)
		$DoorBox.rotation = 0.0
		
func reset_after_parry(delta):
	if attack_timer < 0.0:
		attack_timer += min(delta, -attack_timer)
		if attack_timer == 0.0:
			modulate = Color(1, 1, 1)

func reset_position_if_outside_map():
	if (position.y > 900) or (position.x < -300) or (position.x > 1300):
		position.y = 70
		position.x = 520
		health = max_health
		lifes -= 1
		health_change.emit()
		lifes_change.emit()
		end_game_if_player_has_no_life()
		
func player_gets_hurt():
	health -= 10
	health_change.emit()
	$AudioStreamPlayer2D.play()
	if health <= 0:
		lifes -= 1
		position.y = 70
		position.x = 520
		health = max_health
		lifes_change.emit()
	end_game_if_player_has_no_life()

func handle_knockback(delta):
	if knockback_timer > 0.0:
		velocity = knockback
		knockback += get_gravity() * delta * 3
		knockback_timer -= delta
		
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO

func apply_knockback(direction: Vector2, force: float, knockback_duration: float):
	knockback = direction * force
	knockback_timer = knockback_duration

func handle_create_new_portal():	
	var jump_pressed = Input.is_action_just_pressed("portal_"+input_prefix)
	if jump_pressed:
		player_puts_new_portal.emit()
		#player_has_door.emit()

func set_character_position(x: int, y:int):
	position.x = x
	position.y = y
	is_frozen = true
	await get_tree().create_timer(0.2).timeout
	is_frozen = false
		
func end_game_if_player_has_no_life():
	if lifes <= 0:
		get_node("../../Game_Over").game_over()


func _on_parry_time_timeout():
	$parryboxArea.visible = false
	parrying = false
	$parryboxArea/cooldown.start()

func start_particles():
	$GPUParticles2D.emitting = true
	$GPUParticles2D/ParticleTimer.start()

func _on_particle_timer_timeout():
	$GPUParticles2D.emitting = false
