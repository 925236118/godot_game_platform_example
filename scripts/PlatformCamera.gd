class_name PlatformCamera extends Camera2D

## 平台跳跃相机系统

@export var follow_target: Node2D
@export var follow_speed: float = 8.0
@export var look_ahead_distance: float = 100.0
@export var look_ahead_speed: float = 3.0
@export var vertical_follow_weight: float = 0.5

var look_ahead_offset: float = 0.0
var last_target_x: float = 0.0
var shake_timer: float = 0.0
var shake_intensity: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not follow_target:
		follow_target = get_parent().get_node("Player") as Node2D

func _process(delta: float) -> void:
	if not follow_target:
		return

	var player: PlatformerPlayer = follow_target as PlatformerPlayer
	if not player:
		return

	# 水平视线提前（面向移动方向）
	var direction: float = sign(player.velocity.x)
	if player.velocity.x != 0.0:
		last_target_x = direction

	var target_offset: float = last_target_x * look_ahead_distance
	look_ahead_offset = lerp(look_ahead_offset, target_offset, look_ahead_speed * delta)

	# 目标位置
	var target_pos: Vector2 = follow_target.global_position
	target_pos.x += look_ahead_offset
	target_pos.y = lerp(global_position.y, follow_target.global_position.y, vertical_follow_weight)

	# 平滑插值
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# 震屏更新
	update_shake(delta)

func trigger_shake(intensity: float = 10.0, duration: float = 0.2) -> void:
	shake_intensity = intensity
	shake_timer = duration

func update_shake(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		offset = shake_offset
	else:
		offset = Vector2.ZERO
		shake_timer = 0.0
