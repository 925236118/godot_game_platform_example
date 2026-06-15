class_name Coin extends Area2D

## 金币收集品

@export var value: int = 1
@export var score_value: int = 50
@export var respawn_time: float = 0.0  # 0=不重生

var is_collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal item_collected(coin: Coin)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("collectibles")

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is PlatformerPlayer:
		collect(body)

func collect(player: PlatformerPlayer) -> void:
	is_collected = true
	player.add_coin(value)
	player.add_score(score_value)
	item_collected.emit(self)

	# 隐藏碰撞和视觉
	collision_shape.set_deferred("disabled", true)
	if animation_player and animation_player.has_animation("collect"):
		animation_player.play("collect")
		await animation_player.animation_finished
	else:
		hide()

	# 重生逻辑
	if respawn_time > 0.0:
		await get_tree().create_timer(respawn_time).timeout
		respawn()
	else:
		queue_free()

func respawn() -> void:
	is_collected = false
	collision_shape.disabled = false
	show()
	if animation_player and animation_player.has_animation("default"):
		animation_player.play("default")
