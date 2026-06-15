class_name Spikes extends Area2D

## 尖刺机关 - 触碰即伤

@export var damage: int = 1
@export var knockback_force: Vector2 = Vector2(0, -300)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("hazards")

func _on_body_entered(body: Node2D) -> void:
	if body is PlatformerPlayer:
		var player: PlatformerPlayer = body as PlatformerPlayer
		player.take_damage(damage)
		if player.current_state != PlatformerPlayer.State.DEAD:
			player.velocity = knockback_force
