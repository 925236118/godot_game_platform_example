class_name SurvivorPlayer extends CharacterBody2D

@export var move_speed: float = 250.0
@export var max_hp: float = 100.0
@export var hp: float = 100.0
@export var base_damage: float = 10.0
@export var attack_cooldown: float = 0.8
@export var attack_range: float = 350.0
@export var pickup_range: float = 80.0
@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next: int = 15
@export var game_time: float = 0.0

var input_dir: Vector2 = Vector2.ZERO
var attack_timer: float = 0.0
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D

signal hp_changed(current: float, max_hp: float)
signal xp_changed(current: int, needed: int)
signal level_up(lvl: int)
signal player_died()

func _ready() -> void:
	add_to_group("player")
	xp_to_next = _calc_exp(level)

func _process(delta: float) -> void:
	if is_dead:
		return
	game_time += delta
	attack_timer -= delta

	# 自动攻击
	if attack_timer <= 0:
		auto_attack()
		attack_timer = attack_cooldown

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	var vel: Vector2 = input_dir * move_speed * delta
	move_and_collide(vel)
	update_sprite()
	# 自动拾取
	auto_pickup()

func auto_attack() -> void:
	# 找最近敌人
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = attack_range * attack_range
	for e in enemies:
		var enemy: Node2D = e as Node2D
		var dist: float = global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	if not nearest:
		return

	var dir: Vector2 = global_position.direction_to(nearest.global_position)
	var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
	if bullet_scene:
		var bullet: Area2D = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.set("direction", dir)
		bullet.set("damage", base_damage)
		bullet.set("speed", 400.0)
		add_sibling(bullet)

func auto_pickup() -> void:
	var xp_gems: Array[Node] = get_tree().get_nodes_in_group("xp_gems")
	for g in xp_gems:
		var gem: Node2D = g as Node2D
		if global_position.distance_to(gem.global_position) < pickup_range:
			# 飞向玩家
			gem.set("target", self)
			gem.set("is_flying", true)

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		do_level_up()
	xp_changed.emit(xp, xp_to_next)

func do_level_up() -> void:
	level += 1
	xp_to_next = _calc_exp(level)
	# 基础成长
	max_hp += 20.0
	hp = max_hp
	base_damage += 3.0
	move_speed += 5.0
	level_up.emit(level)

func _calc_exp(lvl: int) -> int:
	return int(pow(lvl, 1.8) * 5 + lvl * 20)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	hp -= amount
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		hp = 0
		die()

func die() -> void:
	is_dead = true
	player_died.emit()

func update_sprite() -> void:
	if input_dir.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)
	elif input_dir.x > 0:
		sprite.scale.x = abs(sprite.scale.x)