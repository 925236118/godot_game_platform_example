class_name ArpgPlayer extends CharacterBody2D

## 玩家属性
@export var move_speed: float = 300.0
@export var max_hp: float = 100.0
@export var hp: float = 100.0
@export var max_mp: float = 50.0
@export var mp: float = 50.0
@export var attack_min: float = 8.0
@export var attack_max: float = 15.0
@export var attack_range: float = 50.0
@export var attack_rate: float = 0.5  # 攻击间隔（秒）
@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next: int = 50

## 闪避
@export var dodge_speed: float = 600.0
@export var dodge_duration: float = 0.2
@export var dodge_cooldown: float = 1.0

var input_dir: Vector2 = Vector2.ZERO
var attack_dir: Vector2 = Vector2.RIGHT
var attack_timer: float = 0.0
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_cd_timer: float = 0.0
var is_invincible: bool = false
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_visual: Sprite2D = $AttackArea/AttackVisual

signal hp_changed(current: float, max_hp: float)
signal mp_changed(current: float, max_mp: float)
signal xp_changed(current: int, needed: int)
signal level_up(level: int)
signal player_died()
signal dropped_coins(points: int)

func _ready() -> void:
	add_to_group("player")
	attack_area.body_entered.connect(_on_attack_hit)
	xp_to_next = _calc_exp_for_level(level)
	if attack_visual:
		attack_visual.hide()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 冷却更新
	if attack_timer > 0:
		attack_timer -= delta
	if dodge_cd_timer > 0:
		dodge_cd_timer -= delta

	# 闪避状态
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
		move_and_slide()
		return

	handle_input()
	var movement: Vector2 = input_dir * move_speed * delta
	move_and_collide(movement)
	update_sprite()

func handle_input() -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	# 攻击方向跟随最后移动方向
	if input_dir != Vector2.ZERO:
		attack_dir = input_dir

	# 攻击（空格或左键）
	if Input.is_action_just_pressed("attack") and attack_timer <= 0:
		attack()

	# 闪避
	if Input.is_action_just_pressed("dodge") and not is_dodging and dodge_cd_timer <= 0 and input_dir != Vector2.ZERO:
		start_dodge()

func attack() -> void:
	attack_timer = attack_rate

	# 将攻击区域对准攻击方向
	attack_area.position = attack_dir * attack_range * 0.5
	attack_area.rotation = attack_dir.angle()
	if attack_collision.shape is RectangleShape2D:
		var rect: RectangleShape2D = attack_collision.shape as RectangleShape2D
		rect.size = Vector2(attack_range, 40)
		attack_collision.shape = rect

	# 攻击动画
	if attack_visual:
		attack_visual.show()
	sprite.modulate = Color(1, 1, 0.8, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	if attack_visual:
		attack_visual.hide()

	# 攻击检测（已连接信号）

func start_dodge() -> void:
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cd_timer = dodge_cooldown
	is_invincible = true
	velocity = input_dir * dodge_speed

	# 闪避动画
	sprite.modulate.a = 0.5
	await get_tree().create_timer(dodge_duration).timeout
	is_invincible = false
	sprite.modulate.a = 1.0

func _on_attack_hit(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		var damage: float = randf_range(attack_min, attack_max)
		body.take_damage(damage, attack_dir)

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invincible or is_dead:
		return

	hp -= amount
	hp_changed.emit(hp, max_hp)

	if hp <= 0:
		hp = 0
		die()
	else:
		# 击退
		if knockback_dir != Vector2.ZERO:
			velocity = knockback_dir * 200.0
		# 受伤无敌
		is_invincible = true
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		is_invincible = false
		sprite.modulate = Color.WHITE

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up_player()
	xp_changed.emit(xp, xp_to_next)

func level_up_player() -> void:
	level += 1
	xp_to_next = _calc_exp_for_level(level)

	# 升级成长
	max_hp += 20.0
	hp = max_hp
	max_mp += 10.0
	mp = max_mp
	attack_min += 3.0
	attack_max += 5.0
	move_speed += 5.0

	hp_changed.emit(hp, max_hp)
	mp_changed.emit(mp, max_mp)
	level_up.emit(level)

func _calc_exp_for_level(lvl: int) -> int:
	return int(pow(lvl, 2.0) * 10 + lvl * 50)

func die() -> void:
	is_dead = true
	player_died.emit()

func heal(amount: float) -> void:
	hp = min(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func update_sprite() -> void:
	if input_dir != Vector2.ZERO:
		# 翻转朝向
		if input_dir.x < 0:
			sprite.scale.x = -abs(sprite.scale.x)
		elif input_dir.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
