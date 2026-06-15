extends Timer

## 敌人波次生成器

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var max_enemies: int = 8
@export var spawn_radius: float = 300.0
@export var min_spawn_distance: float = 100.0

var spawn_count: int = 0

func _ready() -> void:
	timeout.connect(_spawn_enemy)
	# 初始生成几个敌人
	for i in range(3):
		_spawn_enemy()

func _spawn_enemy() -> void:
	# 检查当前敌人数量
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= max_enemies:
		return

	# 获取玩家位置
	var player: ArpgPlayer = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# 在玩家周围随机位置生成
	var angle: float = randf_range(0, TAU)
	var dist: float = randf_range(min_spawn_distance, spawn_radius)
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	# 保持在边界内
	spawn_pos.x = clamp(spawn_pos.x, 20, 1260)
	spawn_pos.y = clamp(spawn_pos.y, 20, 700)

	var enemy: ArpgEnemy = enemy_scene.instantiate() as ArpgEnemy
	enemy.global_position = spawn_pos

	# 随波次成长
	spawn_count += 1
	enemy.max_hp = 30.0 + spawn_count * 5.0
	enemy.hp = enemy.max_hp
	enemy.damage = 10.0 + spawn_count * 2.0
	enemy.xp_reward = 15 + spawn_count * 2

	add_sibling(enemy)
