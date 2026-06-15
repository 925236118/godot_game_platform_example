class_name OneWayPlatform extends AnimatableBody2D

## 单向平台 - 可从下方穿过，上方站立

@export var drop_time: float = 0.5

var can_stand: bool = true

func _ready() -> void:
	collision_layer = 1  # 默认碰撞层
	add_to_group("platforms")

func drop(player: CharacterBody2D) -> void:
	if not can_stand:
		return
	can_stand = false
	collision_layer = 0  # 临时禁用
	await get_tree().create_timer(drop_time).timeout
	collision_layer = 1
	can_stand = true
