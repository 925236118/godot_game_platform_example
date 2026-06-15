class_name SurvivorEnemy extends CharacterBody2D

@export var move_speed: float = 60.0
@export var hp: float = 20.0
@export var max_hp: float = 20.0
@export var damage: float = 8.0
@export var xp_value: int = 5

var player_ref: Node2D = null
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not player_ref:
		return
	var dir: Vector2 = global_position.direction_to(player_ref.global_position)
	move_and_collide(dir * move_speed * delta)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	hp -= amount
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	if is_dead:
		return
	sprite.modulate = Color.WHITE
	if hp <= 0:
		die()

func die() -> void:
	is_dead = true
	# 掉落XP
	var gem_scene: PackedScene = preload("res://scenes/XPGem.tscn")
	if gem_scene:
		var gem: Node2D = gem_scene.instantiate()
		gem.global_position = global_position
		gem.set("xp_amount", xp_value)
		add_sibling(gem)
	queue_free()