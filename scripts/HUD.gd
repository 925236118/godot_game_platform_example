extends CanvasLayer

## HUD - 平台跳跃抬头显示

var health_label: Label
var coin_label: Label
var score_label: Label
var pause_overlay: ColorRect
var game_over_panel: Panel

func _ready() -> void:
	health_label = $TopInfo/HealthLabel
	coin_label = $TopInfo/CoinLabel
	score_label = $TopInfo/ScoreLabel
	pause_overlay = $PauseOverlay
	game_over_panel = $GameOverPanel

	pause_overlay.hide()
	game_over_panel.hide()

	if GameManager.has_signal("game_paused"):
		GameManager.game_paused.connect(func(): pause_overlay.show())
	if GameManager.has_signal("game_resumed"):
		GameManager.game_resumed.connect(func(): pause_overlay.hide())

	# 按钮连接
	var retry_btn: Button = $GameOverPanel/VBoxContainer/RetryBtn
	var quit_btn: Button = $GameOverPanel/VBoxContainer/QuitBtn
	if retry_btn:
		retry_btn.pressed.connect(_on_retry)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

	var player: PlatformerPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health)
		player.coin_collected.connect(_on_coin)
		player.score_changed.connect(_on_score)
		player.player_died.connect(_on_death)
		_on_health(player.current_health, player.max_health)
		_on_coin(0)
		_on_score(0)

func _on_health(current: int, max_hp: int) -> void:
	health_label.text = "❤️ " + str(current) + "/" + str(max_hp)

func _on_coin(total: int) -> void:
	coin_label.text = "🪙 " + str(total)

func _on_score(points: int) -> void:
	score_label.text = "⭐ " + str(points)

func _on_death() -> void:
	game_over_panel.show()
	await get_tree().create_timer(3.0).timeout
	game_over_panel.hide()
	GameManager.restart_level()

func _on_retry() -> void:
	game_over_panel.hide()
	GameManager.restart_level()

func _on_quit() -> void:
	GameManager.quit_game()
