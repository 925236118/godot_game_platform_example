extends CanvasLayer

## HUD - 游戏抬头显示

var health_label: Label
var coin_label: Label
var score_label: Label
var pause_overlay: ColorRect
var game_over_panel: Panel

func _ready() -> void:
	# 手动获取节点引用（避免 % 语法）
	var margin: MarginContainer = $MarginContainer
	var vbox: VBoxContainer = margin.get_node("VBoxContainer")
	health_label = vbox.get_node("HealthLabel")
	coin_label = vbox.get_node("CoinLabel")
	score_label = vbox.get_node("ScoreLabel")

	pause_overlay = $PauseOverlay
	game_over_panel = $GameOverPanel

	# 注册到GameManager
	if GameManager.has_signal("game_paused"):
		GameManager.game_paused.connect(_on_game_paused)
	if GameManager.has_signal("game_resumed"):
		GameManager.game_resumed.connect(_on_game_resumed)

	# 监听玩家信号
	var player: PlatformerPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.coin_collected.connect(_on_coin_changed)
		player.score_changed.connect(_on_score_changed)
		player.player_died.connect(_on_player_died)
		_on_health_changed(player.current_health, player.max_health)
		_on_coin_changed(0)
		_on_score_changed(0)

	pause_overlay.hide()
	game_over_panel.hide()

func _on_health_changed(current: int, max_hp: int) -> void:
	health_label.text = "❤️ " + str(current) + "/" + str(max_hp)

func _on_coin_changed(total: int) -> void:
	coin_label.text = "🪙 " + str(total)

func _on_score_changed(points: int) -> void:
	score_label.text = "⭐ " + str(points)

func _on_game_paused() -> void:
	pause_overlay.show()

func _on_game_resumed() -> void:
	pause_overlay.hide()

func _on_player_died() -> void:
	game_over_panel.show()
	await get_tree().create_timer(3.0).timeout
	game_over_panel.hide()
	GameManager.restart_level()

func _on_retry_pressed() -> void:
	game_over_panel.hide()
	GameManager.restart_level()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
