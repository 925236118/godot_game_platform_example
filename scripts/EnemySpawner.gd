extends Timer

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var max_enemies: int = 15

var spawn_count: int = 0

func _ready() -> void:
	timeout.connect(spawn)
	for i in range(5):
		spawn()

func spawn() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= max_enemies:
		return
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# 从屏幕边缘生成
	var screen_size: Vector2 = Vector2(1280, 720)
	var edge: int = randi() % 4
	var spawn_pos: Vector2
	match edge:
		0: spawn_pos = Vector2(randf_range(0, screen_size.x), -30)
		1: spawn_pos = Vector2(randf_range(0, screen_size.x), screen_size.y + 30)
		2: spawn_pos = Vector2(-30, randf_range(0, screen_size.y))
		3: spawn_pos = Vector2(screen_size.x + 30, randf_range(0, screen_size.y))

	spawn_count += 1
	var enemy: SurvivorEnemy = enemy_scene.instantiate() as SurvivorEnemy
	enemy.global_position = spawn_pos
	# 随游戏时间成长
	var difficulty_mult: float = 1.0 + spawn_count * 0.1
	enemy.max_hp = 20.0 * difficulty_mult
	enemy.hp = enemy.max_hp
	enemy.damage = 8.0 * difficulty_mult
	enemy.xp_value = 5 + int(spawn_count * 1.5)
	enemy.move_speed = 60.0 + spawn_count * 2.0
	add_sibling(enemy)