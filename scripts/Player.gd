class_name PlatformerPlayer extends CharacterBody2D

## 移动参数
@export var speed: float = 200.0
@export var acceleration: float = 1800.0
@export var friction: float = 1200.0
@export var air_resistance: float = 400.0
@export var gravity: float = 1200.0
@export var jump_velocity: float = -400.0

## 高级跳跃参数
@export var variable_jump_multiplier: float = 0.5
@export var coyote_time: float = 0.1
@export var jump_buffer: float = 0.1

## 冲刺参数
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15

## 蹬墙跳参数
@export var wall_jump_force_x: float = 300.0
@export var wall_jump_force_y: float = -300.0
@export var wall_slide_speed: float = 60.0

## 二段跳
@export var max_jumps: int = 1  # 额外跳跃次数（1=二段跳）

## 血量
@export var max_health: int = 3

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	WALL_SLIDING,
	WALL_JUMP,
	DASHING,
	HURT,
	DEAD
}

var current_state: State = State.IDLE
var input_direction: float = 0.0
var current_health: int = 3
var was_on_floor: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jumps_left: int = 0
var can_dash: bool = true
var dash_timer: float = 0.0
var dash_direction: float = 1.0
var is_invincible: bool = false
var coins_collected: int = 0
var score: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal health_changed(current: int, max_hp: int)
signal player_died()
signal coin_collected(total: int)
signal score_changed(points: int)

func _ready() -> void:
	current_health = max_health
	jumps_left = max_jumps
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	handle_input()
	update_timers(delta)
	apply_gravity(delta)
	apply_movement(delta)
	check_state_transitions(delta)
	move_and_slide()
	update_animation()
	update_sprite_direction()

func handle_input() -> void:
	input_direction = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer

	if Input.is_action_just_pressed("dash") and can_dash and current_state != State.DASHING:
		enter_dash_state()

func update_timers(delta: float) -> void:
	if is_on_floor():
		was_on_floor = true
		coyote_timer = coyote_time
		jumps_left = max_jumps
		can_dash = true
	else:
		if coyote_timer > 0.0:
			coyote_timer -= delta
			if coyote_timer <= 0.0:
				coyote_timer = 0.0
				was_on_floor = false

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

func apply_gravity(delta: float) -> void:
	if not is_on_floor() and current_state != State.DASHING:
		velocity.y += gravity * delta
		if velocity.y > 900.0:
			velocity.y = 900.0

func apply_movement(delta: float) -> void:
	if current_state == State.DASHING:
		return
	if current_state == State.WALL_JUMP:
		return
	if current_state == State.HURT:
		return

	# 地面移动
	if is_on_floor():
		if input_direction != 0.0:
			velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		# 空中控制（降低加速度）
		if input_direction != 0.0:
			velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * 0.65 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, air_resistance * delta)

	# 跳跃处理
	if jump_buffer_timer > 0.0:
		try_jump()

	# 可变跳跃高度
	if current_state == State.JUMP and not Input.is_action_pressed("jump") and velocity.y < 0.0:
		velocity.y *= variable_jump_multiplier

func try_jump() -> void:
	if coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		current_state = State.JUMP
		return

	# 蹬墙跳
	if is_on_wall() and not is_on_floor():
		var wall_normal: float = get_wall_normal().x
		velocity.x = wall_normal * wall_jump_force_x
		velocity.y = wall_jump_force_y
		current_state = State.WALL_JUMP
		jump_buffer_timer = 0.0
		return

	# 二段跳
	if jumps_left > 0:
		velocity.y = jump_velocity * 0.9
		jumps_left -= 1
		jump_buffer_timer = 0.0
		current_state = State.JUMP

func check_state_transitions(delta: float) -> void:
	# 墙壁检测
	if is_on_wall() and not is_on_floor() and velocity.y >= 0.0 \
		and input_direction != 0.0:
		var wall_normal: float = get_wall_normal().x
		if input_direction == wall_normal:
			current_state = State.WALL_SLIDING
			velocity.y = min(velocity.y, wall_slide_speed)

	# 落地检测
	if is_on_floor():
		if current_state in [State.JUMP, State.FALL, State.WALL_SLIDING, State.WALL_JUMP]:
			current_state = State.LANDING if velocity.length() < 10.0 else State.RUNNING

	# 跳跃→下落
	if current_state == State.JUMP and velocity.y >= 0.0:
		current_state = State.FALL

	# 冲刺结束
	if current_state == State.DASHING:
		dash_timer -= delta
		if dash_timer <= 0.0:
			current_state = State.FALL if not is_on_floor() else State.RUNNING
			velocity.x *= 0.3
			collision_shape.disabled = false

	# 被击退结束
	if current_state == State.HURT:
		if is_on_floor() and abs(velocity.x) < 10.0:
			current_state = State.IDLE

	# idle ↔ running (地面状态)
	if is_on_floor() and current_state not in [State.LANDING, State.HURT]:
		if input_direction == 0.0 and abs(velocity.x) < 10.0:
			current_state = State.IDLE
		elif input_direction != 0.0:
			current_state = State.RUNNING

func enter_dash_state() -> void:
	if not can_dash:
		return
	can_dash = false
	dash_timer = dash_duration
	dash_direction = input_direction if input_direction != 0.0 else (1.0 if sprite.scale.x >= 0 else -1.0)
	velocity.x = dash_direction * dash_speed
	velocity.y = 0.0
	current_state = State.DASHING
	# 冲刺时禁用碰撞形状短暂穿过敌人
	collision_shape.disabled = true

func take_damage(amount: int = 1) -> void:
	if is_invincible or current_state == State.DEAD:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()
	else:
		# 受伤击退
		var knock_dir: float = -1.0 if sprite.scale.x >= 0 else 1.0
		velocity.x = knock_dir * 200.0
		velocity.y = -200.0
		current_state = State.HURT
		start_invincibility()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	player_died.emit()

func start_invincibility() -> void:
	is_invincible = true
	# 闪烁效果
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.set_loops(5)
	get_tree().create_timer(1.0).timeout.connect(func(): 
		is_invincible = false
		sprite.modulate.a = 1.0
	)

func add_coin(value: int = 1) -> void:
	coins_collected += value
	coin_collected.emit(coins_collected)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func update_animation() -> void:
	if current_state == State.DEAD:
		animation_player.play("dead")
	elif current_state == State.DASHING:
		animation_player.play("dash")
	elif current_state == State.WALL_SLIDING:
		animation_player.play("wall_slide")
	elif not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		else:
			animation_player.play("fall")
	elif current_state == State.RUNNING:
		animation_player.play("run")
	elif current_state == State.HURT:
		animation_player.play("hurt")
	else:
		animation_player.play("idle")

func update_sprite_direction() -> void:
	if input_direction != 0.0:
		sprite.scale.x = abs(sprite.scale.x) * sign(input_direction)

func respawn() -> void:
	current_health = max_health
	current_state = State.IDLE
	velocity = Vector2.ZERO
	is_invincible = false
	sprite.modulate.a = 1.0
	jumps_left = max_jumps
	can_dash = true
	health_changed.emit(current_health, max_health)
