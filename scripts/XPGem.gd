class_name XPGem extends Area2D

@export var xp_amount: int = 5
var target: Node2D = null
var is_flying: bool = false
var fly_speed: float = 300.0

func _ready() -> void:
	add_to_group("xp_gems")

func _physics_process(delta: float) -> void:
	if is_flying and target:
		var dir: Vector2 = global_position.direction_to(target.global_position)
		position += dir * fly_speed * delta
		if global_position.distance_to(target.global_position) < 10:
			collect()
		return

func collect() -> void:
	var player: SurvivorPlayer = get_tree().get_first_node_in_group("player") as SurvivorPlayer
	if player:
		player.add_xp(xp_amount)
	queue_free()