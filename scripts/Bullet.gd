class_name SurvivorBullet extends Area2D

var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var speed: float = 400.0

func _ready() -> void:
	body_entered.connect(_on_hit)
	var notifier: VisibleOnScreenNotifier2D = $VisNotifier
	if notifier:
		notifier.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_hit(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()