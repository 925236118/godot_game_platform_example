class_name ArpgEnemy extends CharacterBody2D

## 敌人属性
@export var move_speed: float = 80.0
@export var hp: float = 30.0
@export var max_hp: float = 30.0
@export var damage: float = 10.0
@export var attack_rate: float = 1.0
@export var xp_reward: int = 15
@export var coin_drop: int = 5
@export var chase_range: float = 300.0
@export var stop_range: float = 30.0

var player_ref: ArpgPlayer = null
var attack_timer: float = 0.0
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ColorRect = $HPBar

func _ready() -> void:
	add_to_group("enemies")
	player_ref = get_tree().get_first_node_in_group("player") as ArpgPlayer
	if hp_bar:
		hp_bar.size.x = 30.0

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if attack_timer > 0:
		attack_timer -= delta

	# 击退衰减
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, delta * 10.0)
		if knockback_velocity.length() < 5.0:
			knockback_velocity = Vector2.ZERO

	# 追逐玩家
	if player_ref and not player_ref.is_dead:
		var dist: float = global_position.distance_to(player_ref.global_position)
		if dist < chase_range and dist > stop_range:
			var dir: Vector2 = global_position.direction_to(player_ref.global_position)
			var vel: Vector2 = dir * move_speed * delta
			move_and_collide(vel + knockback_velocity * delta)
			update_sprite(dir)
		elif dist <= stop_range and attack_timer <= 0:
			attack_player()

func update_sprite(dir: Vector2) -> void:
	if dir.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)
	elif dir.x > 0:
		sprite.scale.x = abs(sprite.scale.x)

func attack_player() -> void:
	if not player_ref:
		return
	attack_timer = attack_rate
	player_ref.take_damage(damage, global_position.direction_to(player_ref.global_position))

func take_damage(amount: float, from_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return

	hp -= amount
	update_hp_bar()

	# 击退
	if from_dir != Vector2.ZERO:
		knockback_velocity = from_dir * 300.0

	# 受伤闪白
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color.WHITE

	if hp <= 0:
		die()

func update_hp_bar() -> void:
	if hp_bar:
		var ratio: float = max(0, hp / max_hp)
		hp_bar.size.x = 30.0 * ratio

func die() -> void:
	is_dead = true

	# 奖励玩家
	if player_ref:
		player_ref.add_xp(xp_reward)
		player_ref.dropped_coins.emit(coin_drop)

	# 死亡效果
	sprite.modulate = Color(1, 0.3, 0.3, 0.5)
	set_collision_layer_value(3, false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
