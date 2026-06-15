class_name PatrolEnemy extends CharacterBody2D

## 巡逻型敌人

@export var move_speed: float = 50.0
@export var patrol_range: float = 100.0
@export var damage: int = 1
@export var health: int = 2
@export var score_value: int = 100

var start_position: Vector2
var direction: float = 1.0
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_area: Area2D = $HitArea

signal enemy_died(enemy: PatrolEnemy)
signal enemy_hit(enemy: PatrolEnemy)

func _ready() -> void:
	start_position = global_position
	add_to_group("enemies")
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 巡逻移动
	velocity.x = direction * move_speed

	# 到达巡逻边界时转向
	if global_position.x > start_position.x + patrol_range:
		direction = -1.0
		sprite.scale.x = abs(sprite.scale.x) * direction
	elif global_position.x < start_position.x - patrol_range:
		direction = 1.0
		sprite.scale.x = abs(sprite.scale.x) * direction

	# 检测边缘（前方没有地面则转向）
	if is_on_wall():
		direction *= -1
		sprite.scale.x = abs(sprite.scale.x) * direction

	move_and_slide()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body is PlatformerPlayer:
		var player: PlatformerPlayer = body as PlatformerPlayer
		# 玩家从上方落下踩到敌人 → 踩杀
		if player.velocity.y > 0 and player.global_position.y < global_position.y:
			player.velocity.y = -300.0  # 弹跳
			take_damage(1)
		else:
			player.take_damage(damage)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	enemy_hit.emit(self)
	if health <= 0:
		die()
	else:
		# 受伤反馈
		if animation_player and animation_player.has_animation("hurt"):
			animation_player.play("hurt")
		else:
			sprite.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			sprite.modulate = Color.WHITE

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	set_collision_layer_value(3, false)
	set_collision_mask_value(2, false)
	enemy_died.emit(self)

	# 找到玩家加分数
	var player: PlatformerPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.add_score(score_value)

	# 死亡动画后销毁
	if animation_player and animation_player.has_animation("die"):
		animation_player.play("die")
		await animation_player.animation_finished
	queue_free()
